const crypto = require('crypto');
const db = require('../connection');

// T059: Database seeding for development
async function seedDatabase() {
  console.log('Starting database seeding...');

  const client = await db.getClient();

  try {
    await client.query('BEGIN');

    // Clear existing data (in reverse order of dependencies)
    await client.query('DELETE FROM sync_packages');
    await client.query('DELETE FROM photos');
    await client.query('DELETE FROM revisions');
    await client.query('DELETE FROM gps_boundaries');
    await client.query('DELETE FROM equipment');
    await client.query('DELETE FROM sites');
    await client.query('DELETE FROM clients');
    await client.query('DELETE FROM users');
    await client.query('DELETE FROM companies');

    // Seed companies
    const companies = [
      {
        id: 'company-1',
        name: 'Industrial Services Corp',
        settings: JSON.stringify({
          theme: 'light',
          syncInterval: 15,
          photoQuality: 'high'
        })
      },
      {
        id: 'company-2',
        name: 'Field Tech Solutions',
        settings: JSON.stringify({
          theme: 'dark',
          syncInterval: 30,
          photoQuality: 'medium'
        })
      }
    ];

    for (const company of companies) {
      await client.query(
        `INSERT INTO companies (id, name, settings, created_at, updated_at, is_active)
         VALUES ($1, $2, $3, NOW(), NOW(), true)`,
        [company.id, company.name, company.settings]
      );
    }

    // Seed users (devices)
    const users = [
      {
        id: 'device-1',
        deviceName: 'John\'s iPhone',
        companyId: 'company-1',
        preferences: JSON.stringify({
          autoSync: true,
          syncOnWifiOnly: true
        })
      },
      {
        id: 'device-2',
        deviceName: 'Sarah\'s Android',
        companyId: 'company-1',
        preferences: JSON.stringify({
          autoSync: true,
          syncOnWifiOnly: false
        })
      },
      {
        id: 'device-3',
        deviceName: 'Mike\'s iPad',
        companyId: 'company-2',
        preferences: JSON.stringify({
          autoSync: false,
          syncOnWifiOnly: true
        })
      }
    ];

    for (const user of users) {
      await client.query(
        `INSERT INTO users (id, device_name, company_id, preferences, first_seen, last_seen, is_active)
         VALUES ($1, $2, $3, $4, NOW(), NOW(), true)`,
        [user.id, user.deviceName, user.companyId, user.preferences]
      );
    }

    // Seed clients
    const clients = [
      {
        id: 'client-1',
        companyId: 'company-1',
        name: 'ACME Manufacturing',
        description: 'Primary manufacturing facility'
      },
      {
        id: 'client-2',
        companyId: 'company-1',
        name: 'TechCorp Industries',
        description: 'Technology campus'
      },
      {
        id: 'client-3',
        companyId: 'company-2',
        name: 'Global Energy Systems',
        description: 'Energy production facilities'
      }
    ];

    for (const client of clients) {
      await client.query(
        `INSERT INTO clients (id, company_id, name, description, created_at, updated_at, is_active)
         VALUES ($1, $2, $3, $4, NOW(), NOW(), true)`,
        [client.id, client.companyId, client.name, client.description]
      );
    }

    // Seed sites
    const sites = [
      // ACME Manufacturing sites
      {
        id: 'site-1',
        clientId: 'client-1',
        parentSiteId: null,
        name: 'Main Plant',
        address: '123 Industrial Way, Detroit, MI',
        centerLatitude: 42.3314,
        centerLongitude: -83.0458,
        boundaryRadius: 500
      },
      {
        id: 'site-2',
        clientId: 'client-1',
        parentSiteId: 'site-1',
        name: 'Building A - Production',
        address: 'Building A, Main Plant',
        centerLatitude: 42.3320,
        centerLongitude: -83.0460,
        boundaryRadius: 100
      },
      {
        id: 'site-3',
        clientId: 'client-1',
        parentSiteId: 'site-1',
        name: 'Building B - Warehouse',
        address: 'Building B, Main Plant',
        centerLatitude: 42.3310,
        centerLongitude: -83.0455,
        boundaryRadius: 150
      },
      // TechCorp sites
      {
        id: 'site-4',
        clientId: 'client-2',
        parentSiteId: null,
        name: 'Research Campus',
        address: '456 Tech Boulevard, San Jose, CA',
        centerLatitude: 37.3382,
        centerLongitude: -121.8863,
        boundaryRadius: 300
      },
      {
        id: 'site-5',
        clientId: 'client-2',
        parentSiteId: 'site-4',
        name: 'Lab 1',
        address: 'Laboratory Building 1',
        centerLatitude: 37.3385,
        centerLongitude: -121.8865,
        boundaryRadius: 50
      }
    ];

    for (const site of sites) {
      await client.query(
        `INSERT INTO sites (id, client_id, parent_site_id, name, address, center_latitude, center_longitude, boundary_radius, created_at, updated_at, is_active)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW(), true)`,
        [site.id, site.clientId, site.parentSiteId, site.name, site.address,
         site.centerLatitude, site.centerLongitude, site.boundaryRadius]
      );
    }

    // Seed equipment
    const equipment = [
      // Building A equipment
      {
        id: 'equipment-1',
        siteId: 'site-2',
        name: 'PLC Panel 1',
        equipmentType: 'Control Panel',
        serialNumber: 'PLC-2023-001',
        model: 'Allen-Bradley 5000',
        manufacturer: 'Rockwell Automation',
        tags: ['plc', 'critical', 'production']
      },
      {
        id: 'equipment-2',
        siteId: 'site-2',
        name: 'Conveyor System A',
        equipmentType: 'Conveyor',
        serialNumber: 'CONV-2023-A01',
        model: 'FlexLink X85',
        manufacturer: 'FlexLink',
        tags: ['conveyor', 'production']
      },
      {
        id: 'equipment-3',
        siteId: 'site-2',
        name: 'Hydraulic Press 1',
        equipmentType: 'Press',
        serialNumber: 'HP-2023-001',
        model: 'HydroForce 500T',
        manufacturer: 'Industrial Press Co',
        tags: ['press', 'hydraulic', 'heavy-duty']
      },
      // Building B equipment
      {
        id: 'equipment-4',
        siteId: 'site-3',
        name: 'Forklift Charging Station',
        equipmentType: 'Charging Station',
        serialNumber: 'CS-2023-001',
        model: 'PowerCharge Pro',
        manufacturer: 'ChargeTech',
        tags: ['charging', 'forklift']
      },
      // Lab 1 equipment
      {
        id: 'equipment-5',
        siteId: 'site-5',
        name: 'Test Bench Alpha',
        equipmentType: 'Test Equipment',
        serialNumber: 'TB-2024-A01',
        model: 'LabMaster 3000',
        manufacturer: 'TestCo',
        tags: ['testing', 'lab', 'precision']
      }
    ];

    for (const eq of equipment) {
      await client.query(
        `INSERT INTO equipment (id, site_id, name, equipment_type, serial_number, model, manufacturer, tags, created_at, updated_at, is_active)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW(), true)`,
        [eq.id, eq.siteId, eq.name, eq.equipmentType, eq.serialNumber,
         eq.model, eq.manufacturer, JSON.stringify(eq.tags)]
      );
    }

    // Seed GPS boundaries
    const boundaries = [
      {
        id: 'boundary-1',
        clientId: 'client-1',
        siteId: 'site-1',
        name: 'Main Plant Perimeter',
        centerLatitude: 42.3314,
        centerLongitude: -83.0458,
        radiusMeters: 500,
        priority: 1
      },
      {
        id: 'boundary-2',
        clientId: 'client-1',
        siteId: 'site-2',
        name: 'Building A Zone',
        centerLatitude: 42.3320,
        centerLongitude: -83.0460,
        radiusMeters: 100,
        priority: 2
      },
      {
        id: 'boundary-3',
        clientId: 'client-2',
        siteId: 'site-4',
        name: 'Research Campus Zone',
        centerLatitude: 37.3382,
        centerLongitude: -121.8863,
        radiusMeters: 300,
        priority: 1
      }
    ];

    for (const boundary of boundaries) {
      await client.query(
        `INSERT INTO gps_boundaries (id, client_id, site_id, name, center_latitude, center_longitude, radius_meters, priority, created_at, updated_at, is_active)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW(), true)`,
        [boundary.id, boundary.clientId, boundary.siteId, boundary.name,
         boundary.centerLatitude, boundary.centerLongitude, boundary.radiusMeters, boundary.priority]
      );
    }

    // Seed sample photos
    const photos = [
      {
        id: 'photo-1',
        equipmentId: 'equipment-1',
        fileName: 'plc_panel_001.jpg',
        fileHash: crypto.randomBytes(32).toString('hex'),
        latitude: 42.3320,
        longitude: -83.0460,
        capturedAt: new Date('2024-01-15T10:30:00'),
        notes: 'Initial installation inspection',
        deviceId: 'device-1'
      },
      {
        id: 'photo-2',
        equipmentId: 'equipment-1',
        fileName: 'plc_panel_002.jpg',
        fileHash: crypto.randomBytes(32).toString('hex'),
        latitude: 42.3320,
        longitude: -83.0460,
        capturedAt: new Date('2024-02-20T14:15:00'),
        notes: 'After maintenance work',
        deviceId: 'device-2'
      },
      {
        id: 'photo-3',
        equipmentId: 'equipment-2',
        fileName: 'conveyor_001.jpg',
        fileHash: crypto.randomBytes(32).toString('hex'),
        latitude: 42.3318,
        longitude: -83.0459,
        capturedAt: new Date('2024-03-10T09:00:00'),
        notes: 'Belt replacement',
        deviceId: 'device-1'
      },
      {
        id: 'photo-4',
        equipmentId: null, // Unassigned photo
        fileName: 'unassigned_001.jpg',
        fileHash: crypto.randomBytes(32).toString('hex'),
        latitude: 42.3315,
        longitude: -83.0457,
        capturedAt: new Date('2024-03-15T11:30:00'),
        notes: 'Needs assignment',
        deviceId: 'device-2'
      }
    ];

    for (const photo of photos) {
      await client.query(
        `INSERT INTO photos (id, equipment_id, file_name, file_hash, latitude, longitude, captured_at, notes, device_id, created_at, updated_at, is_synced)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, NOW(), NOW(), true)`,
        [photo.id, photo.equipmentId, photo.fileName, photo.fileHash,
         photo.latitude, photo.longitude, photo.capturedAt, photo.notes, photo.deviceId]
      );
    }

    // Seed revisions
    const revisions = [
      {
        id: 'revision-1',
        equipmentId: 'equipment-1',
        name: '2024-01 Installation',
        description: 'Initial PLC panel installation',
        createdAt: new Date('2024-01-15T08:00:00'),
        createdBy: 'device-1'
      },
      {
        id: 'revision-2',
        equipmentId: 'equipment-1',
        name: '2024-02 Maintenance',
        description: 'Routine maintenance and updates',
        createdAt: new Date('2024-02-20T08:00:00'),
        createdBy: 'device-2'
      }
    ];

    for (const revision of revisions) {
      await client.query(
        `INSERT INTO revisions (id, equipment_id, name, description, created_at, created_by, is_active)
         VALUES ($1, $2, $3, $4, $5, $6, true)`,
        [revision.id, revision.equipmentId, revision.name, revision.description,
         revision.createdAt, revision.createdBy]
      );
    }

    await client.query('COMMIT');
    console.log('Database seeding completed successfully');

    // Print summary
    const stats = await db.getStats();
    console.log('\nDatabase Statistics:');
    console.log(`- Photos: ${stats.photoCount}`);
    console.log(`- Equipment: ${stats.equipmentCount}`);
    console.log(`- Database Size: ${stats.databaseSizeMB} MB`);

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Database seeding failed:', error);
    throw error;
  } finally {
    client.release();
  }
}

// Run if called directly
if (require.main === module) {
  db.initialize()
    .then(() => seedDatabase())
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = seedDatabase;