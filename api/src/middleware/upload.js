const multer = require('multer');
const crypto = require('crypto');
const path = require('path');
const fs = require('fs').promises;

const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
const UPLOAD_DIR = process.env.UPLOAD_DIR || './uploads';

const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const deviceId = req.deviceId || 'unknown';
    const date = new Date().toISOString().split('T')[0];
    const dir = path.join(UPLOAD_DIR, deviceId, date);

    try {
      await fs.mkdir(dir, { recursive: true });
      cb(null, dir);
    } catch (error) {
      cb(error);
    }
  },

  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + crypto.randomBytes(6).toString('hex');
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/heif',
    'image/heic',
    'image/webp'
  ];

  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only JPEG, PNG, HEIF, HEIC, and WebP are allowed.'), false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 1,
    fields: 10,
    headerPairs: 100
  }
});

const uploadMiddleware = {
  single: upload.single('file'),

  multiple: upload.array('files', 10),

  verifyHash: async (req, res, next) => {
    if (!req.file || !req.photoMetadata) {
      return next();
    }

    try {
      const filePath = req.file.path;
      const fileBuffer = await fs.readFile(filePath);
      const hash = crypto.createHash('sha256');
      hash.update(fileBuffer);
      const calculatedHash = hash.digest('hex');

      if (calculatedHash !== req.photoMetadata.fileHash) {
        await fs.unlink(filePath);
        return res.status(422).json({
          error: 'Hash mismatch',
          message: 'File integrity check failed',
          expected: req.photoMetadata.fileHash,
          received: calculatedHash
        });
      }

      req.file.hash = calculatedHash;
      next();
    } catch (error) {
      console.error('Hash verification error:', error);
      if (req.file && req.file.path) {
        try {
          await fs.unlink(req.file.path);
        } catch (unlinkError) {
          console.error('Failed to delete file after hash error:', unlinkError);
        }
      }
      res.status(500).json({ error: 'Hash verification failed' });
    }
  },

  handleMulterError: (err, req, res, next) => {
    if (err instanceof multer.MulterError) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(413).json({
          error: 'File too large',
          message: `Maximum file size is ${MAX_FILE_SIZE / (1024 * 1024)}MB`,
          maxSize: MAX_FILE_SIZE
        });
      }
      if (err.code === 'LIMIT_FILE_COUNT') {
        return res.status(400).json({
          error: 'Too many files',
          message: 'Maximum 10 files per request'
        });
      }
      if (err.code === 'LIMIT_UNEXPECTED_FILE') {
        return res.status(400).json({
          error: 'Unexpected field',
          message: 'File field name must be "file" or "files"'
        });
      }
      return res.status(400).json({
        error: 'Upload error',
        message: err.message
      });
    }

    if (err.message && err.message.includes('Invalid file type')) {
      return res.status(422).json({
        error: 'Invalid file format',
        message: err.message
      });
    }

    next(err);
  },

  cleanup: async (req, res, next) => {
    if (req.file && req.file.path) {
      const originalUnlink = res.json;
      res.json = function(data) {
        if (res.statusCode >= 400) {
          fs.unlink(req.file.path).catch(err => {
            console.error('Failed to cleanup file:', err);
          });
        }
        return originalUnlink.call(this, data);
      };
    }
    next();
  },

  ensureUploadDir: async () => {
    try {
      await fs.mkdir(UPLOAD_DIR, { recursive: true });
      const testFile = path.join(UPLOAD_DIR, '.test');
      await fs.writeFile(testFile, 'test');
      await fs.unlink(testFile);
      console.log(`Upload directory ready: ${UPLOAD_DIR}`);
    } catch (error) {
      console.error('Failed to setup upload directory:', error);
      throw error;
    }
  }
};

module.exports = uploadMiddleware;