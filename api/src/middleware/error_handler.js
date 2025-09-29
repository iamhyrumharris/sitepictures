const errorHandler = {
  notFound: (req, res, next) => {
    res.status(404).json({
      error: 'Not Found',
      message: `Route ${req.method} ${req.path} not found`,
      path: req.path,
      method: req.method
    });
  },

  asyncHandler: (fn) => {
    return (req, res, next) => {
      Promise.resolve(fn(req, res, next)).catch(next);
    };
  },

  globalErrorHandler: (err, req, res, next) => {
    // Sanitize sensitive data before logging
    const sanitizedBody = req.body ? { ...req.body } : {};
    if (sanitizedBody.password) sanitizedBody.password = '[REDACTED]';
    if (sanitizedBody.token) sanitizedBody.token = '[REDACTED]';
    if (sanitizedBody.apiKey) sanitizedBody.apiKey = '[REDACTED]';

    console.error('Error:', {
      message: err.message,
      stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
      path: req.path,
      method: req.method,
      body: process.env.NODE_ENV === 'development' ? sanitizedBody : undefined,
      query: req.query,
      params: req.params,
      deviceId: req.deviceId
    });

    if (res.headersSent) {
      return next(err);
    }

    if (err.name === 'ValidationError') {
      return res.status(400).json({
        error: 'Validation Error',
        message: err.message,
        details: err.errors || {}
      });
    }

    if (err.name === 'UnauthorizedError') {
      return res.status(401).json({
        error: 'Unauthorized',
        message: err.message || 'Authentication required'
      });
    }

    if (err.code === '23505') {
      return res.status(409).json({
        error: 'Conflict',
        message: 'Resource already exists',
        field: err.detail
      });
    }

    if (err.code === '23503') {
      return res.status(400).json({
        error: 'Foreign Key Violation',
        message: 'Referenced resource does not exist',
        detail: err.detail
      });
    }

    if (err.code === '22P02') {
      return res.status(400).json({
        error: 'Invalid Input',
        message: 'Invalid UUID format',
        detail: err.detail
      });
    }

    if (err.code === 'ECONNREFUSED') {
      return res.status(503).json({
        error: 'Service Unavailable',
        message: 'Database connection failed',
        retryAfter: 30
      });
    }

    if (err.type === 'entity.too.large') {
      return res.status(413).json({
        error: 'Payload Too Large',
        message: 'Request entity too large',
        maxSize: err.limit
      });
    }

    const statusCode = err.statusCode || err.status || 500;
    const message = err.message || 'Internal Server Error';

    res.status(statusCode).json({
      error: statusCode === 500 ? 'Internal Server Error' : 'Error',
      message: statusCode === 500 && process.env.NODE_ENV === 'production'
        ? 'An error occurred processing your request'
        : message,
      ...(process.env.NODE_ENV === 'development' && {
        stack: err.stack,
        details: err
      })
    });
  },

  handleDatabaseError: (error, entity) => {
    const err = new Error();

    if (error.code === '23505') {
      err.statusCode = 409;
      err.message = `${entity} already exists`;
    } else if (error.code === '23503') {
      err.statusCode = 400;
      err.message = `Invalid reference in ${entity}`;
    } else if (error.code === '23502') {
      err.statusCode = 400;
      err.message = `Missing required field in ${entity}`;
    } else {
      err.statusCode = 500;
      err.message = `Database error while processing ${entity}`;
    }

    err.originalError = error;
    return err;
  },

  createError: (statusCode, message, details = {}) => {
    const err = new Error(message);
    err.statusCode = statusCode;
    err.details = details;
    return err;
  }
};

module.exports = errorHandler;