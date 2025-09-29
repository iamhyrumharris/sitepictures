import request from 'supertest';
import { describe, it, expect, beforeAll, afterAll } from '@jest/globals';
import fs from 'fs';
import path from 'path';

// This will fail initially - endpoint not implemented yet
describe('POST /v1/photos', () => {
  let app;
  const testPhotoPath = path.join(__dirname, 'test-photo.jpg');

  beforeAll(async () => {
    // App will be imported once implemented
    // app = await import('../../src/index.js');

    // Create a test photo file
    const buffer = Buffer.alloc(1024); // 1KB test file
    fs.writeFileSync(testPhotoPath, buffer);
  });

  afterAll(async () => {
    // Cleanup test file
    if (fs.existsSync(testPhotoPath)) {
      fs.unlinkSync(testPhotoPath);
    }
  });

  it('should upload photo with metadata', async () => {
    const metadata = {
      id: '789e4567-e89b-12d3-a456-426614174002',
      equipmentId: '012e4567-e89b-12d3-a456-426614174003',
      fileName: 'IMG_001.jpg',
      fileHash: 'a'.repeat(64),
      capturedAt: new Date().toISOString(),
      latitude: 42.3601,
      longitude: -71.0589,
      notes: 'Control panel before modification',
      deviceId: '123e4567-e89b-12d3-a456-426614174000'
    };

    const response = await request(app)
      .post('/v1/photos')
      .set('X-Device-ID', '123e4567-e89b-12d3-a456-426614174000')
      .attach('file', testPhotoPath)
      .field('metadata', JSON.stringify(metadata));

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('photoId');
    expect(response.body).toHaveProperty('downloadUrl');
  });

  it('should reject oversized photos', async () => {
    // Create large test file (over typical limit)
    const largePhotoPath = path.join(__dirname, 'large-photo.jpg');
    const largeBuffer = Buffer.alloc(100 * 1024 * 1024); // 100MB
    fs.writeFileSync(largePhotoPath, largeBuffer);

    try {
      const response = await request(app)
        .post('/v1/photos')
        .set('X-Device-ID', '123e4567-e89b-12d3-a456-426614174000')
        .attach('file', largePhotoPath)
        .field('metadata', JSON.stringify({ equipmentId: 'test' }));

      expect(response.status).toBe(413);
    } finally {
      fs.unlinkSync(largePhotoPath);
    }
  });

  it('should validate metadata format', async () => {
    const invalidMetadata = {
      equipmentId: 'not-a-uuid',
      fileName: '',
      capturedAt: 'invalid-date'
    };

    const response = await request(app)
      .post('/v1/photos')
      .set('X-Device-ID', '123e4567-e89b-12d3-a456-426614174000')
      .attach('file', testPhotoPath)
      .field('metadata', JSON.stringify(invalidMetadata));

    expect(response.status).toBe(422);
  });

  it('should require device authentication', async () => {
    const response = await request(app)
      .post('/v1/photos')
      .attach('file', testPhotoPath)
      .field('metadata', JSON.stringify({ equipmentId: 'test' }));

    expect(response.status).toBe(401);
  });

  it('should handle missing file', async () => {
    const metadata = {
      equipmentId: '012e4567-e89b-12d3-a456-426614174003',
      fileName: 'IMG_001.jpg'
    };

    const response = await request(app)
      .post('/v1/photos')
      .set('X-Device-ID', '123e4567-e89b-12d3-a456-426614174000')
      .field('metadata', JSON.stringify(metadata));

    expect(response.status).toBe(400);
  });
});