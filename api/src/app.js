import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';

const { default: photosRouter } = await import('./routes/photos.js');

// Load environment variables
dotenv.config();

const app = express();

// Security middleware
app.use(helmet());
app.use(
  cors({
    origin: process.env.CORS_ORIGIN || 'http://localhost:8080',
    credentials: true,
  }),
);

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  message: 'Too many requests from this IP',
});
app.use('/v1/', limiter);

// General middleware
app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(morgan('dev'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// API version prefix
app.get('/v1', (req, res) => {
  res.json({
    name: 'FieldPhoto Pro API',
    version: '1.0.0',
    endpoints: [
      'POST /v1/sync/changes',
      'GET /v1/sync/changes/:since',
      'POST /v1/photos',
      'GET /v1/photos',
      'GET /v1/photos/:photoId',
      'GET /v1/companies/:companyId/structure',
      'POST /v1/boundaries',
      'GET /v1/boundaries/detect/:lat/:lng',
    ],
  });
});

// API routes
app.use('/v1/photos', photosRouter);

// Error handling middleware
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: {
      message: err.message || 'Internal Server Error',
      status: err.status || 500,
    },
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: {
      message: 'Endpoint not found',
      status: 404,
    },
  });
});

export default app;
