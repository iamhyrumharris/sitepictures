const express = require('express');
const router = express.Router();
const GPSBoundary = require('../models/gps_boundary');

// T048: POST /boundaries - Create GPS boundary
router.post('/', async (req, res) => {
  try {
    const boundaryData = req.body;

    // Validate required fields
    const requiredFields = ['name', 'centerLatitude', 'centerLongitude', 'radiusMeters', 'priority'];
    const missingFields = requiredFields.filter(field => !boundaryData.hasOwnProperty(field));

    if (missingFields.length > 0) {
      return res.status(400).json({
        error: `Missing required fields: ${missingFields.join(', ')}`
      });
    }

    // Validate GPS coordinates
    if (boundaryData.centerLatitude < -90 || boundaryData.centerLatitude > 90) {
      return res.status(400).json({
        error: 'Invalid latitude. Must be between -90 and 90'
      });
    }

    if (boundaryData.centerLongitude < -180 || boundaryData.centerLongitude > 180) {
      return res.status(400).json({
        error: 'Invalid longitude. Must be between -180 and 180'
      });
    }

    // Validate radius
    if (boundaryData.radiusMeters < 1 || boundaryData.radiusMeters > 10000) {
      return res.status(400).json({
        error: 'Invalid radius. Must be between 1 and 10000 meters'
      });
    }

    // Validate priority
    if (boundaryData.priority < 1) {
      return res.status(400).json({
        error: 'Invalid priority. Must be a positive integer'
      });
    }

    // Validate name length
    if (!boundaryData.name || boundaryData.name.length > 100) {
      return res.status(400).json({
        error: 'Invalid name. Must be 1-100 characters'
      });
    }

    // Generate ID if not provided
    if (!boundaryData.id) {
      boundaryData.id = require('crypto').randomUUID();
    }

    // Set timestamps
    const now = new Date();
    boundaryData.createdAt = now;
    boundaryData.updatedAt = now;
    boundaryData.isActive = boundaryData.isActive !== false; // Default to true

    // Create boundary
    const createdBoundary = await GPSBoundary.create(boundaryData);

    res.status(201).json(createdBoundary);

  } catch (error) {
    console.error('Error creating boundary:', error);

    if (error.code === 'UNIQUE_VIOLATION') {
      return res.status(409).json({
        error: 'A boundary with this ID already exists'
      });
    }

    res.status(500).json({ error: 'Failed to create boundary' });
  }
});

// T049: GET /boundaries/detect/{lat}/{lng} - Detect boundaries at location
router.get('/detect/:lat/:lng', async (req, res) => {
  try {
    const lat = parseFloat(req.params.lat);
    const lng = parseFloat(req.params.lng);
    const { companyId } = req.query;

    // Validate coordinates
    if (isNaN(lat) || lat < -90 || lat > 90) {
      return res.status(400).json({
        error: 'Invalid latitude. Must be between -90 and 90'
      });
    }

    if (isNaN(lng) || lng < -180 || lng > 180) {
      return res.status(400).json({
        error: 'Invalid longitude. Must be between -180 and 180'
      });
    }

    if (!companyId) {
      return res.status(400).json({
        error: 'companyId query parameter is required'
      });
    }

    // Get all boundaries for the company
    const boundaries = await GPSBoundary.findByCompanyId(companyId);

    // Calculate which boundaries contain the point
    const matches = [];

    for (const boundary of boundaries) {
      if (!boundary.isActive) continue;

      // Calculate distance from point to boundary center using Haversine formula
      const distance = calculateHaversineDistance(
        lat, lng,
        boundary.centerLatitude, boundary.centerLongitude
      );

      // Check if point is within boundary radius
      if (distance <= boundary.radiusMeters) {
        matches.push({
          boundary: boundary,
          distance: Math.round(distance),
          confidence: Math.max(0, Math.min(1, 1 - (distance / boundary.radiusMeters)))
        });
      }
    }

    // Sort by priority (higher priority first), then by distance (closer first)
    matches.sort((a, b) => {
      if (a.boundary.priority !== b.boundary.priority) {
        return b.boundary.priority - a.boundary.priority;
      }
      return a.distance - b.distance;
    });

    res.json(matches);

  } catch (error) {
    console.error('Error detecting boundaries:', error);
    res.status(500).json({ error: 'Failed to detect boundaries' });
  }
});

// Additional endpoints for boundary management
router.get('/', async (req, res) => {
  try {
    const { companyId, clientId, siteId } = req.query;

    let boundaries;

    if (clientId) {
      boundaries = await GPSBoundary.findByClientId(clientId);
    } else if (siteId) {
      boundaries = await GPSBoundary.findBySiteId(siteId);
    } else if (companyId) {
      boundaries = await GPSBoundary.findByCompanyId(companyId);
    } else {
      return res.status(400).json({
        error: 'Must provide companyId, clientId, or siteId query parameter'
      });
    }

    res.json(boundaries.filter(b => b.isActive));

  } catch (error) {
    console.error('Error fetching boundaries:', error);
    res.status(500).json({ error: 'Failed to retrieve boundaries' });
  }
});

router.put('/:boundaryId', async (req, res) => {
  try {
    const { boundaryId } = req.params;
    const updateData = req.body;

    // Remove immutable fields
    delete updateData.id;
    delete updateData.createdAt;

    // Validate if provided
    if (updateData.centerLatitude !== undefined) {
      if (updateData.centerLatitude < -90 || updateData.centerLatitude > 90) {
        return res.status(400).json({
          error: 'Invalid latitude. Must be between -90 and 90'
        });
      }
    }

    if (updateData.centerLongitude !== undefined) {
      if (updateData.centerLongitude < -180 || updateData.centerLongitude > 180) {
        return res.status(400).json({
          error: 'Invalid longitude. Must be between -180 and 180'
        });
      }
    }

    if (updateData.radiusMeters !== undefined) {
      if (updateData.radiusMeters < 1 || updateData.radiusMeters > 10000) {
        return res.status(400).json({
          error: 'Invalid radius. Must be between 1 and 10000 meters'
        });
      }
    }

    updateData.updatedAt = new Date();

    const updatedBoundary = await GPSBoundary.update(boundaryId, updateData);

    if (!updatedBoundary) {
      return res.status(404).json({ error: 'Boundary not found' });
    }

    res.json(updatedBoundary);

  } catch (error) {
    console.error('Error updating boundary:', error);
    res.status(500).json({ error: 'Failed to update boundary' });
  }
});

router.delete('/:boundaryId', async (req, res) => {
  try {
    const { boundaryId } = req.params;

    // Soft delete
    const deleted = await GPSBoundary.softDelete(boundaryId);

    if (!deleted) {
      return res.status(404).json({ error: 'Boundary not found' });
    }

    res.json({ message: 'Boundary deleted successfully' });

  } catch (error) {
    console.error('Error deleting boundary:', error);
    res.status(500).json({ error: 'Failed to delete boundary' });
  }
});

// Helper function: Calculate Haversine distance between two GPS points
function calculateHaversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371000; // Earth's radius in meters
  const phi1 = lat1 * Math.PI / 180;
  const phi2 = lat2 * Math.PI / 180;
  const deltaPhi = (lat2 - lat1) * Math.PI / 180;
  const deltaLambda = (lon2 - lon1) * Math.PI / 180;

  const a = Math.sin(deltaPhi / 2) * Math.sin(deltaPhi / 2) +
            Math.cos(phi1) * Math.cos(phi2) *
            Math.sin(deltaLambda / 2) * Math.sin(deltaLambda / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c; // Distance in meters
}

module.exports = router;