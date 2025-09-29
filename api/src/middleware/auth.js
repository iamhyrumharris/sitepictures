const auth = {
  deviceAuth: (req, res, next) => {
    const deviceId = req.headers['x-device-id'];

    if (!deviceId) {
      return res.status(401).json({ error: 'Device ID required' });
    }

    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(deviceId)) {
      return res.status(401).json({ error: 'Invalid device ID format' });
    }

    req.deviceId = deviceId;
    req.auth = { type: 'device', id: deviceId };

    next();
  },

  optionalDeviceAuth: (req, res, next) => {
    const deviceId = req.headers['x-device-id'];

    if (deviceId) {
      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
      if (uuidRegex.test(deviceId)) {
        req.deviceId = deviceId;
        req.auth = { type: 'device', id: deviceId };
      }
    }

    next();
  },

  requireCompany: async (req, res, next) => {
    if (!req.deviceId) {
      return res.status(401).json({ error: 'Device authentication required' });
    }

    try {
      const db = req.app.get('db');
      const result = await db.query(
        'SELECT company_id FROM users WHERE id = $1 AND is_active = true',
        [req.deviceId]
      );

      if (result.rows.length === 0) {
        return res.status(403).json({ error: 'Device not registered' });
      }

      if (!result.rows[0].company_id) {
        return res.status(403).json({ error: 'Device not associated with company' });
      }

      req.companyId = result.rows[0].company_id;
      next();
    } catch (error) {
      console.error('Company verification error:', error);
      res.status(500).json({ error: 'Authentication error' });
    }
  }
};

module.exports = auth;