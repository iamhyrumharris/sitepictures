const { DataTypes } = require('sequelize');
const sequelize = require('../database/connection');

const Client = sequelize.define('Client', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  companyId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'Companies',
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
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
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
  tableName: 'clients',
  timestamps: true,
  indexes: [
    {
      fields: ['companyId', 'name'],
      unique: true,
    },
    {
      fields: ['isActive'],
    },
  ],
});

Client.prototype.toJSON = function() {
  const values = { ...this.get() };
  if (this.boundaries) {
    values.boundaries = this.boundaries;
  }
  return values;
};

Client.prototype.deactivate = async function() {
  this.isActive = false;
  await this.save();
};

Client.prototype.activate = async function() {
  this.isActive = true;
  await this.save();
};

Client.findByCompany = function(companyId, includeInactive = false) {
  const where = { companyId };
  if (!includeInactive) {
    where.isActive = true;
  }
  return this.findAll({
    where,
    order: [['name', 'ASC']],
  });
};

Client.findActiveByName = function(companyId, name) {
  return this.findOne({
    where: {
      companyId,
      name,
      isActive: true,
    },
  });
};

Client.associate = function(models) {
  Client.belongsTo(models.Company, {
    foreignKey: 'companyId',
    as: 'company',
  });
  Client.hasMany(models.Site, {
    foreignKey: 'clientId',
    as: 'sites',
  });
  Client.hasMany(models.GPSBoundary, {
    foreignKey: 'clientId',
    as: 'boundaries',
  });
};

module.exports = Client;