const express = require('express');
const router = express.Router();
const SyncPackage = require('../models/sync_package');
const Photo = require('../models/photo');
const Client = require('../models/client');
const Site = require('../models/site');
const Equipment = require('../models/equipment');
const GPSBoundary = require('../models/gps_boundary');

// T043: POST /sync/changes - Upload pending changes from device
router.post('/changes', async (req, res) => {
  try {
    const { deviceId, packages } = req.body;

    if (!deviceId || !packages || !Array.isArray(packages)) {
      return res.status(400).json({
        error: 'Invalid request: deviceId and packages array required'
      });
    }

    const processed = [];
    const conflicts = [];

    for (const pkg of packages) {
      try {
        // Check for conflicts based on entity type and timestamp
        const existingEntity = await getEntityByTypeAndId(pkg.entityType, pkg.entityId);

        if (existingEntity && existingEntity.updatedAt > new Date(pkg.timestamp)) {
          // Conflict detected - merge all versions per requirements
          conflicts.push({
            entityId: pkg.entityId,
            entityType: pkg.entityType,
            conflictType: 'CONCURRENT_UPDATE',
            versions: [
              {
                deviceId: existingEntity.deviceId || existingEntity.createdBy,
                timestamp: existingEntity.updatedAt,
                data: existingEntity
              },
              {
                deviceId: deviceId,
                timestamp: pkg.timestamp,
                data: pkg.data
              }
            ],
            resolution: 'MERGE_ALL'
          });

          // Apply merge-all strategy
          const mergedData = mergeEntityData(existingEntity, pkg.data);
          await updateEntityByType(pkg.entityType, pkg.entityId, mergedData);
        } else {
          // No conflict, apply the change
          await applyPackageChange(pkg);
        }

        // Mark package as synced
        pkg.status = 'SYNCED';
        await SyncPackage.updateStatus(pkg.id, 'SYNCED');
        processed.push(pkg.id);

      } catch (error) {
        console.error(`Failed to process package ${pkg.id}:`, error);
        pkg.status = 'FAILED';
        pkg.retryCount = (pkg.retryCount || 0) + 1;
        await SyncPackage.updateStatus(pkg.id, 'FAILED', pkg.retryCount);
      }
    }

    res.json({
      processed: processed.length,
      conflicts: conflicts
    });

  } catch (error) {
    console.error('Sync error:', error);
    res.status(500).json({ error: 'Internal server error during sync' });
  }
});

// T044: GET /sync/changes/{since} - Download changes since timestamp
router.get('/changes/:since', async (req, res) => {
  try {
    const { since } = req.params;
    const { deviceId } = req.query;

    if (!deviceId) {
      return res.status(400).json({
        error: 'deviceId query parameter required'
      });
    }

    const sinceDate = new Date(since);
    if (isNaN(sinceDate.getTime())) {
      return res.status(400).json({
        error: 'Invalid timestamp format'
      });
    }

    // Get all changes from other devices since the given timestamp
    const changes = await SyncPackage.getChangesSince(sinceDate, deviceId);

    // Get the most recent modification timestamp
    const lastModified = changes.length > 0
      ? changes.reduce((max, change) =>
          change.timestamp > max ? change.timestamp : max,
          changes[0].timestamp)
      : sinceDate;

    res.json({
      changes: changes,
      lastModified: lastModified.toISOString()
    });

  } catch (error) {
    console.error('Error fetching changes:', error);
    res.status(500).json({ error: 'Failed to retrieve changes' });
  }
});

// Helper functions
async function getEntityByTypeAndId(entityType, entityId) {
  switch(entityType) {
    case 'Photo':
      return await Photo.findById(entityId);
    case 'Client':
      return await Client.findById(entityId);
    case 'Site':
      return await Site.findById(entityId);
    case 'Equipment':
      return await Equipment.findById(entityId);
    case 'GPSBoundary':
      return await GPSBoundary.findById(entityId);
    default:
      throw new Error(`Unknown entity type: ${entityType}`);
  }
}

async function updateEntityByType(entityType, entityId, data) {
  switch(entityType) {
    case 'Photo':
      return await Photo.update(entityId, data);
    case 'Client':
      return await Client.update(entityId, data);
    case 'Site':
      return await Site.update(entityId, data);
    case 'Equipment':
      return await Equipment.update(entityId, data);
    case 'GPSBoundary':
      return await GPSBoundary.update(entityId, data);
    default:
      throw new Error(`Unknown entity type: ${entityType}`);
  }
}

async function applyPackageChange(pkg) {
  const { entityType, entityId, operation, data } = pkg;

  switch(operation) {
    case 'CREATE':
      return await createEntity(entityType, data);
    case 'UPDATE':
      return await updateEntityByType(entityType, entityId, data);
    case 'DELETE':
      return await deleteEntity(entityType, entityId);
    default:
      throw new Error(`Unknown operation: ${operation}`);
  }
}

async function createEntity(entityType, data) {
  switch(entityType) {
    case 'Photo':
      return await Photo.create(data);
    case 'Client':
      return await Client.create(data);
    case 'Site':
      return await Site.create(data);
    case 'Equipment':
      return await Equipment.create(data);
    case 'GPSBoundary':
      return await GPSBoundary.create(data);
    default:
      throw new Error(`Unknown entity type: ${entityType}`);
  }
}

async function deleteEntity(entityType, entityId) {
  switch(entityType) {
    case 'Photo':
      return await Photo.delete(entityId);
    case 'Client':
      return await Client.softDelete(entityId);
    case 'Site':
      return await Site.softDelete(entityId);
    case 'Equipment':
      return await Equipment.softDelete(entityId);
    case 'GPSBoundary':
      return await GPSBoundary.softDelete(entityId);
    default:
      throw new Error(`Unknown entity type: ${entityType}`);
  }
}

function mergeEntityData(existing, incoming) {
  // Merge strategy: Keep all data from both versions
  const merged = { ...existing };

  // For conflicting fields, append values or create arrays
  for (const key in incoming) {
    if (key === 'id' || key === 'createdAt') {
      continue; // Skip immutable fields
    }

    if (key === 'notes' || key === 'description') {
      // Merge text fields with separator
      if (existing[key] && incoming[key] && existing[key] !== incoming[key]) {
        merged[key] = `${existing[key]}; ${incoming[key]}`;
      } else if (incoming[key]) {
        merged[key] = incoming[key];
      }
    } else if (key === 'tags' && Array.isArray(existing[key]) && Array.isArray(incoming[key])) {
      // Merge arrays by combining unique values
      merged[key] = [...new Set([...existing[key], ...incoming[key]])];
    } else {
      // For other fields, take the incoming value
      merged[key] = incoming[key];
    }
  }

  merged.updatedAt = new Date();
  return merged;
}

module.exports = router;