const { DataTypes } = require('sequelize');
const sequelize = require('../database/connection');

const Company = sequelize.define('Company', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    validate: {
      notEmpty: true,
      len: [1, 100],
    },
  },
  settings: {
    type: DataTypes.JSON,
    defaultValue: {},
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
  tableName: 'companies',
  timestamps: true,
  indexes: [
    {
      fields: ['name'],
      unique: true,
    },
    {
      fields: ['isActive'],
    },
  ],
});

Company.prototype.toJSON = function() {
  const values = { ...this.get() };
  return values;
};

Company.prototype.getSetting = function(key, defaultValue = null) {
  return this.settings[key] !== undefined ? this.settings[key] : defaultValue;
};

Company.prototype.updateSetting = async function(key, value) {
  this.settings = {
    ...this.settings,
    [key]: value,
  };
  await this.save();
};

Company.prototype.removeSetting = async function(key) {
  const newSettings = { ...this.settings };
  delete newSettings[key];
  this.settings = newSettings;
  await this.save();
};

Company.prototype.getDefaultSettings = function() {
  return {
    syncEnabled: this.getSetting('syncEnabled', true),
    syncIntervalMinutes: this.getSetting('syncIntervalMinutes', 30),
    maxPhotosPerSync: this.getSetting('maxPhotosPerSync', 100),
    autoAssignByGPS: this.getSetting('autoAssignByGPS', true),
    photoQuality: this.getSetting('photoQuality', 95),
    keepOriginalPhotos: this.getSetting('keepOriginalPhotos', true),
    defaultPhotoNamingPattern: this.getSetting('defaultPhotoNamingPattern', '{equipment}_{timestamp}'),
    maxStorageGB: this.getSetting('maxStorageGB', 100),
    dataRetentionDays: this.getSetting('dataRetentionDays', null),
    allowOfflineMode: this.getSetting('allowOfflineMode', true),
  };
};

Company.findActive = function() {
  return this.findAll({
    where: { isActive: true },
    order: [['name', 'ASC']],
  });
};

Company.findByName = function(name) {
  return this.findOne({
    where: { name },
  });
};

Company.associate = function(models) {
  Company.hasMany(models.Client, {
    foreignKey: 'companyId',
    as: 'clients',
  });
  Company.hasMany(models.User, {
    foreignKey: 'companyId',
    as: 'users',
  });
};

module.exports = Company;