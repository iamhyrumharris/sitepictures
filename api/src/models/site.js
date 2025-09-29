const { DataTypes } = require('sequelize');
const sequelize = require('../database/connection');

const Site = sequelize.define('Site', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  clientId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'Clients',
      key: 'id',
    },
  },
  parentSiteId: {
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
  address: {
    type: DataTypes.STRING(500),
    allowNull: true,
  },
  centerLatitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true,
    validate: {
      min: -90,
      max: 90,
    },
  },
  centerLongitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true,
    validate: {
      min: -180,
      max: 180,
    },
  },
  boundaryRadius: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true,
    validate: {
      min: 0,
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
  tableName: 'sites',
  timestamps: true,
  indexes: [
    {
      fields: ['clientId', 'name'],
    },
    {
      fields: ['parentSiteId'],
    },
    {
      fields: ['isActive'],
    },
  ],
});

Site.prototype.toJSON = function() {
  const values = { ...this.get() };
  return values;
};

Site.prototype.isMainSite = function() {
  return this.parentSiteId === null;
};

Site.prototype.isSubSite = function() {
  return this.parentSiteId !== null;
};

Site.prototype.containsLocation = function(latitude, longitude) {
  if (!this.centerLatitude || !this.centerLongitude || !this.boundaryRadius) {
    return false;
  }

  const distance = this.calculateDistance(
    this.centerLatitude,
    this.centerLongitude,
    latitude,
    longitude
  );
  return distance <= this.boundaryRadius;
};

Site.prototype.calculateDistance = function(lat1, lon1, lat2, lon2) {
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

Site.findByClient = function(clientId, includeInactive = false) {
  const where = { clientId };
  if (!includeInactive) {
    where.isActive = true;
  }
  return this.findAll({
    where,
    order: [['parentSiteId', 'ASC'], ['name', 'ASC']],
  });
};

Site.findMainSites = function(clientId) {
  return this.findAll({
    where: {
      clientId,
      parentSiteId: null,
      isActive: true,
    },
    order: [['name', 'ASC']],
  });
};

Site.findSubSites = function(parentSiteId) {
  return this.findAll({
    where: {
      parentSiteId,
      isActive: true,
    },
    order: [['name', 'ASC']],
  });
};

Site.associate = function(models) {
  Site.belongsTo(models.Client, {
    foreignKey: 'clientId',
    as: 'client',
  });
  Site.belongsTo(models.Site, {
    foreignKey: 'parentSiteId',
    as: 'parentSite',
  });
  Site.hasMany(models.Site, {
    foreignKey: 'parentSiteId',
    as: 'subSites',
  });
  Site.hasMany(models.Equipment, {
    foreignKey: 'siteId',
    as: 'equipment',
  });
};

module.exports = Site;