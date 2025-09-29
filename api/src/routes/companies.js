const express = require('express');
const router = express.Router();
const Company = require('../models/company');
const Client = require('../models/client');
const Site = require('../models/site');
const Equipment = require('../models/equipment');

// T047: GET /companies/{companyId}/structure - Get company organizational structure
router.get('/:companyId/structure', async (req, res) => {
  try {
    const { companyId } = req.params;

    // Validate UUID format
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(companyId)) {
      return res.status(400).json({ error: 'Invalid company ID format' });
    }

    // Get company details
    const company = await Company.findById(companyId);

    if (!company) {
      return res.status(404).json({ error: 'Company not found' });
    }

    // Get all clients for the company
    const clients = await Client.findByCompanyId(companyId);

    // Build complete hierarchical structure
    const structure = {
      company: {
        id: company.id,
        name: company.name,
        settings: company.settings || {},
        createdAt: company.createdAt,
        updatedAt: company.updatedAt
      },
      clients: []
    };

    // For each client, get sites and equipment
    for (const client of clients) {
      if (!client.isActive) continue; // Skip soft-deleted clients

      const clientData = {
        id: client.id,
        name: client.name,
        description: client.description,
        boundaries: client.boundaries || [],
        sites: []
      };

      // Get all sites for this client
      const sites = await Site.findByClientId(client.id);

      // Build site hierarchy (main sites and sub-sites)
      const mainSites = sites.filter(s => !s.parentSiteId && s.isActive);

      for (const mainSite of mainSites) {
        const siteData = {
          id: mainSite.id,
          name: mainSite.name,
          address: mainSite.address,
          parentSiteId: null,
          centerLatitude: mainSite.centerLatitude,
          centerLongitude: mainSite.centerLongitude,
          boundaryRadius: mainSite.boundaryRadius,
          subSites: [],
          equipment: []
        };

        // Get sub-sites
        const subSites = sites.filter(s => s.parentSiteId === mainSite.id && s.isActive);

        for (const subSite of subSites) {
          const subSiteData = {
            id: subSite.id,
            name: subSite.name,
            address: subSite.address,
            parentSiteId: subSite.parentSiteId,
            centerLatitude: subSite.centerLatitude,
            centerLongitude: subSite.centerLongitude,
            boundaryRadius: subSite.boundaryRadius,
            equipment: []
          };

          // Get equipment for sub-site
          const subSiteEquipment = await Equipment.findBySiteId(subSite.id);
          subSiteData.equipment = subSiteEquipment
            .filter(e => e.isActive)
            .map(e => ({
              id: e.id,
              name: e.name,
              equipmentType: e.equipmentType,
              serialNumber: e.serialNumber,
              model: e.model,
              manufacturer: e.manufacturer,
              tags: e.tags || []
            }));

          siteData.subSites.push(subSiteData);
        }

        // Get equipment for main site (not in sub-sites)
        const mainSiteEquipment = await Equipment.findBySiteId(mainSite.id);
        siteData.equipment = mainSiteEquipment
          .filter(e => e.isActive)
          .map(e => ({
            id: e.id,
            name: e.name,
            equipmentType: e.equipmentType,
            serialNumber: e.serialNumber,
            model: e.model,
            manufacturer: e.manufacturer,
            tags: e.tags || []
          }));

        clientData.sites.push(siteData);
      }

      structure.clients.push(clientData);
    }

    // Add statistics
    structure.statistics = {
      totalClients: structure.clients.length,
      totalSites: structure.clients.reduce((sum, c) =>
        sum + c.sites.length + c.sites.reduce((subSum, s) =>
          subSum + (s.subSites ? s.subSites.length : 0), 0), 0),
      totalEquipment: structure.clients.reduce((sum, c) =>
        sum + c.sites.reduce((siteSum, s) =>
          siteSum + s.equipment.length +
          (s.subSites ? s.subSites.reduce((subSum, ss) =>
            subSum + ss.equipment.length, 0) : 0), 0), 0)
    };

    res.json(structure);

  } catch (error) {
    console.error('Error fetching company structure:', error);
    res.status(500).json({ error: 'Failed to retrieve company structure' });
  }
});

// Additional endpoints for company management
router.get('/:companyId', async (req, res) => {
  try {
    const { companyId } = req.params;

    const company = await Company.findById(companyId);

    if (!company) {
      return res.status(404).json({ error: 'Company not found' });
    }

    res.json(company);

  } catch (error) {
    console.error('Error fetching company:', error);
    res.status(500).json({ error: 'Failed to retrieve company' });
  }
});

router.put('/:companyId/settings', async (req, res) => {
  try {
    const { companyId } = req.params;
    const { settings } = req.body;

    if (!settings || typeof settings !== 'object') {
      return res.status(400).json({ error: 'Invalid settings format' });
    }

    const company = await Company.findById(companyId);

    if (!company) {
      return res.status(404).json({ error: 'Company not found' });
    }

    // Merge with existing settings
    const updatedSettings = {
      ...company.settings,
      ...settings
    };

    await Company.updateSettings(companyId, updatedSettings);

    res.json({
      message: 'Settings updated successfully',
      settings: updatedSettings
    });

  } catch (error) {
    console.error('Error updating company settings:', error);
    res.status(500).json({ error: 'Failed to update settings' });
  }
});

module.exports = router;