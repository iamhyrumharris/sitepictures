import 'package:flutter/foundation.dart';
import 'package:fieldphoto_pro/services/storage_service.dart';
import 'package:fieldphoto_pro/services/network_monitor_service.dart';

/// Base service class to reduce code duplication across services
abstract class BaseService {
  final StorageService storageService;
  final NetworkMonitorService networkMonitor;

  BaseService({
    required this.storageService,
    required this.networkMonitor,
  });

  /// Common error handling logic
  Future<T> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    T? fallbackValue,
    bool requiresNetwork = false,
  }) async {
    try {
      if (requiresNetwork) {
        final isConnected = await networkMonitor.isConnected();
        if (!isConnected && fallbackValue != null) {
          return fallbackValue;
        }
      }

      return await operation();
    } catch (e, stackTrace) {
      logError(e, stackTrace);
      if (fallbackValue != null) {
        return fallbackValue;
      }
      rethrow;
    }
  }

  /// Common retry logic with exponential backoff
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }

    throw Exception('Operation failed after $maxRetries retries');
  }

  /// Common batch processing logic
  Future<List<R>> processBatch<T, R>(
    List<T> items,
    Future<R> Function(T item) processor, {
    int batchSize = 10,
    bool parallel = false,
  }) async {
    final results = <R>[];

    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize).toList();

      if (parallel) {
        final batchResults = await Future.wait(
          batch.map((item) => processor(item)),
        );
        results.addAll(batchResults);
      } else {
        for (final item in batch) {
          results.add(await processor(item));
        }
      }
    }

    return results;
  }

  /// Common caching logic
  final Map<String, CacheEntry> _cache = {};

  Future<T> getCached<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration ttl = const Duration(minutes: 5),
  }) async {
    final cached = _cache[key];

    if (cached != null && !cached.isExpired) {
      return cached.value as T;
    }

    final value = await fetcher();
    _cache[key] = CacheEntry(value: value, expiry: DateTime.now().add(ttl));

    return value;
  }

  void clearCache() {
    _cache.clear();
  }

  /// Common logging logic
  void logError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('Error in ${runtimeType}: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
    // In production, send to error reporting service
  }

  void logInfo(String message) {
    if (kDebugMode) {
      print('[${runtimeType}] $message');
    }
  }

  /// Common validation logic
  bool validateUuid(String? id) {
    if (id == null || id.isEmpty) return false;

    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    return uuidRegex.hasMatch(id);
  }

  bool validateGpsCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    return latitude >= -90 && latitude <= 90 &&
           longitude >= -180 && longitude <= 180;
  }

  /// Common database transaction wrapper
  Future<T> executeInTransaction<T>(
    Future<T> Function() operation,
  ) async {
    return storageService.transaction(() async {
      return await operation();
    });
  }

  /// Common performance monitoring
  Future<T> measurePerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      logInfo('$operationName completed in ${stopwatch.elapsedMilliseconds}ms');

      return result;
    } catch (e) {
      stopwatch.stop();
      logInfo('$operationName failed after ${stopwatch.elapsedMilliseconds}ms');
      rethrow;
    }
  }

  /// Dispose method to clean up resources
  @mustCallSuper
  void dispose() {
    clearCache();
  }
}

/// Cache entry with expiration
class CacheEntry {
  final dynamic value;
  final DateTime expiry;

  CacheEntry({
    required this.value,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// Mixin for services that need queue management
mixin QueueManagement {
  final _queue = <QueueItem>[];
  bool _isProcessing = false;

  Future<void> addToQueue(QueueItem item) async {
    _queue.add(item);
    if (!_isProcessing) {
      await _processQueue();
    }
  }

  Future<void> _processQueue() async {
    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final item = _queue.removeAt(0);
      await item.process();
    }

    _isProcessing = false;
  }
}

/// Queue item interface
abstract class QueueItem {
  Future<void> process();
}

/// Mixin for services that need event handling
mixin EventHandling {
  final _listeners = <String, List<Function>>{};

  void addEventListener(String event, Function listener) {
    _listeners[event] ??= [];
    _listeners[event]!.add(listener);
  }

  void removeEventListener(String event, Function listener) {
    _listeners[event]?.remove(listener);
  }

  void emit(String event, [dynamic data]) {
    final eventListeners = _listeners[event];
    if (eventListeners != null) {
      for (final listener in eventListeners) {
        listener(data);
      }
    }
  }
}