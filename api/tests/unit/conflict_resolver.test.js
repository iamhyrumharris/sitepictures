const ConflictResolver = require('../../src/services/conflict_resolver');

describe('Conflict Resolution Unit Tests', () => {
  let conflictResolver;

  beforeEach(() => {
    conflictResolver = new ConflictResolver();
  });

  describe('Merge All Strategy', () => {
    it('should merge both versions of conflicting updates', async () => {
      const localVersion = {
        id: 'photo-001',
        equipmentId: 'equip-001',
        fileName: 'local.jpg',
        notes: 'Local notes',
        updatedAt: new Date('2024-01-15T10:00:00Z'),
        deviceId: 'device-001'
      };

      const remoteVersion = {
        id: 'photo-001',
        equipmentId: 'equip-001',
        fileName: 'remote.jpg',
        notes: 'Remote notes',
        updatedAt: new Date('2024-01-15T10:01:00Z'),
        deviceId: 'device-002'
      };

      const resolution = await conflictResolver.resolve(localVersion, remoteVersion);

      expect(resolution.strategy).toBe('MERGE_ALL');
      expect(resolution.preservedVersions).toBe(2);
      expect(resolution.dataLoss).toBe(false);
      expect(resolution.merged.notes).toContain('Local notes');
      expect(resolution.merged.notes).toContain('Remote notes');
    });

    it('should preserve all field values from both versions', async () => {
      const localVersion = {
        id: 'equip-001',
        name: 'Panel A',
        location: 'Building 1',
        tags: ['maintenance'],
        updatedAt: new Date('2024-01-15T10:00:00Z'),
        deviceId: 'device-001'
      };

      const remoteVersion = {
        id: 'equip-001',
        name: 'Panel A Updated',
        serialNumber: 'SN12345',
        tags: ['inspection'],
        updatedAt: new Date('2024-01-15T10:02:00Z'),
        deviceId: 'device-002'
      };

      const resolution = await conflictResolver.resolve(localVersion, remoteVersion);

      expect(resolution.merged.name).toContain('Panel A Updated');
      expect(resolution.merged.location).toBe('Building 1');
      expect(resolution.merged.serialNumber).toBe('SN12345');
      expect(resolution.merged.tags).toContain('maintenance');
      expect(resolution.merged.tags).toContain('inspection');
    });

    it('should handle array field merging correctly', async () => {
      const localVersion = {
        id: 'site-001',
        boundaries: [
          { lat: 42.3601, lng: -71.0589 },
          { lat: 42.3605, lng: -71.0590 }
        ],
        deviceId: 'device-001'
      };

      const remoteVersion = {
        id: 'site-001',
        boundaries: [
          { lat: 42.3601, lng: -71.0589 },
          { lat: 42.3608, lng: -71.0592 }
        ],
        deviceId: 'device-002'
      };

      const resolution = await conflictResolver.resolve(localVersion, remoteVersion);

      expect(resolution.merged.boundaries).toHaveLength(3);
      expect(resolution.merged.boundaries).toContainEqual({ lat: 42.3605, lng: -71.0590 });
      expect(resolution.merged.boundaries).toContainEqual({ lat: 42.3608, lng: -71.0592 });
    });

    it('should maintain attribution for merged changes', async () => {
      const localVersion = {
        id: 'photo-001',
        notes: 'Maintenance required',
        updatedAt: new Date('2024-01-15T10:00:00Z'),
        deviceId: 'device-001'
      };

      const remoteVersion = {
        id: 'photo-001',
        notes: 'Inspection complete',
        updatedAt: new Date('2024-01-15T10:05:00Z'),
        deviceId: 'device-002'
      };

      const resolution = await conflictResolver.resolve(localVersion, remoteVersion);

      expect(resolution.merged.attribution).toEqual([
        {
          deviceId: 'device-001',
          timestamp: localVersion.updatedAt,
          field: 'notes',
          value: 'Maintenance required'
        },
        {
          deviceId: 'device-002',
          timestamp: remoteVersion.updatedAt,
          field: 'notes',
          value: 'Inspection complete'
        }
      ]);
    });
  });

  describe('Conflict Detection', () => {
    it('should detect concurrent updates to same entity', async () => {
      const update1 = {
        id: 'photo-001',
        operation: 'UPDATE',
        timestamp: new Date('2024-01-15T10:00:00Z'),
        deviceId: 'device-001'
      };

      const update2 = {
        id: 'photo-001',
        operation: 'UPDATE',
        timestamp: new Date('2024-01-15T10:00:05Z'),
        deviceId: 'device-002'
      };

      const hasConflict = await conflictResolver.detectConflict(update1, update2);

      expect(hasConflict).toBe(true);
    });

    it('should not detect conflict for different entities', async () => {
      const update1 = {
        id: 'photo-001',
        operation: 'UPDATE',
        timestamp: new Date('2024-01-15T10:00:00Z'),
        deviceId: 'device-001'
      };

      const update2 = {
        id: 'photo-002',
        operation: 'UPDATE',
        timestamp: new Date('2024-01-15T10:00:05Z'),
        deviceId: 'device-002'
      };

      const hasConflict = await conflictResolver.detectConflict(update1, update2);

      expect(hasConflict).toBe(false);
    });

    it('should detect delete conflicts', async () => {
      const update = {
        id: 'photo-001',
        operation: 'UPDATE',
        timestamp: new Date('2024-01-15T10:00:00Z'),
        deviceId: 'device-001'
      };

      const deletion = {
        id: 'photo-001',
        operation: 'DELETE',
        timestamp: new Date('2024-01-15T10:00:05Z'),
        deviceId: 'device-002'
      };

      const conflict = await conflictResolver.detectDeleteConflict(update, deletion);

      expect(conflict).toBe(true);
      expect(conflict.type).toBe('DELETE_CONFLICT');
    });
  });

  describe('Version History', () => {
    it('should maintain complete version history', async () => {
      const versions = [
        {
          id: 'photo-001',
          version: 1,
          notes: 'Initial',
          timestamp: new Date('2024-01-15T10:00:00Z'),
          deviceId: 'device-001'
        },
        {
          id: 'photo-001',
          version: 2,
          notes: 'Updated',
          timestamp: new Date('2024-01-15T10:05:00Z'),
          deviceId: 'device-002'
        },
        {
          id: 'photo-001',
          version: 3,
          notes: 'Final',
          timestamp: new Date('2024-01-15T10:10:00Z'),
          deviceId: 'device-001'
        }
      ];

      const history = await conflictResolver.buildVersionHistory(versions);

      expect(history).toHaveLength(3);
      expect(history[0].version).toBe(1);
      expect(history[2].version).toBe(3);
      expect(history[2].notes).toBe('Final');
    });

    it('should preserve all versions during merge', async () => {
      const localHistory = [
        { version: 1, notes: 'Base', deviceId: 'device-001' },
        { version: 2, notes: 'Local update', deviceId: 'device-001' }
      ];

      const remoteHistory = [
        { version: 1, notes: 'Base', deviceId: 'device-001' },
        { version: 2, notes: 'Remote update', deviceId: 'device-002' }
      ];

      const mergedHistory = await conflictResolver.mergeHistories(localHistory, remoteHistory);

      expect(mergedHistory).toHaveLength(3);
      expect(mergedHistory).toContainEqual(expect.objectContaining({ notes: 'Base' }));
      expect(mergedHistory).toContainEqual(expect.objectContaining({ notes: 'Local update' }));
      expect(mergedHistory).toContainEqual(expect.objectContaining({ notes: 'Remote update' }));
    });
  });

  describe('Field-Level Conflict Resolution', () => {
    it('should handle field-level conflicts intelligently', async () => {
      const localVersion = {
        id: 'equip-001',
        name: 'Panel A',
        temperature: 75.5,
        lastMaintenance: new Date('2024-01-10'),
        deviceId: 'device-001'
      };

      const remoteVersion = {
        id: 'equip-001',
        name: 'Panel A',
        temperature: 76.2,
        lastInspection: new Date('2024-01-12'),
        deviceId: 'device-002'
      };

      const resolution = await conflictResolver.resolveFieldLevel(localVersion, remoteVersion);

      expect(resolution.name).toBe('Panel A'); // Same value, no conflict
      expect(resolution.temperature).toBe(76.2); // Take latest reading
      expect(resolution.lastMaintenance).toEqual(new Date('2024-01-10'));
      expect(resolution.lastInspection).toEqual(new Date('2024-01-12'));
    });

    it('should merge text fields with attribution', async () => {
      const localVersion = {
        id: 'photo-001',
        description: 'Equipment before maintenance',
        deviceId: 'device-001',
        timestamp: new Date('2024-01-15T10:00:00Z')
      };

      const remoteVersion = {
        id: 'photo-001',
        description: 'Shows wear on bearings',
        deviceId: 'device-002',
        timestamp: new Date('2024-01-15T10:05:00Z')
      };

      const resolution = await conflictResolver.resolveTextFields(localVersion, remoteVersion);

      expect(resolution.description).toContain('Equipment before maintenance');
      expect(resolution.description).toContain('Shows wear on bearings');
      expect(resolution.description).toContain('[device-001]');
      expect(resolution.description).toContain('[device-002]');
    });
  });

  describe('Timestamp Handling', () => {
    it('should handle clock skew between devices', async () => {
      const localVersion = {
        id: 'photo-001',
        timestamp: new Date('2024-01-15T10:00:00Z'),
        deviceId: 'device-001'
      };

      const remoteVersion = {
        id: 'photo-001',
        timestamp: new Date('2024-01-15T09:59:58Z'), // 2 seconds earlier
        deviceId: 'device-002'
      };

      const adjusted = await conflictResolver.adjustForClockSkew(localVersion, remoteVersion);

      expect(Math.abs(adjusted.skew)).toBeLessThan(5000); // Less than 5 seconds
      expect(adjusted.concurrent).toBe(true);
    });

    it('should use vector clocks for ordering', async () => {
      const events = [
        { id: '1', vectorClock: { 'device-001': 1, 'device-002': 0 } },
        { id: '2', vectorClock: { 'device-001': 1, 'device-002': 1 } },
        { id: '3', vectorClock: { 'device-001': 2, 'device-002': 1 } }
      ];

      const ordered = await conflictResolver.orderByVectorClock(events);

      expect(ordered[0].id).toBe('1');
      expect(ordered[2].id).toBe('3');
    });
  });

  describe('Conflict Resolution Strategies', () => {
    it('should support last-write-wins strategy when configured', async () => {
      conflictResolver.setStrategy('LAST_WRITE_WINS');

      const localVersion = {
        id: 'photo-001',
        notes: 'Local notes',
        updatedAt: new Date('2024-01-15T10:00:00Z'),
        deviceId: 'device-001'
      };

      const remoteVersion = {
        id: 'photo-001',
        notes: 'Remote notes',
        updatedAt: new Date('2024-01-15T10:01:00Z'),
        deviceId: 'device-002'
      };

      const resolution = await conflictResolver.resolve(localVersion, remoteVersion);

      expect(resolution.strategy).toBe('LAST_WRITE_WINS');
      expect(resolution.merged.notes).toBe('Remote notes');
    });

    it('should support custom resolution function', async () => {
      const customResolver = (local, remote) => {
        return {
          ...remote,
          notes: `${local.notes} | ${remote.notes}`
        };
      };

      conflictResolver.setCustomResolver(customResolver);

      const localVersion = {
        id: 'photo-001',
        notes: 'Local',
        deviceId: 'device-001'
      };

      const remoteVersion = {
        id: 'photo-001',
        notes: 'Remote',
        deviceId: 'device-002'
      };

      const resolution = await conflictResolver.resolve(localVersion, remoteVersion);

      expect(resolution.merged.notes).toBe('Local | Remote');
    });
  });

  describe('Data Integrity', () => {
    it('should never lose data during conflict resolution', async () => {
      const localVersion = {
        id: 'photo-001',
        uniqueLocalField: 'local-only-data',
        sharedField: 'local-value',
        deviceId: 'device-001'
      };

      const remoteVersion = {
        id: 'photo-001',
        uniqueRemoteField: 'remote-only-data',
        sharedField: 'remote-value',
        deviceId: 'device-002'
      };

      const resolution = await conflictResolver.resolve(localVersion, remoteVersion);

      expect(resolution.dataLoss).toBe(false);
      expect(resolution.merged.uniqueLocalField).toBe('local-only-data');
      expect(resolution.merged.uniqueRemoteField).toBe('remote-only-data');
      expect(resolution.merged.sharedField).toBeDefined();
    });

    it('should validate merged data integrity', async () => {
      const localVersion = {
        id: 'photo-001',
        fileHash: 'abc123',
        fileSize: 1024,
        deviceId: 'device-001'
      };

      const remoteVersion = {
        id: 'photo-001',
        fileHash: 'abc123',
        fileSize: 1024,
        deviceId: 'device-002'
      };

      const resolution = await conflictResolver.resolve(localVersion, remoteVersion);
      const isValid = await conflictResolver.validateIntegrity(resolution.merged);

      expect(isValid).toBe(true);
      expect(resolution.merged.fileHash).toBe('abc123');
    });
  });

  describe('Batch Conflict Resolution', () => {
    it('should resolve multiple conflicts in batch', async () => {
      const conflicts = [
        {
          local: { id: '1', value: 'local1' },
          remote: { id: '1', value: 'remote1' }
        },
        {
          local: { id: '2', value: 'local2' },
          remote: { id: '2', value: 'remote2' }
        }
      ];

      const resolutions = await conflictResolver.resolveBatch(conflicts);

      expect(resolutions).toHaveLength(2);
      expect(resolutions[0].dataLoss).toBe(false);
      expect(resolutions[1].dataLoss).toBe(false);
    });

    it('should handle related entity conflicts', async () => {
      const photoConflict = {
        local: { id: 'photo-001', equipmentId: 'equip-001' },
        remote: { id: 'photo-001', equipmentId: 'equip-002' }
      };

      const equipmentConflict = {
        local: { id: 'equip-001', name: 'Panel A' },
        remote: { id: 'equip-002', name: 'Panel B' }
      };

      const resolutions = await conflictResolver.resolveRelated([
        photoConflict,
        equipmentConflict
      ]);

      expect(resolutions).toHaveLength(2);
      // Should maintain referential integrity
      expect(resolutions[0].merged.equipmentId).toBeDefined();
    });
  });
});