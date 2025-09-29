class ConflictResolver {
  constructor(db) {
    this.db = db;
  }

  async resolveConflicts(packages, deviceId) {
    const conflicts = [];
    const resolved = [];

    for (const pkg of packages) {
      const existingEntity = await this.getExistingEntity(pkg.entityType, pkg.entityId);

      if (!existingEntity) {
        resolved.push(pkg);
        continue;
      }

      const conflict = await this.detectConflict(pkg, existingEntity, deviceId);
      if (conflict) {
        const resolution = await this.mergeVersions(conflict);
        conflicts.push(resolution);
      } else {
        resolved.push(pkg);
      }
    }

    return { resolved, conflicts };
  }

  async getExistingEntity(entityType, entityId) {
    const tableMap = {
      'Photo': 'photos',
      'Client': 'clients',
      'Site': 'sites',
      'Equipment': 'equipment',
      'Revision': 'revisions',
      'GPSBoundary': 'gps_boundaries'
    };

    const tableName = tableMap[entityType];
    if (!tableName) {
      throw new Error(`Unknown entity type: ${entityType}`);
    }

    try {
      // Use parameterized query with table name validation
      const validTables = ['photos', 'clients', 'sites', 'equipment', 'revisions', 'gps_boundaries'];
      if (!validTables.includes(tableName)) {
        throw new Error(`Invalid table name: ${tableName}`);
      }

      // Safe query with validated table name and parameterized ID
      const query = `SELECT * FROM "${tableName}" WHERE id = $1`;
      const result = await this.db.query(query, [entityId]);
      return result.rows[0];
    } catch (error) {
      console.error(`Error fetching existing entity: ${error.message}`);
      return null;
    }
  }

  async detectConflict(incoming, existing, deviceId) {
    if (incoming.operation === 'DELETE' && existing) {
      return {
        type: 'DELETE_CONFLICT',
        entityId: incoming.entityId,
        entityType: incoming.entityType,
        incoming: incoming,
        existing: existing
      };
    }

    if (incoming.operation === 'UPDATE' && existing) {
      const incomingTime = new Date(incoming.timestamp);
      const existingTime = new Date(existing.updated_at);

      if (existingTime > incomingTime) {
        return {
          type: 'CONCURRENT_UPDATE',
          entityId: incoming.entityId,
          entityType: incoming.entityType,
          incoming: incoming,
          existing: existing
        };
      }

      const lastDeviceUpdate = await this.getLastDeviceUpdate(
        incoming.entityType,
        incoming.entityId,
        deviceId
      );

      if (lastDeviceUpdate && lastDeviceUpdate.updated_at < existing.updated_at) {
        return {
          type: 'CONCURRENT_UPDATE',
          entityId: incoming.entityId,
          entityType: incoming.entityType,
          incoming: incoming,
          existing: existing
        };
      }
    }

    return null;
  }

  async mergeVersions(conflict) {
    const versions = [];

    if (conflict.existing) {
      versions.push({
        deviceId: conflict.existing.device_id || 'server',
        timestamp: conflict.existing.updated_at,
        data: this.cleanEntityData(conflict.existing)
      });
    }

    if (conflict.incoming) {
      versions.push({
        deviceId: conflict.incoming.deviceId,
        timestamp: conflict.incoming.timestamp,
        data: conflict.incoming.data
      });
    }

    const resolution = {
      entityId: conflict.entityId,
      entityType: conflict.entityType,
      conflictType: conflict.type,
      versions: versions,
      resolution: 'MERGE_ALL'
    };

    await this.saveMergedVersion(resolution);

    return resolution;
  }

  async saveMergedVersion(resolution) {
    const mergedData = this.mergeAllFields(resolution.versions);
    const tableMap = {
      'Photo': 'photos',
      'Client': 'clients',
      'Site': 'sites',
      'Equipment': 'equipment',
      'Revision': 'revisions',
      'GPSBoundary': 'gps_boundaries'
    };

    const tableName = tableMap[resolution.entityType];
    if (!tableName) return;

    // Validate table name to prevent SQL injection
    const validTables = ['photos', 'clients', 'sites', 'equipment', 'revisions', 'gps_boundaries'];
    if (!validTables.includes(tableName)) {
      throw new Error(`Invalid table name: ${tableName}`);
    }

    try {
      await this.db.query('BEGIN');

      const historyQuery = `
        INSERT INTO sync_history (entity_type, entity_id, device_id, operation, data, timestamp)
        VALUES ($1, $2, $3, $4, $5, $6)
      `;

      for (const version of resolution.versions) {
        await this.db.query(historyQuery, [
          resolution.entityType,
          resolution.entityId,
          version.deviceId,
          'MERGE',
          JSON.stringify(version.data),
          version.timestamp
        ]);
      }

      const updateQuery = this.buildUpdateQuery(tableName, mergedData, resolution.entityId);
      await this.db.query(updateQuery.query, updateQuery.values);

      await this.db.query('COMMIT');
    } catch (error) {
      await this.db.query('ROLLBACK');
      console.error('Error saving merged version:', error);
      throw error;
    }
  }

  mergeAllFields(versions) {
    const merged = {};
    const timestamps = {};

    for (const version of versions) {
      const timestamp = new Date(version.timestamp).getTime();

      for (const [key, value] of Object.entries(version.data)) {
        if (!timestamps[key] || timestamp > timestamps[key]) {
          merged[key] = value;
          timestamps[key] = timestamp;
        }
      }
    }

    if (versions.length > 1) {
      const notes = [];
      const devices = new Set();

      for (const version of versions) {
        if (version.data.notes) {
          notes.push(version.data.notes);
        }
        devices.add(version.deviceId);
      }

      if (notes.length > 1) {
        merged.notes = notes.join('; ');
      }

      if (merged.description && versions.some(v => v.data.description !== merged.description)) {
        const descriptions = versions
          .map(v => v.data.description)
          .filter(d => d)
          .join('; ');
        merged.description = descriptions;
      }
    }

    merged.updated_at = new Date().toISOString();
    return merged;
  }

  buildUpdateQuery(tableName, data, entityId) {
    const fields = [];
    const values = [];
    let paramIndex = 1;

    for (const [key, value] of Object.entries(data)) {
      if (key !== 'id' && key !== 'created_at') {
        fields.push(`${key} = $${paramIndex}`);
        values.push(value);
        paramIndex++;
      }
    }

    values.push(entityId);
    const query = `UPDATE ${tableName} SET ${fields.join(', ')} WHERE id = $${paramIndex}`;

    return { query, values };
  }

  cleanEntityData(entity) {
    const cleaned = { ...entity };
    delete cleaned.created_at;
    delete cleaned.updated_at;
    delete cleaned.is_synced;
    return cleaned;
  }

  async getLastDeviceUpdate(entityType, entityId, deviceId) {
    const query = `
      SELECT * FROM sync_history
      WHERE entity_type = $1 AND entity_id = $2 AND device_id = $3
      ORDER BY timestamp DESC
      LIMIT 1
    `;

    try {
      const result = await this.db.query(query, [entityType, entityId, deviceId]);
      return result.rows[0];
    } catch (error) {
      console.error('Error fetching device update history:', error);
      return null;
    }
  }

  async getConflictHistory(entityId, entityType) {
    const query = `
      SELECT sh.*,
             CASE
               WHEN u.device_name IS NOT NULL THEN u.device_name
               ELSE sh.device_id
             END as device_display_name
      FROM sync_history sh
      LEFT JOIN users u ON sh.device_id = u.id
      WHERE sh.entity_id = $1 AND sh.entity_type = $2
      ORDER BY sh.timestamp DESC
    `;

    try {
      const result = await this.db.query(query, [entityId, entityType]);
      return result.rows;
    } catch (error) {
      console.error('Error fetching conflict history:', error);
      return [];
    }
  }

  async resolveManualConflict(entityId, entityType, selectedVersionId) {
    const query = `
      SELECT data FROM sync_history
      WHERE entity_id = $1 AND entity_type = $2 AND id = $3
    `;

    try {
      const result = await this.db.query(query, [entityId, entityType, selectedVersionId]);
      if (result.rows.length === 0) {
        throw new Error('Version not found');
      }

      const selectedData = JSON.parse(result.rows[0].data);
      const tableMap = {
        'Photo': 'photos',
        'Client': 'clients',
        'Site': 'sites',
        'Equipment': 'equipment',
        'Revision': 'revisions',
        'GPSBoundary': 'gps_boundaries'
      };

      const tableName = tableMap[entityType];
      const updateQuery = this.buildUpdateQuery(tableName, selectedData, entityId);
      await this.db.query(updateQuery.query, updateQuery.values);

      return { success: true, appliedData: selectedData };
    } catch (error) {
      console.error('Error resolving manual conflict:', error);
      throw error;
    }
  }
}

module.exports = ConflictResolver;