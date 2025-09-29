const { DataTypes } = require('sequelize');
const sequelize = require('../database/connection');

const SyncPackage = sequelize.define('SyncPackage', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  entityType: {
    type: DataTypes.ENUM('Photo', 'Client', 'Site', 'Equipment', 'Revision', 'GPSBoundary'),
    allowNull: false,
  },
  entityId: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  operation: {
    type: DataTypes.ENUM('CREATE', 'UPDATE', 'DELETE'),
    allowNull: false,
  },
  data: {
    type: DataTypes.JSON,
    allowNull: false,
  },
  timestamp: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  deviceId: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('PENDING', 'SYNCING', 'SYNCED', 'FAILED'),
    allowNull: false,
    defaultValue: 'PENDING',
  },
  retryCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    validate: {
      min: 0,
      max: 10,
    },
  },
  lastAttempt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  errorMessage: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
}, {
  tableName: 'sync_packages',
  timestamps: false,
  indexes: [
    {
      fields: ['status', 'timestamp'],
    },
    {
      fields: ['deviceId', 'status'],
    },
    {
      fields: ['entityType', 'entityId'],
    },
  ],
});

SyncPackage.prototype.toJSON = function() {
  const values = { ...this.get() };
  return values;
};

SyncPackage.prototype.markAsSyncing = async function() {
  this.status = 'SYNCING';
  this.lastAttempt = new Date();
  await this.save();
};

SyncPackage.prototype.markAsSynced = async function() {
  this.status = 'SYNCED';
  await this.save();
};

SyncPackage.prototype.markAsFailed = async function(errorMessage = null) {
  this.status = 'FAILED';
  this.retryCount += 1;
  if (errorMessage) {
    this.errorMessage = errorMessage;
  }
  await this.save();
};

SyncPackage.prototype.canRetry = function() {
  return this.status === 'FAILED' && this.retryCount < 10;
};

SyncPackage.prototype.resetForRetry = async function() {
  this.status = 'PENDING';
  this.errorMessage = null;
  await this.save();
};

SyncPackage.findPending = function(limit = 100) {
  return this.findAll({
    where: { status: 'PENDING' },
    order: [['timestamp', 'ASC']],
    limit,
  });
};

SyncPackage.findByDevice = function(deviceId, status = null) {
  const where = { deviceId };
  if (status) {
    where.status = status;
  }
  return this.findAll({
    where,
    order: [['timestamp', 'DESC']],
  });
};

SyncPackage.findFailedWithRetries = function() {
  const { Op } = require('sequelize');
  return this.findAll({
    where: {
      status: 'FAILED',
      retryCount: {
        [Op.lt]: 10,
      },
    },
    order: [['lastAttempt', 'ASC']],
  });
};

SyncPackage.findChangesSince = function(timestamp, deviceId) {
  const { Op } = require('sequelize');
  return this.findAll({
    where: {
      timestamp: {
        [Op.gt]: timestamp,
      },
      deviceId: {
        [Op.ne]: deviceId,
      },
      status: 'SYNCED',
    },
    order: [['timestamp', 'ASC']],
  });
};

SyncPackage.detectConflicts = async function(packages) {
  const conflicts = [];
  const entityMap = new Map();

  for (const pkg of packages) {
    const key = `${pkg.entityType}-${pkg.entityId}`;
    if (entityMap.has(key)) {
      const existing = entityMap.get(key);
      conflicts.push({
        entityId: pkg.entityId,
        entityType: pkg.entityType,
        conflictType: 'CONCURRENT_UPDATE',
        versions: [
          {
            deviceId: existing.deviceId,
            timestamp: existing.timestamp,
            data: existing.data,
          },
          {
            deviceId: pkg.deviceId,
            timestamp: pkg.timestamp,
            data: pkg.data,
          },
        ],
        resolution: 'MERGE_ALL',
      });
    } else {
      entityMap.set(key, pkg);
    }
  }

  return conflicts;
};

module.exports = SyncPackage;