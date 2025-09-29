const { DataTypes } = require('sequelize');
const sequelize = require('../database/connection');

const GPSBoundary = sequelize.define('GPSBoundary', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  clientId: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'Clients',
      key: 'id',
    },
  },
  siteId: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'Sites',
      key: 'id',
    },
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    validate: {
      notEmpty: true,
      len: [1, 100],
    },
  },
  centerLatitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: false,
    validate: {
      min: -90,
      max: 90,
    },
  },
  centerLongitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: false,
    validate: {
      min: -180,
      max: 180,
    },
  },
  radiusMeters: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
    validate: {
      min: 1,
      max: 10000,
    },
  },
  priority: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1,
    validate: {
      min: 1,
    },
  },
  createdAt: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  updatedAt: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
}, {
  tableName: 'gps_boundaries',
  timestamps: true,
  indexes: [
    {
      fields: ['clientId'],
    },
    {
      fields: ['siteId'],
    },
    {
      fields: ['priority'],
    },
    {
      fields: ['isActive'],
    },
  ],
});

GPSBoundary.prototype.toJSON = function() {
  const values = { ...this.get() };
  return values;
};

GPSBoundary.prototype.containsLocation = function(latitude, longitude) {
  const distance = this.calculateDistance(
    this.centerLatitude,
    this.centerLongitude,
    latitude,
    longitude
  );
  return distance <= this.radiusMeters;
};

GPSBoundary.prototype.distanceToLocation = function(latitude, longitude) {
  return this.calculateDistance(
    this.centerLatitude,
    this.centerLongitude,
    latitude,
    longitude
  );
};

GPSBoundary.prototype.calculateDistance = function(lat1, lon1, lat2, lon2) {
  const earthRadius = 6371000;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) *
    Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) *
    Math.sin(dLon / 2);
  const c = 2 * Math.asin(Math.sqrt(a));
  return earthRadius * c;
};

GPSBoundary.prototype.getConfidence = function() {
  const radius = parseFloat(this.radiusMeters);
  if (radius <= 100) return 1.0;
  if (radius <= 500) return 0.9;
  if (radius <= 1000) return 0.8;
  if (radius <= 5000) return 0.6;
  return 0.4;
};

GPSBoundary.prototype.overlapsWith = function(other) {
  const distance = this.calculateDistance(
    this.centerLatitude,
    this.centerLongitude,
    other.centerLatitude,
    other.centerLongitude
  );
  return distance < (parseFloat(this.radiusMeters) + parseFloat(other.radiusMeters));
};

GPSBoundary.findByLocation = async function(latitude, longitude, companyId = null) {
  const allBoundaries = await this.findAll({
    where: {
      isActive: true,
      ...(companyId && { clientId: companyId }),
    },
  });

  const matches = [];
  for (const boundary of allBoundaries) {
    if (boundary.containsLocation(latitude, longitude)) {
      matches.push({
        boundary,
        distance: boundary.distanceToLocation(latitude, longitude),
        confidence: boundary.getConfidence(),
      });
    }
  }

  matches.sort((a, b) => {
    if (a.boundary.priority !== b.boundary.priority) {
      return b.boundary.priority - a.boundary.priority;
    }
    return a.distance - b.distance;
  });

  return matches;
};

GPSBoundary.findByClient = function(clientId) {
  return this.findAll({
    where: {
      clientId,
      isActive: true,
    },
    order: [['priority', 'DESC'], ['name', 'ASC']],
  });
};

GPSBoundary.findBySite = function(siteId) {
  return this.findAll({
    where: {
      siteId,
      isActive: true,
    },
    order: [['priority', 'DESC'], ['name', 'ASC']],
  });
};

GPSBoundary.associate = function(models) {
  GPSBoundary.belongsTo(models.Client, {
    foreignKey: 'clientId',
    as: 'client',
  });
  GPSBoundary.belongsTo(models.Site, {
    foreignKey: 'siteId',
    as: 'site',
  });
};

module.exports = GPSBoundary;