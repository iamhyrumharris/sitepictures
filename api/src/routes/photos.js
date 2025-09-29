const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const crypto = require('crypto');
const Photo = require('../models/photo');

// Configure multer for photo uploads
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../../uploads/photos');
    await fs.mkdir(uploadDir, { recursive: true });
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, `photo-${uniqueSuffix}${ext}`);
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 50 * 1024 * 1024 // 50MB max file size
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|bmp|webp|heic|heif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Invalid photo format. Supported formats: JPEG, PNG, GIF, BMP, WebP, HEIC'));
    }
  }
});

// T045: POST /photos - Upload photo file
router.post('/', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    // Parse metadata from request
    let metadata = {};
    if (req.body.metadata) {
      try {
        metadata = typeof req.body.metadata === 'string'
          ? JSON.parse(req.body.metadata)
          : req.body.metadata;
      } catch (e) {
        return res.status(400).json({ error: 'Invalid metadata format' });
      }
    }

    // Calculate file hash
    const fileBuffer = await fs.readFile(req.file.path);
    const hash = crypto.createHash('sha256');
    hash.update(fileBuffer);
    const fileHash = hash.digest('hex');

    // Create photo record with metadata
    const photoData = {
      id: metadata.id || crypto.randomUUID(),
      equipmentId: metadata.equipmentId,
      revisionId: metadata.revisionId || null,
      fileName: req.file.filename,
      fileHash: fileHash,
      latitude: metadata.latitude || null,
      longitude: metadata.longitude || null,
      capturedAt: metadata.capturedAt ? new Date(metadata.capturedAt) : new Date(),
      notes: metadata.notes || null,
      deviceId: req.headers['x-device-id'] || metadata.deviceId,
      createdAt: new Date(),
      updatedAt: new Date(),
      isSynced: true
    };

    // Validate required fields
    if (!photoData.equipmentId) {
      // Clean up uploaded file
      await fs.unlink(req.file.path);
      return res.status(400).json({ error: 'equipmentId is required' });
    }

    if (!photoData.deviceId) {
      // Clean up uploaded file
      await fs.unlink(req.file.path);
      return res.status(400).json({ error: 'deviceId is required' });
    }

    // Save to database
    await Photo.create(photoData);

    // Generate download URL
    const protocol = req.secure ? 'https' : 'http';
    const host = req.get('host');
    const downloadUrl = `${protocol}://${host}/v1/photos/${photoData.id}`;

    res.status(201).json({
      photoId: photoData.id,
      downloadUrl: downloadUrl
    });

  } catch (error) {
    console.error('Photo upload error:', error);

    // Clean up file if it was uploaded
    if (req.file) {
      try {
        await fs.unlink(req.file.path);
      } catch (unlinkError) {
        console.error('Failed to clean up file:', unlinkError);
      }
    }

    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(413).json({ error: 'Photo file too large (max 50MB)' });
    }

    if (error.message && error.message.includes('Invalid photo format')) {
      return res.status(422).json({ error: error.message });
    }

    res.status(500).json({ error: 'Failed to upload photo' });
  }
});

// T046: GET /photos/{photoId} - Download photo file
router.get('/:photoId', async (req, res) => {
  try {
    const { photoId } = req.params;

    // Validate UUID format
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(photoId)) {
      return res.status(400).json({ error: 'Invalid photo ID format' });
    }

    // Get photo metadata from database
    const photo = await Photo.findById(photoId);

    if (!photo) {
      return res.status(404).json({ error: 'Photo not found' });
    }

    // Build file path
    const filePath = path.join(__dirname, '../../uploads/photos', photo.fileName);

    // Check if file exists
    try {
      await fs.access(filePath);
    } catch (error) {
      console.error('Photo file not found:', filePath);
      return res.status(404).json({ error: 'Photo file not found' });
    }

    // Determine content type from file extension
    const ext = path.extname(photo.fileName).toLowerCase();
    const contentTypes = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.bmp': 'image/bmp',
      '.webp': 'image/webp',
      '.heic': 'image/heic',
      '.heif': 'image/heif'
    };

    const contentType = contentTypes[ext] || 'application/octet-stream';

    // Set response headers
    res.set({
      'Content-Type': contentType,
      'Content-Disposition': `inline; filename="${photo.fileName}"`,
      'Cache-Control': 'public, max-age=31536000', // Cache for 1 year
      'ETag': photo.fileHash
    });

    // Stream the file to response
    const fileStream = require('fs').createReadStream(filePath);
    fileStream.pipe(res);

  } catch (error) {
    console.error('Photo retrieval error:', error);
    res.status(500).json({ error: 'Failed to retrieve photo' });
  }
});

// Additional endpoint for photo metadata
router.get('/:photoId/metadata', async (req, res) => {
  try {
    const { photoId } = req.params;

    const photo = await Photo.findById(photoId);

    if (!photo) {
      return res.status(404).json({ error: 'Photo not found' });
    }

    res.json(photo);

  } catch (error) {
    console.error('Metadata retrieval error:', error);
    res.status(500).json({ error: 'Failed to retrieve photo metadata' });
  }
});

module.exports = router;