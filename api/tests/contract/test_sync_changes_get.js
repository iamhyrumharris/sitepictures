import request from 'supertest';
import { describe, it, expect, beforeAll, afterAll } from '@jest/globals';

// This will fail initially - endpoint not implemented yet
describe('GET /v1/sync/changes/:since', () => {
  let app;

  beforeAll(async () => {
    // App will be imported once implemented
    // app = await import('../../src/index.js');
  });

  afterAll(async () => {
    // Cleanup
  });

  it('should return changes since timestamp', async () => {
    const since = new Date(Date.now() - 3600000).toISOString(); // 1 hour ago
    const deviceId = '123e4567-e89b-12d3-a456-426614174000';

    const response = await request(app)
      .get(`/v1/sync/changes/${since}`)
      .query({ deviceId })
      .set('X-Device-ID', deviceId);

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('changes');
    expect(response.body).toHaveProperty('lastModified');
    expect(Array.isArray(response.body.changes)).toBe(true);
  });

  it('should exclude changes from requesting device', async () => {
    const since = new Date(Date.now() - 3600000).toISOString();
    const deviceId = '123e4567-e89b-12d3-a456-426614174000';

    const response = await request(app)
      .get(`/v1/sync/changes/${since}`)
      .query({ deviceId })
      .set('X-Device-ID', deviceId);

    expect(response.status).toBe(200);
    const ownChanges = response.body.changes.filter(c => c.deviceId === deviceId);
    expect(ownChanges.length).toBe(0);
  });

  it('should handle invalid timestamp format', async () => {
    const response = await request(app)
      .get('/v1/sync/changes/invalid-timestamp')
      .query({ deviceId: '123e4567-e89b-12d3-a456-426614174000' })
      .set('X-Device-ID', '123e4567-e89b-12d3-a456-426614174000');

    expect(response.status).toBe(400);
  });

  it('should require deviceId parameter', async () => {
    const since = new Date().toISOString();

    const response = await request(app)
      .get(`/v1/sync/changes/${since}`)
      .set('X-Device-ID', '123e4567-e89b-12d3-a456-426614174000');

    expect(response.status).toBe(400);
  });

  it('should return empty array for future timestamp', async () => {
    const future = new Date(Date.now() + 3600000).toISOString(); // 1 hour in future
    const deviceId = '123e4567-e89b-12d3-a456-426614174000';

    const response = await request(app)
      .get(`/v1/sync/changes/${future}`)
      .query({ deviceId })
      .set('X-Device-ID', deviceId);

    expect(response.status).toBe(200);
    expect(response.body.changes).toEqual([]);
  });
});