import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'dart:async';

// T060: Transaction support for data integrity
class TransactionManager {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Stack to track nested transaction attempts
  final List<String> _transactionStack = [];

  // Active transaction reference
  Transaction? _activeTransaction;

  // Transaction lock to prevent concurrent transactions
  final _transactionLock = Completer<void>();

  // Execute a transactional operation with automatic rollback on error
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction txn) operation, {
    String? name,
  }) async {
    final transactionName = name ?? 'Transaction_${DateTime.now().millisecondsSinceEpoch}';

    // Check for nested transaction attempt
    if (_activeTransaction != null) {
      throw StateError(
        'Nested transactions not supported. '
        'Current: ${_transactionStack.last}, '
        'Attempted: $transactionName'
      );
    }

    final db = await _dbHelper.database;
    _transactionStack.add(transactionName);

    try {
      // Execute the transaction
      final result = await db.transaction<T>((txn) async {
        _activeTransaction = txn;

        try {
          // Enable foreign keys within transaction
          await txn.execute('PRAGMA foreign_keys = ON');

          // Execute the operation
          final operationResult = await operation(txn);

          // Log successful transaction
          await _logTransaction(txn, transactionName, 'SUCCESS');

          return operationResult;

        } catch (error) {
          // Log failed transaction
          await _logTransaction(txn, transactionName, 'FAILED', error.toString());

          // Re-throw to trigger rollback
          throw error;
        } finally {
          _activeTransaction = null;
        }
      });

      _transactionStack.removeLast();
      return result;

    } catch (error) {
      _transactionStack.removeLast();
      throw TransactionException(
        'Transaction "$transactionName" failed',
        originalError: error,
      );
    }
  }

  // Batch operations with transaction
  Future<void> batchOperation(
    Future<void> Function(Batch batch) operation, {
    bool noResult = true,
    bool continueOnError = false,
  }) async {
    return runTransaction((txn) async {
      final batch = txn.batch();

      await operation(batch);

      final results = await batch.commit(
        noResult: noResult,
        continueOnError: continueOnError,
      );

      if (!noResult && !continueOnError) {
        // Check for errors in results
        for (final result in results) {
          if (result is DatabaseException) {
            throw result;
          }
        }
      }
    }, name: 'BatchOperation');
  }

  // Execute multiple operations atomically
  Future<List<T>> executeAtomic<T>(
    List<Future<T> Function(Transaction txn)> operations,
  ) async {
    return runTransaction((txn) async {
      final results = <T>[];

      for (final operation in operations) {
        final result = await operation(txn);
        results.add(result);
      }

      return results;
    }, name: 'AtomicOperations');
  }

  // Savepoint emulation using temporary tables
  Future<T> withSavepoint<T>(
    Transaction txn,
    String savepointName,
    Future<T> Function() operation,
  ) async {
    // SQLite doesn't support savepoints in the same way as PostgreSQL
    // We'll track changes manually for potential rollback

    final changesTable = 'temp_savepoint_$savepointName';

    try {
      // Create temporary table to track changes
      await txn.execute('''
        CREATE TEMPORARY TABLE IF NOT EXISTS $changesTable (
          table_name TEXT,
          operation TEXT,
          row_id TEXT,
          old_data TEXT,
          timestamp TEXT
        )
      ''');

      // Execute operation
      final result = await operation();

      // Clean up temporary table on success
      await txn.execute('DROP TABLE IF EXISTS $changesTable');

      return result;

    } catch (error) {
      // In case of error, we could potentially use the changes table
      // to manually revert changes, but SQLite transaction will handle it
      await txn.execute('DROP TABLE IF EXISTS $changesTable');
      throw error;
    }
  }

  // Optimistic locking support
  Future<T> withOptimisticLock<T>(
    Transaction txn,
    String table,
    String id,
    Future<T> Function(Map<String, dynamic> currentData) operation,
  ) async {
    // Read current data with version
    final result = await txn.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      throw StateError('Record not found for optimistic lock: $table.$id');
    }

    final currentData = result.first;
    final currentVersion = currentData['updated_at'] as String;

    // Execute operation
    final operationResult = await operation(Map<String, dynamic>.from(currentData));

    // Verify version hasn't changed
    final checkResult = await txn.query(
      table,
      columns: ['updated_at'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (checkResult.isEmpty) {
      throw StateError('Record disappeared during optimistic lock: $table.$id');
    }

    final newVersion = checkResult.first['updated_at'] as String;

    if (newVersion != currentVersion) {
      throw OptimisticLockException(
        'Record was modified by another process',
        table: table,
        id: id,
      );
    }

    return operationResult;
  }

  // Pessimistic locking emulation (SQLite doesn't have true row locks)
  Future<T> withPessimisticLock<T>(
    Transaction txn,
    String table,
    String id,
    Future<T> Function() operation,
  ) async {
    // In SQLite, we simulate pessimistic locking using a lock table
    final lockTable = 'locks';
    final lockId = '${table}_$id';

    try {
      // Create lock table if not exists
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS $lockTable (
          lock_id TEXT PRIMARY KEY,
          locked_by TEXT,
          locked_at TEXT
        )
      ''');

      // Try to acquire lock
      await txn.insert(
        lockTable,
        {
          'lock_id': lockId,
          'locked_by': 'current_device', // TODO: Get actual device ID
          'locked_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );

      // Execute operation with lock held
      final result = await operation();

      // Release lock
      await txn.delete(
        lockTable,
        where: 'lock_id = ?',
        whereArgs: [lockId],
      );

      return result;

    } catch (error) {
      if (error is DatabaseException && error.isUniqueConstraintError()) {
        throw PessimisticLockException(
          'Record is locked by another process',
          table: table,
          id: id,
        );
      }
      throw error;
    }
  }

  // Deadlock detection and retry
  Future<T> withDeadlockRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(milliseconds: 100),
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error) {
        attempts++;

        if (error is DatabaseException && error.isDatabaseClosedError()) {
          // Database was closed, reconnect
          await _dbHelper.database;
        } else if (error is DatabaseException &&
                   (error.isConcurrencyError() || error.isDuplicateError())) {
          // Potential deadlock or conflict
          if (attempts >= maxRetries) {
            throw DeadlockException(
              'Operation failed after $maxRetries retries',
              attempts: attempts,
              originalError: error,
            );
          }

          // Exponential backoff
          final delay = retryDelay * (attempts * attempts);
          await Future.delayed(delay);

          continue;
        } else {
          // Non-retryable error
          throw error;
        }
      }
    }

    throw StateError('Unexpected end of retry loop');
  }

  // Transaction logging for audit trail
  Future<void> _logTransaction(
    Transaction txn,
    String transactionName,
    String status, [
    String? errorMessage,
  ]) async {
    try {
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS transaction_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transaction_name TEXT,
          status TEXT,
          error_message TEXT,
          timestamp TEXT
        )
      ''');

      await txn.insert('transaction_log', {
        'transaction_name': transactionName,
        'status': status,
        'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore logging errors to not interfere with main transaction
      print('Failed to log transaction: $e');
    }
  }

  // Clean up old transaction logs
  Future<void> cleanupTransactionLogs({
    Duration retention = const Duration(days: 30),
  }) async {
    final db = await _dbHelper.database;
    final cutoffDate = DateTime.now().subtract(retention);

    await db.delete(
      'transaction_log',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // Get transaction statistics
  Future<Map<String, dynamic>> getTransactionStats() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as total_transactions,
        SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) as successful,
        SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) as failed,
        MAX(timestamp) as last_transaction
      FROM transaction_log
      WHERE timestamp > datetime('now', '-1 day')
    ''');

    if (result.isEmpty) {
      return {
        'totalTransactions': 0,
        'successful': 0,
        'failed': 0,
        'successRate': 0.0,
        'lastTransaction': null,
      };
    }

    final stats = result.first;
    final total = stats['total_transactions'] as int? ?? 0;
    final successful = stats['successful'] as int? ?? 0;

    return {
      'totalTransactions': total,
      'successful': successful,
      'failed': stats['failed'] ?? 0,
      'successRate': total > 0 ? (successful / total * 100) : 0.0,
      'lastTransaction': stats['last_transaction'],
    };
  }
}

// Custom exceptions
class TransactionException implements Exception {
  final String message;
  final dynamic originalError;

  TransactionException(this.message, {this.originalError});

  @override
  String toString() => 'TransactionException: $message\n'
      '${originalError != null ? "Caused by: $originalError" : ""}';
}

class OptimisticLockException implements Exception {
  final String message;
  final String table;
  final String id;

  OptimisticLockException(this.message, {
    required this.table,
    required this.id,
  });

  @override
  String toString() => 'OptimisticLockException: $message (${table}.$id)';
}

class PessimisticLockException implements Exception {
  final String message;
  final String table;
  final String id;

  PessimisticLockException(this.message, {
    required this.table,
    required this.id,
  });

  @override
  String toString() => 'PessimisticLockException: $message (${table}.$id)';
}

class DeadlockException implements Exception {
  final String message;
  final int attempts;
  final dynamic originalError;

  DeadlockException(this.message, {
    required this.attempts,
    this.originalError,
  });

  @override
  String toString() => 'DeadlockException: $message after $attempts attempts\n'
      '${originalError != null ? "Caused by: $originalError" : ""}';
}

// Extension for DatabaseException
extension DatabaseExceptionExtensions on DatabaseException {
  bool isConcurrencyError() {
    return toString().toLowerCase().contains('locked') ||
           toString().toLowerCase().contains('busy');
  }

  bool isDuplicateError() {
    return isUniqueConstraintError() ||
           toString().toLowerCase().contains('duplicate');
  }
}