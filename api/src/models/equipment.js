const { DataTypes } = require('sequelize');
const sequelize = require('../database/connection');

const Equipment = sequelize.define('Equipment', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  siteId: {
    type: DataTypes.UUID,
    allowNull: false,
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
  equipmentType: {
    type: DataTypes.STRING(50),
    allowNull: true,
  },
  serialNumber: {
    type: DataTypes.STRING(100),
    allowNull: true,
  },
  model: {
    type: DataTypes.STRING(100),
    allowNull: true,
  },
  manufacturer: {
    type: DataTypes.STRING(100),
    allowNull: true,
  },
  tags: {
    type: DataTypes.JSON,
    defaultValue: [],
    validate: {
      isArray(value) {
        if (!Array.isArray(value)) {
          throw new Error('Tags must be an array');
        }
        if (value.length > 10) {
          throw new Error('Maximum 10 tags allowed');
        }
        for (const tag of value) {
          if (typeof tag !== 'string' || tag.length > 30) {
            throw new Error('Each tag must be a string of max 30 characters');
          }
        }
      },
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
  tableName: 'equipment',
  timestamps: true,
  indexes: [
    {
      fields: ['siteId', 'name'],
    },
    {
      fields: ['equipmentType'],
    },
    {
      fields: ['serialNumber'],
    },
    {
      fields: ['isActive'],
    },
  ],
});

Equipment.prototype.toJSON = function() {
  const values = { ...this.get() };
  return values;
};

Equipment.prototype.addTag = async function(tag) {
  if (!this.tags.includes(tag)) {
    this.tags = [...this.tags, tag];
    await this.save();
  }
};

Equipment.prototype.removeTag = async function(tag) {
  this.tags = this.tags.filter(t => t !== tag);
  await this.save();
};

Equipment.prototype.hasTag = function(tag) {
  return this.tags.includes(tag);
};

Equipment.findBySite = function(siteId, includeInactive = false) {
  const where = { siteId };
  if (!includeInactive) {
    where.isActive = true;
  }
  return this.findAll({
    where,
    order: [['name', 'ASC']],
  });
};

Equipment.findByType = function(equipmentType, options = {}) {
  return this.findAll({
    where: {
      equipmentType,
      isActive: true,
    },
    ...options,
  });
};

Equipment.findByTag = async function(tag) {
  const { Op } = require('sequelize');
  return this.findAll({
    where: {
      tags: {
        [Op.contains]: [tag],
      },
      isActive: true,
    },
  });
};

Equipment.searchByName = function(searchTerm, siteId = null) {
  const { Op } = require('sequelize');
  const where = {
    name: {
      [Op.iLike]: `%${searchTerm}%`,
    },
    isActive: true,
  };
  if (siteId) {
    where.siteId = siteId;
  }
  return this.findAll({ where });
};

Equipment.associate = function(models) {
  Equipment.belongsTo(models.Site, {
    foreignKey: 'siteId',
    as: 'site',
  });
  Equipment.hasMany(models.Photo, {
    foreignKey: 'equipmentId',
    as: 'photos',
  });
  Equipment.hasMany(models.Revision, {
    foreignKey: 'equipmentId',
    as: 'revisions',
  });
};

module.exports = Equipment;