const { Pool } = require('pg');
const fs = require('fs').promises;
const path = require('path');

// T058: PostgreSQL connection and pooling
class DatabaseConnection {
  constructor() {
    this.pool = null;
    this.isConnected = false;
  }

  async initialize() {
    if (this.pool) {
      return this.pool;
    }

    // Database configuration from environment variables
    const config = {
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5432'),
      database: process.env.DB_NAME || 'fieldphoto_dev',
      user: process.env.DB_USER || 'fieldphoto',
      password: process.env.DB_PASSWORD || 'fieldphoto_pass',

      // Connection pool configuration for optimal performance
      max: parseInt(process.env.DB_POOL_MAX || '20'),
      min: parseInt(process.env.DB_POOL_MIN || '5'),
      idleTimeoutMillis: parseInt(process.env.DB_IDLE_TIMEOUT || '30000'),
      connectionTimeoutMillis: parseInt(process.env.DB_CONNECTION_TIMEOUT || '5000'),

      // Enable SSL in production
      ssl: process.env.NODE_ENV === 'production' ? {
        rejectUnauthorized: false
      } : false
    };

    this.pool = new Pool(config);

    // Handle pool errors
    this.pool.on('error', (err, client) => {
      console.error('Unexpected database pool error:', err);
      this.isConnected = false;
    });

    // Test connection
    try {
      const client = await this.pool.connect();
      await client.query('SELECT NOW()');
      client.release();
      this.isConnected = true;
      console.log('Database connection pool established successfully');
    } catch (error) {
      console.error('Failed to connect to database:', error);
      throw error;
    }

    return this.pool;
  }

  async query(text, params) {
    if (!this.pool) {
      await this.initialize();
    }

    const start = Date.now();
    try {
      const result = await this.pool.query(text, params);
      const duration = Date.now() - start;

      // Log slow queries in development
      if (process.env.NODE_ENV === 'development' && duration > 1000) {
        console.warn(`Slow query (${duration}ms):`, text);
      }

      return result;
    } catch (error) {
      console.error('Database query error:', error);
      console.error('Query:', text);
      console.error('Params:', params);
      throw error;
    }
  }

  async getClient() {
    if (!this.pool) {
      await this.initialize();
    }
    return await this.pool.connect();
  }

  async transaction(callback) {
    const client = await this.getClient();

    try {
      await client.query('BEGIN');
      const result = await callback(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  // Batch insert with transaction
  async batchInsert(table, columns, values) {
    if (values.length === 0) return;

    const client = await this.getClient();

    try {
      await client.query('BEGIN');

      // Build parameterized query
      const placeholders = values.map((row, rowIndex) => {
        const rowPlaceholders = columns.map((col, colIndex) => {
          return `$${rowIndex * columns.length + colIndex + 1}`;
        }).join(', ');
        return `(${rowPlaceholders})`;
      }).join(', ');

      const query = `
        INSERT INTO ${table} (${columns.join(', ')})
        VALUES ${placeholders}
        ON CONFLICT DO NOTHING
      `;

      // Flatten values array
      const flatValues = values.flat();

      await client.query(query, flatValues);
      await client.query('COMMIT');

    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  // Create database schema
  async createSchema() {
    const schemaPath = path.join(__dirname, 'migrations', '001_initial_schema.sql');
    const schema = await fs.readFile(schemaPath, 'utf8');

    const client = await this.getClient();

    try {
      await client.query('BEGIN');

      // Split schema by semicolons and execute each statement
      const statements = schema
        .split(';')
        .map(s => s.trim())
        .filter(s => s.length > 0);

      for (const statement of statements) {
        await client.query(statement);
      }

      await client.query('COMMIT');
      console.log('Database schema created successfully');

    } catch (error) {
      await client.query('ROLLBACK');
      console.error('Failed to create schema:', error);
      throw error;
    } finally {
      client.release();
    }
  }

  // Run migrations
  async migrate() {
    const client = await this.getClient();

    try {
      // Create migrations table if not exists
      await client.query(`
        CREATE TABLE IF NOT EXISTS migrations (
          id SERIAL PRIMARY KEY,
          filename VARCHAR(255) NOT NULL UNIQUE,
          applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);

      // Get list of applied migrations
      const appliedResult = await client.query('SELECT filename FROM migrations');
      const applied = new Set(appliedResult.rows.map(row => row.filename));

      // Get list of migration files
      const migrationsDir = path.join(__dirname, 'migrations');
      const files = await fs.readdir(migrationsDir);
      const migrations = files
        .filter(f => f.endsWith('.sql'))
        .sort();

      // Apply pending migrations
      for (const filename of migrations) {
        if (!applied.has(filename)) {
          console.log(`Applying migration: ${filename}`);

          const migrationPath = path.join(migrationsDir, filename);
          const sql = await fs.readFile(migrationPath, 'utf8');

          await client.query('BEGIN');

          try {
            // Execute migration
            const statements = sql
              .split(';')
              .map(s => s.trim())
              .filter(s => s.length > 0);

            for (const statement of statements) {
              await client.query(statement);
            }

            // Record migration
            await client.query(
              'INSERT INTO migrations (filename) VALUES ($1)',
              [filename]
            );

            await client.query('COMMIT');
            console.log(`Migration ${filename} applied successfully`);

          } catch (error) {
            await client.query('ROLLBACK');
            console.error(`Migration ${filename} failed:`, error);
            throw error;
          }
        }
      }

      console.log('All migrations completed');

    } finally {
      client.release();
    }
  }

  // Database statistics
  async getStats() {
    const result = await this.query(`
      SELECT
        (SELECT COUNT(*) FROM photos) as photo_count,
        (SELECT COUNT(*) FROM equipment) as equipment_count,
        (SELECT COUNT(*) FROM sync_packages WHERE status = 'PENDING') as pending_sync_count,
        pg_database_size(current_database()) as database_size
    `);

    const stats = result.rows[0];

    return {
      photoCount: parseInt(stats.photo_count),
      equipmentCount: parseInt(stats.equipment_count),
      pendingSyncCount: parseInt(stats.pending_sync_count),
      databaseSizeMB: (parseInt(stats.database_size) / 1024 / 1024).toFixed(2)
    };
  }

  // Health check
  async healthCheck() {
    try {
      const result = await this.query('SELECT NOW()');
      return {
        status: 'healthy',
        timestamp: result.rows[0].now,
        poolSize: this.pool.totalCount,
        idleConnections: this.pool.idleCount,
        waitingClients: this.pool.waitingCount
      };
    } catch (error) {
      return {
        status: 'unhealthy',
        error: error.message
      };
    }
  }

  async close() {
    if (this.pool) {
      await this.pool.end();
      this.pool = null;
      this.isConnected = false;
      console.log('Database connection pool closed');
    }
  }
}

// Singleton instance
const db = new DatabaseConnection();

module.exports = db;