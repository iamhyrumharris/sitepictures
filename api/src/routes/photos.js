import express from 'express';
import multer from 'multer';
import path from 'path';
import { promises as fs } from 'fs';
import crypto from 'crypto';
import { fileURLToPath } from 'url';
const { default: db } = await import('../database/connection.js');

const router = express.Router();

const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadDir = path.join(path.dirname(fileURLToPath(import.meta.url)), '../../uploads/photos');
    await fs.mkdir(uploadDir, { recursive: true });
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const ext = path.extname(file.originalname);
    cb(null, `photo-${uniqueSuffix}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: {
    fileSize: 50 * 1024 * 1024,
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|bmp|webp|heic|heif/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      cb(null, true);
    } else {
      cb(new Error('Invalid photo format. Supported formats: JPEG, PNG, GIF, BMP, WebP, HEIC'));
    }
  },
});

router.get('/', async (req, res) => {
  try {
    const pageQuery = req.query.page ?? {};
    const sizeParam = req.query['page[size]'] ?? req.query.size ?? pageQuery.size;
    const offsetParam = req.query['page[offset]'] ?? req.query.offset ?? pageQuery.offset;

    let limit = Number(sizeParam ?? 50);
    let offset = Number(offsetParam ?? 0);

    if (!Number.isFinite(limit) || limit <= 0) {
      return res.status(400).json({ error: 'page[size] must be a positive integer' });
    }

    if (limit > 100) {
      limit = 100;
    }

    if (!Number.isFinite(offset) || offset < 0) {
      return res.status(400).json({ error: 'page[offset] must be a non-negative integer' });
    }

    const countResult = await db.query(
      'SELECT COUNT(*)::int AS total FROM photos WHERE is_deleted = FALSE',
    );
    const total = countResult.rows?.[0]?.total ?? 0;

    const photoResult = await db.query(
      `SELECT
        p.id,
        p.captured_at,
        p.created_at,
        p.file_name,
        p.file_url,
        p.notes,
        e.name AS equipment_name,
        s.name AS site_name,
        parent.name AS parent_site_name,
        c.name AS client_name
      FROM photos p
      JOIN equipment e ON e.id = p.equipment_id
      JOIN sites s ON s.id = e.site_id
      LEFT JOIN sites parent ON parent.id = s.parent_site_id
      JOIN clients c ON c.id = s.client_id
      WHERE p.is_deleted = FALSE
      ORDER BY p.captured_at DESC, p.created_at DESC
      LIMIT $1 OFFSET $2`,
      [limit, offset],
    );

    const formatTimestamp = (value) => {
      if (!value) return null;
      if (value instanceof Date) return value.toISOString();
      try {
        return new Date(value).toISOString();
      } catch (error) {
        return value;
      }
    };

    const protocol = req.secure ? 'https' : 'http';
    const host = req.get('host');

    const data = photoResult.rows.map((row) => {
      const locationParts = [];
      if (row.site_name && row.parent_site_name) {
        locationParts.push(row.site_name);
      }
      if (row.parent_site_name) {
        locationParts.push(row.parent_site_name);
      } else if (row.site_name) {
        locationParts.push(row.site_name);
      }
      if (row.client_name) {
        locationParts.push(row.client_name);
      }

      const locationSummary = locationParts.filter(Boolean).join(' • ');
      const fileUrl = row.file_url ? row.file_url : `${protocol}://${host}/v1/photos/${row.id}`;

      return {
        id: row.id,
        capturedAt: formatTimestamp(row.captured_at),
        createdAt: formatTimestamp(row.created_at),
        equipmentName: row.equipment_name,
        mainSiteName: row.parent_site_name ?? row.site_name ?? null,
        subSiteName: row.parent_site_name ? row.site_name : null,
        clientName: row.client_name,
        locationSummary: locationSummary || null,
        fileName: row.file_name,
        fileUrl,
        notes: row.notes,
      };
    });

    return res.json({
      data,
      meta: {
        total,
        page: {
          size: limit,
          offset,
        },
      },
    });
  } catch (error) {
    console.error('Failed to fetch photos:', error);
    return res.status(500).json({ error: 'Failed to fetch photos' });
  }
});

router.post('/', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

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

    const fileBuffer = await fs.readFile(req.file.path);
    const hash = crypto.createHash('sha256');
    hash.update(fileBuffer);
    const fileHash = hash.digest('hex');

    const photoData = {
      id: metadata.id || crypto.randomUUID(),
      equipmentId: metadata.equipmentId,
      revisionId: metadata.revisionId || null,
      fileName: req.file.filename,
      fileHash,
      latitude: metadata.latitude || null,
      longitude: metadata.longitude || null,
      capturedAt: metadata.capturedAt ? new Date(metadata.capturedAt) : new Date(),
      notes: metadata.notes || null,
      deviceId: req.headers['x-device-id'] || metadata.deviceId,
      createdAt: new Date(),
      updatedAt: new Date(),
      isSynced: true,
    };

    if (!photoData.equipmentId) {
      await fs.unlink(req.file.path);
      return res.status(400).json({ error: 'equipmentId is required' });
    }

    if (!photoData.deviceId) {
      await fs.unlink(req.file.path);
      return res.status(400).json({ error: 'deviceId is required' });
    }

    await db.query(
      `INSERT INTO photos (
        id,
        equipment_id,
        revision_id,
        file_name,
        file_hash,
        latitude,
        longitude,
        captured_at,
        notes,
        device_id,
        file_url,
        created_at,
        updated_at,
        is_synced
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, NOW(), NOW(), true)`,
      [
        photoData.id,
        photoData.equipmentId,
        photoData.revisionId,
        photoData.fileName,
        photoData.fileHash,
        photoData.latitude,
        photoData.longitude,
        photoData.capturedAt,
        photoData.notes,
        photoData.deviceId,
        null,
      ],
    );

    const protocol = req.secure ? 'https' : 'http';
    const host = req.get('host');
    const downloadUrl = `${protocol}://${host}/v1/photos/${photoData.id}`;

    res.status(201).json({
      photoId: photoData.id,
      downloadUrl,
    });
  } catch (error) {
    console.error('Photo upload error:', error);

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

router.get('/:photoId', async (req, res) => {
  try {
    const { photoId } = req.params;
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(photoId)) {
      return res.status(400).json({ error: 'Invalid photo ID format' });
    }

    const photoResult = await db.query(
      `SELECT file_name FROM photos WHERE id = $1`,
      [photoId],
    );

    if (photoResult.rows.length === 0) {
      return res.status(404).json({ error: 'Photo not found' });
    }

    const photo = photoResult.rows[0];

    const filePath = path.join(
      path.dirname(fileURLToPath(import.meta.url)),
      '../../uploads/photos',
      photo.file_name,
    );

    try {
      await fs.access(filePath);
    } catch (error) {
      console.error('Photo file not found:', filePath);
      return res.status(404).json({ error: 'Photo file not found' });
    }

    res.download(filePath, photo.file_name);
  } catch (error) {
    console.error('Failed to download photo:', error);
    res.status(500).json({ error: 'Failed to download photo' });
  }
});

export default router;
