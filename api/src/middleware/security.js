const crypto = require('crypto');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const securityMiddleware = {
  headers: helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:'],
        scriptSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        fontSrc: ["'self'"],
        connectSrc: ["'self'"],
        frameSrc: ["'none'"],
        objectSrc: ["'none'"],
        upgradeInsecureRequests: process.env.NODE_ENV === 'production' ? [] : null
      }
    },
    crossOriginEmbedderPolicy: false
  }),

  cors: (req, res, next) => {
    const allowedOrigins = process.env.ALLOWED_ORIGINS
      ? process.env.ALLOWED_ORIGINS.split(',')
      : ['http://localhost:3000', 'http://localhost:8080'];

    const origin = req.headers.origin;

    if (allowedOrigins.includes(origin) || process.env.NODE_ENV === 'development') {
      res.setHeader('Access-Control-Allow-Origin', origin || '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH');
      res.setHeader('Access-Control-Allow-Headers',
        'Content-Type, Authorization, X-Device-ID, X-Company-ID, X-Request-ID');
      res.setHeader('Access-Control-Max-Age', '86400');
      res.setHeader('Access-Control-Allow-Credentials', 'true');
    }

    if (req.method === 'OPTIONS') {
      return res.sendStatus(204);
    }

    next();
  },

  rateLimits: {
    general: rateLimit({
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 100,
      message: 'Too many requests from this device, please try again later.',
      standardHeaders: true,
      legacyHeaders: false,
      keyGenerator: (req) => req.deviceId || req.ip,
      skip: (req) => process.env.NODE_ENV === 'test'
    }),

    strict: rateLimit({
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 20,
      message: 'Rate limit exceeded for this operation.',
      standardHeaders: true,
      legacyHeaders: false,
      keyGenerator: (req) => req.deviceId || req.ip,
      skip: (req) => process.env.NODE_ENV === 'test'
    }),

    upload: rateLimit({
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 100,
      message: 'Upload limit exceeded. Maximum 100 photos per hour.',
      standardHeaders: true,
      legacyHeaders: false,
      keyGenerator: (req) => req.deviceId || req.ip,
      skip: (req) => process.env.NODE_ENV === 'test',
      skipSuccessfulRequests: false
    }),

    sync: rateLimit({
      windowMs: 5 * 60 * 1000, // 5 minutes
      max: 10,
      message: 'Sync rate limit exceeded. Please wait before syncing again.',
      standardHeaders: true,
      legacyHeaders: false,
      keyGenerator: (req) => req.deviceId || req.ip,
      skip: (req) => process.env.NODE_ENV === 'test'
    })
  },

  sanitizeInput: (req, res, next) => {
    const sanitize = (obj) => {
      if (typeof obj !== 'object' || obj === null) return obj;

      for (const key in obj) {
        if (typeof obj[key] === 'string') {
          obj[key] = obj[key].trim();

          obj[key] = obj[key].replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '');

          obj[key] = obj[key].replace(/[<>]/g, (match) => {
            return match === '<' ? '&lt;' : '&gt;';
          });
        } else if (typeof obj[key] === 'object') {
          obj[key] = sanitize(obj[key]);
        }
      }

      return obj;
    };

    if (req.body) req.body = sanitize(req.body);
    if (req.query) req.query = sanitize(req.query);
    if (req.params) req.params = sanitize(req.params);

    next();
  },

  preventSqlInjection: (req, res, next) => {
    const sqlPatterns = [
      /(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|EXECUTE|UNION|FROM|WHERE|JOIN|ORDER BY|GROUP BY|HAVING)\b)/gi,
      /(--|\||;|\/\*|\*\/|xp_|sp_|0x)/gi,
      /(\bOR\b\s*\d+\s*=\s*\d+|\bAND\b\s*\d+\s*=\s*\d+)/gi
    ];

    const checkValue = (value) => {
      if (typeof value !== 'string') return false;
      return sqlPatterns.some(pattern => pattern.test(value));
    };

    const checkObject = (obj) => {
      if (!obj || typeof obj !== 'object') return false;

      for (const key in obj) {
        if (checkValue(obj[key]) || (typeof obj[key] === 'object' && checkObject(obj[key]))) {
          return true;
        }
      }
      return false;
    };

    if (checkObject(req.body) || checkObject(req.query) || checkObject(req.params)) {
      console.warn('Potential SQL injection attempt:', {
        ip: req.ip,
        deviceId: req.deviceId,
        path: req.path,
        method: req.method
      });
      return res.status(400).json({ error: 'Invalid input detected' });
    }

    next();
  },

  requestId: (req, res, next) => {
    const requestId = req.headers['x-request-id'] ||
                     crypto.randomBytes(16).toString('hex');
    req.requestId = requestId;
    res.setHeader('X-Request-ID', requestId);
    next();
  },

  logging: (req, res, next) => {
    const start = Date.now();

    res.on('finish', () => {
      const duration = Date.now() - start;
      console.log({
        timestamp: new Date().toISOString(),
        method: req.method,
        path: req.path,
        status: res.statusCode,
        duration: `${duration}ms`,
        deviceId: req.deviceId,
        requestId: req.requestId,
        ip: req.ip
      });
    });

    next();
  }
};

module.exports = securityMiddleware;