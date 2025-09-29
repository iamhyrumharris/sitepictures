const { DataTypes } = require('sequelize');
const sequelize = require('../database/connection');

const Photo = sequelize.define('Photo', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  equipmentId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'Equipment',
      key: 'id',
    },
  },
  revisionId: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'Revisions',
      key: 'id',
    },
  },
  fileName: {
    type: DataTypes.STRING(255),
    allowNull: false,
    unique: true,
  },
  fileHash: {
    type: DataTypes.STRING(64),
    allowNull: false,
    validate: {
      is: /^[a-f0-9]{64}$/,
    },
  },
  latitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true,
    validate: {
      min: -90,
      max: 90,
    },
  },
  longitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true,
    validate: {
      min: -180,
      max: 180,
    },
  },
  capturedAt: {
    type: DataTypes.DATE,
    allowNull: false,
    validate: {
      isDate: true,
      isBefore: new Date().toISOString(),
    },
  },
  notes: {
    type: DataTypes.STRING(1000),
    allowNull: true,
  },
  deviceId: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  isSynced: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  createdAt: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  updatedAt: {
    type: DataTypes.DATE,
    allowNull: false,
  },
}, {
  tableName: 'photos',
  timestamps: true,
  indexes: [
    {
      fields: ['equipmentId', 'capturedAt'],
    },
    {
      fields: ['deviceId', 'createdAt'],
    },
    {
      fields: ['latitude', 'longitude'],
      where: {
        latitude: { [DataTypes.Op.ne]: null },
      },
    },
    {
      fields: ['fileHash'],
      unique: true,
    },
  ],
});

Photo.prototype.toJSON = function() {
  const values = { ...this.get() };
  return values;
};

Photo.prototype.validateIntegrity = async function(fileData) {
  const crypto = require('crypto');
  const hash = crypto.createHash('sha256');
  hash.update(fileData);
  const calculatedHash = hash.digest('hex');
  return calculatedHash === this.fileHash;
};

Photo.prototype.markAsSynced = async function() {
  this.isSynced = true;
  await this.save();
};

Photo.findByEquipment = function(equipmentId, options = {}) {
  return this.findAll({
    where: { equipmentId },
    order: [['capturedAt', 'DESC']],
    ...options,
  });
};

Photo.findByDevice = function(deviceId, options = {}) {
  return this.findAll({
    where: { deviceId },
    order: [['createdAt', 'DESC']],
    ...options,
  });
};

Photo.findUnsynced = function(limit = 100) {
  return this.findAll({
    where: { isSynced: false },
    order: [['createdAt', 'ASC']],
    limit,
  });
};

Photo.findByLocation = async function(lat, lng, radiusMeters = 1000) {
  const earthRadius = 6371000;
  const latRad = lat * Math.PI / 180;
  const lngRad = lng * Math.PI / 180;
  const latDelta = radiusMeters / earthRadius * 180 / Math.PI;
  const lngDelta = radiusMeters / (earthRadius * Math.cos(latRad)) * 180 / Math.PI;

  return this.findAll({
    where: {
      latitude: {
        [DataTypes.Op.between]: [lat - latDelta, lat + latDelta],
      },
      longitude: {
        [DataTypes.Op.between]: [lng - lngDelta, lng + lngDelta],
      },
    },
  });
};

module.exports = Photo;