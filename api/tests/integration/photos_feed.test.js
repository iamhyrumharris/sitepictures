import request from 'supertest';
import { jest } from '@jest/globals';

const queryMock = jest.fn();

jest.unstable_mockModule('../../src/database/connection.js', () => ({
  default: { query: queryMock },
  query: queryMock,
}));

const { default: app } = await import('../../src/app.js');
const dbModule = await import('../../src/database/connection.js');
const db = dbModule.default || dbModule;

describe('GET /v1/photos', () => {
  beforeEach(() => {
    queryMock.mockReset();
  });

  it('returns paginated photo metadata', async () => {
    queryMock
      .mockResolvedValueOnce({ rows: [{ total: 2 }] })
      .mockResolvedValueOnce({
        rows: [
          {
            id: 'photo-1',
            captured_at: new Date('2025-01-10T12:00:00Z'),
            created_at: new Date('2025-01-10T12:05:00Z'),
            file_name: 'photo-1.jpg',
            file_url: null,
            notes: 'Inspection',
            equipment_name: 'Generator A',
            site_name: 'Assembly Line',
            parent_site_name: 'Factory North',
            client_name: 'ACME Industrial',
          },
        ],
      });

    const response = await request(app).get('/v1/photos').expect(200);

    expect(queryMock).toHaveBeenCalledTimes(2);
    expect(response.body.meta).toEqual({
      total: 2,
      page: {
        size: 50,
        offset: 0,
      },
    });
    expect(response.body.data).toHaveLength(1);
    expect(response.body.data[0]).toMatchObject({
      id: 'photo-1',
      equipmentName: 'Generator A',
      mainSiteName: 'Factory North',
      subSiteName: 'Assembly Line',
      clientName: 'ACME Industrial',
      locationSummary: 'Assembly Line • Factory North • ACME Industrial',
    });
    expect(response.body.data[0].fileUrl).toContain('/v1/photos/photo-1');
  });

  it('clamps page size to maximum', async () => {
    queryMock
      .mockResolvedValueOnce({ rows: [{ total: 0 }] })
      .mockResolvedValueOnce({ rows: [] });

    await request(app).get('/v1/photos?page[size]=999').expect(200);

    const [, lastCall] = queryMock.mock.calls;
    expect(lastCall[1]).toEqual([100, 0]);
  });

  it('rejects invalid pagination params', async () => {
    await request(app).get('/v1/photos?page[size]=-1').expect(400);
    await request(app).get('/v1/photos?page[offset]=-5').expect(400);
  });
});
