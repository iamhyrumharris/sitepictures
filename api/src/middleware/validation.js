const validateRequest = {
  syncPackages: (req, res, next) => {
    const { deviceId, packages } = req.body;

    if (!deviceId || !packages) {
      return res.status(400).json({ error: 'Missing required fields: deviceId, packages' });
    }

    if (!Array.isArray(packages)) {
      return res.status(400).json({ error: 'Packages must be an array' });
    }

    const validOperations = ['CREATE', 'UPDATE', 'DELETE'];
    const validStatuses = ['PENDING', 'SYNCING', 'SYNCED', 'FAILED'];
    const validEntityTypes = ['Photo', 'Client', 'Site', 'Equipment', 'Revision', 'GPSBoundary'];

    for (const pkg of packages) {
      if (!pkg.entityType || !pkg.entityId || !pkg.operation || !pkg.data) {
        return res.status(400).json({ error: 'Invalid sync package format' });
      }

      if (!validOperations.includes(pkg.operation)) {
        return res.status(400).json({ error: `Invalid operation: ${pkg.operation}` });
      }

      if (!validEntityTypes.includes(pkg.entityType)) {
        return res.status(400).json({ error: `Invalid entity type: ${pkg.entityType}` });
      }

      if (pkg.status && !validStatuses.includes(pkg.status)) {
        return res.status(400).json({ error: `Invalid status: ${pkg.status}` });
      }
    }

    next();
  },

  photoUpload: (req, res, next) => {
    if (!req.file) {
      return res.status(400).json({ error: 'No photo file provided' });
    }

    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/heif', 'image/heic'];
    if (!allowedMimeTypes.includes(req.file.mimetype)) {
      return res.status(422).json({ error: 'Invalid photo format. Allowed: JPEG, PNG, HEIF' });
    }

    if (!req.body.metadata) {
      return res.status(400).json({ error: 'Photo metadata required' });
    }

    try {
      const metadata = JSON.parse(req.body.metadata);

      if (!metadata.id || !metadata.equipmentId || !metadata.fileName || !metadata.fileHash || !metadata.capturedAt || !metadata.deviceId) {
        return res.status(400).json({ error: 'Missing required metadata fields' });
      }

      const sha256Regex = /^[a-f0-9]{64}$/;
      if (!sha256Regex.test(metadata.fileHash)) {
        return res.status(400).json({ error: 'Invalid file hash format (expected SHA-256)' });
      }

      if (metadata.latitude !== undefined && metadata.latitude !== null) {
        if (metadata.latitude < -90 || metadata.latitude > 90) {
          return res.status(400).json({ error: 'Invalid latitude value' });
        }
      }

      if (metadata.longitude !== undefined && metadata.longitude !== null) {
        if (metadata.longitude < -180 || metadata.longitude > 180) {
          return res.status(400).json({ error: 'Invalid longitude value' });
        }
      }

      req.photoMetadata = metadata;
      next();
    } catch (error) {
      return res.status(400).json({ error: 'Invalid metadata JSON' });
    }
  },

  gpsCoordinates: (req, res, next) => {
    const lat = parseFloat(req.params.lat);
    const lng = parseFloat(req.params.lng);

    if (isNaN(lat) || isNaN(lng)) {
      return res.status(400).json({ error: 'Invalid GPS coordinates' });
    }

    if (lat < -90 || lat > 90) {
      return res.status(400).json({ error: 'Invalid latitude (must be -90 to 90)' });
    }

    if (lng < -180 || lng > 180) {
      return res.status(400).json({ error: 'Invalid longitude (must be -180 to 180)' });
    }

    req.coordinates = { latitude: lat, longitude: lng };
    next();
  },

  boundary: (req, res, next) => {
    const { name, centerLatitude, centerLongitude, radiusMeters, priority } = req.body;

    if (!name || centerLatitude === undefined || centerLongitude === undefined || !radiusMeters || priority === undefined) {
      return res.status(400).json({ error: 'Missing required boundary fields' });
    }

    if (centerLatitude < -90 || centerLatitude > 90) {
      return res.status(400).json({ error: 'Invalid latitude (must be -90 to 90)' });
    }

    if (centerLongitude < -180 || centerLongitude > 180) {
      return res.status(400).json({ error: 'Invalid longitude (must be -180 to 180)' });
    }

    if (radiusMeters < 1 || radiusMeters > 10000) {
      return res.status(400).json({ error: 'Invalid radius (must be 1-10000 meters)' });
    }

    if (priority < 1) {
      return res.status(400).json({ error: 'Invalid priority (must be >= 1)' });
    }

    next();
  },

  uuidParam: (paramName) => {
    return (req, res, next) => {
      const value = req.params[paramName];
      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

      if (!value || !uuidRegex.test(value)) {
        return res.status(400).json({ error: `Invalid ${paramName} format` });
      }

      next();
    };
  },

  dateParam: (paramName) => {
    return (req, res, next) => {
      const value = req.params[paramName];
      const date = new Date(value);

      if (isNaN(date.getTime())) {
        return res.status(400).json({ error: `Invalid ${paramName} format (expected ISO date-time)` });
      }

      req[`${paramName}Date`] = date;
      next();
    };
  }
};

module.exports = validateRequest;