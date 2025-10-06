import 'package:flutter_test/flutter_test.dart';
import 'package:sitepictures/models/photo.dart';

void main() {
  group('Photo', () {
    test('creates photo with valid data', () {
      final timestamp = DateTime.now().subtract(const Duration(minutes: 5));
      final photo = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        thumbnailPath: '/path/to/thumbnail.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024 * 1024, // 1MB
      );

      expect(photo.equipmentId, 'equipment-123');
      expect(photo.filePath, '/path/to/photo.jpg');
      expect(photo.thumbnailPath, '/path/to/thumbnail.jpg');
      expect(photo.latitude, 45.5);
      expect(photo.longitude, -122.6);
      expect(photo.timestamp, timestamp);
      expect(photo.capturedBy, 'user-123');
      expect(photo.fileSize, 1024 * 1024);
      expect(photo.id, isNotEmpty);
      expect(photo.isSynced, false);
      expect(photo.syncedAt, null);
      expect(photo.remoteUrl, null);
    });

    test('generates UUID when id not provided', () {
      final timestamp = DateTime.now();
      final photo1 = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo1.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
      );
      final photo2 = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo2.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
      );

      expect(photo1.id, isNotEmpty);
      expect(photo2.id, isNotEmpty);
      expect(photo1.id, isNot(equals(photo2.id)));
    });

    test('isValid returns true for valid photo', () {
      final timestamp = DateTime.now().subtract(const Duration(minutes: 5));
      final photo = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024 * 1024,
      );

      expect(photo.isValid(), true);
    });

    test('isValid returns false for empty filePath', () {
      final timestamp = DateTime.now();
      final photo = Photo(
        equipmentId: 'equipment-123',
        filePath: '',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
      );

      expect(photo.isValid(), false);
    });

    test('isValid returns false for empty equipmentId', () {
      final timestamp = DateTime.now();
      final photo = Photo(
        equipmentId: '',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
      );

      expect(photo.isValid(), false);
    });

    test('isValid returns false for empty capturedBy', () {
      final timestamp = DateTime.now();
      final photo = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: '',
        fileSize: 1024,
      );

      expect(photo.isValid(), false);
    });

    test('isValid returns false for future timestamp', () {
      final futureTime = DateTime.now().add(const Duration(days: 1));
      final photo = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: futureTime,
        capturedBy: 'user-123',
        fileSize: 1024,
      );

      expect(photo.isValid(), false);
    });

    test('isValid returns false for invalid latitude', () {
      final timestamp = DateTime.now();
      final photo1 = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: -91.0,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
      );
      final photo2 = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 91.0,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
      );

      expect(photo1.isValid(), false);
      expect(photo2.isValid(), false);
    });

    test('isValid returns false for invalid longitude', () {
      final timestamp = DateTime.now();
      final photo1 = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -181.0,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
      );
      final photo2 = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: 181.0,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
      );

      expect(photo1.isValid(), false);
      expect(photo2.isValid(), false);
    });

    test('isValid returns false for fileSize <= 0', () {
      final timestamp = DateTime.now();
      final photo = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 0,
      );

      expect(photo.isValid(), false);
    });

    test('isValid returns false for fileSize > 10MB', () {
      final timestamp = DateTime.now();
      final photo = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 11 * 1024 * 1024, // 11MB
      );

      expect(photo.isValid(), false);
    });

    test('isValid returns true for fileSize exactly 10MB', () {
      final timestamp = DateTime.now();
      final photo = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 10 * 1024 * 1024, // 10MB
      );

      expect(photo.isValid(), true);
    });

    group('Serialization', () {
      test('toMap converts to database format', () {
        final timestamp = DateTime.parse('2025-01-01T12:00:00.000Z');
        final photo = Photo(
          id: 'test-id',
          equipmentId: 'equipment-123',
          filePath: '/path/to/photo.jpg',
          thumbnailPath: '/path/to/thumbnail.jpg',
          latitude: 45.5,
          longitude: -122.6,
          timestamp: timestamp,
          capturedBy: 'user-123',
          fileSize: 1024 * 1024,
          isSynced: true,
          syncedAt: '2025-01-01T13:00:00.000Z',
          remoteUrl: 'https://example.com/photo.jpg',
        );

        final map = photo.toMap();

        expect(map['id'], 'test-id');
        expect(map['equipment_id'], 'equipment-123');
        expect(map['file_path'], '/path/to/photo.jpg');
        expect(map['thumbnail_path'], '/path/to/thumbnail.jpg');
        expect(map['latitude'], 45.5);
        expect(map['longitude'], -122.6);
        expect(map['timestamp'], '2025-01-01T12:00:00.000Z');
        expect(map['captured_by'], 'user-123');
        expect(map['file_size'], 1024 * 1024);
        expect(map['is_synced'], 1);
        expect(map['synced_at'], '2025-01-01T13:00:00.000Z');
        expect(map['remote_url'], 'https://example.com/photo.jpg');
      });

      test('toMap converts isSynced false to 0', () {
        final timestamp = DateTime.now();
        final photo = Photo(
          equipmentId: 'equipment-123',
          filePath: '/path/to/photo.jpg',
          latitude: 45.5,
          longitude: -122.6,
          timestamp: timestamp,
          capturedBy: 'user-123',
          fileSize: 1024,
          isSynced: false,
        );

        final map = photo.toMap();
        expect(map['is_synced'], 0);
      });

      test('fromMap creates photo from database map', () {
        final map = {
          'id': 'test-id',
          'equipment_id': 'equipment-123',
          'file_path': '/path/to/photo.jpg',
          'thumbnail_path': '/path/to/thumbnail.jpg',
          'latitude': 45.5,
          'longitude': -122.6,
          'timestamp': '2025-01-01T12:00:00.000Z',
          'captured_by': 'user-123',
          'file_size': 1024 * 1024,
          'is_synced': 1,
          'synced_at': '2025-01-01T13:00:00.000Z',
          'remote_url': 'https://example.com/photo.jpg',
        };

        final photo = Photo.fromMap(map);

        expect(photo.id, 'test-id');
        expect(photo.equipmentId, 'equipment-123');
        expect(photo.filePath, '/path/to/photo.jpg');
        expect(photo.latitude, 45.5);
        expect(photo.longitude, -122.6);
        expect(photo.fileSize, 1024 * 1024);
        expect(photo.isSynced, true);
        expect(photo.remoteUrl, 'https://example.com/photo.jpg');
      });

      test('fromMap handles isSynced = 0', () {
        final map = {
          'id': 'test-id',
          'equipment_id': 'equipment-123',
          'file_path': '/path/to/photo.jpg',
          'thumbnail_path': null,
          'latitude': 45.5,
          'longitude': -122.6,
          'timestamp': '2025-01-01T12:00:00.000Z',
          'captured_by': 'user-123',
          'file_size': 1024,
          'is_synced': 0,
          'synced_at': null,
          'remote_url': null,
        };

        final photo = Photo.fromMap(map);
        expect(photo.isSynced, false);
      });

      test('toJson converts to API format', () {
        final timestamp = DateTime.parse('2025-01-01T12:00:00.000Z');
        final photo = Photo(
          id: 'test-id',
          equipmentId: 'equipment-123',
          filePath: '/path/to/photo.jpg',
          latitude: 45.5,
          longitude: -122.6,
          timestamp: timestamp,
          capturedBy: 'user-123',
          fileSize: 1024 * 1024,
        );

        final json = photo.toJson();

        expect(json['id'], 'test-id');
        expect(json['equipmentId'], 'equipment-123');
        expect(json['latitude'], 45.5);
        expect(json['longitude'], -122.6);
        expect(json['timestamp'], '2025-01-01T12:00:00.000Z');
        expect(json['capturedBy'], 'user-123');
        expect(json['fileSize'], 1024 * 1024);
        expect(json.containsKey('filePath'), false); // Not included in API
      });

      test('fromJson creates photo from API JSON', () {
        final json = {
          'id': 'test-id',
          'equipmentId': 'equipment-123',
          'latitude': 45.5,
          'longitude': -122.6,
          'timestamp': '2025-01-01T12:00:00.000Z',
          'capturedBy': 'user-123',
          'fileSize': 1024 * 1024,
          'syncedAt': '2025-01-01T13:00:00.000Z',
          'remoteUrl': 'https://example.com/photo.jpg',
        };

        final photo = Photo.fromJson(json);

        expect(photo.id, 'test-id');
        expect(photo.equipmentId, 'equipment-123');
        expect(photo.latitude, 45.5);
        expect(photo.fileSize, 1024 * 1024);
        expect(photo.isSynced, true);
        expect(photo.remoteUrl, 'https://example.com/photo.jpg');
      });
    });

    test('copyWith creates new instance with updated fields', () {
      final timestamp = DateTime.now();
      final original = Photo(
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
        isSynced: false,
      );

      final updated = original.copyWith(
        thumbnailPath: '/path/to/thumbnail.jpg',
        isSynced: true,
        syncedAt: '2025-01-01T13:00:00.000Z',
        remoteUrl: 'https://example.com/photo.jpg',
      );

      expect(updated.id, original.id);
      expect(updated.thumbnailPath, '/path/to/thumbnail.jpg');
      expect(updated.isSynced, true);
      expect(updated.syncedAt, '2025-01-01T13:00:00.000Z');
      expect(updated.remoteUrl, 'https://example.com/photo.jpg');
      expect(updated.filePath, original.filePath);
      expect(updated.latitude, original.latitude);
    });

    test('toString returns readable format', () {
      final timestamp = DateTime.now();
      final photo = Photo(
        id: 'test-id',
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
        isSynced: true,
      );

      final str = photo.toString();

      expect(str.contains('test-id'), true);
      expect(str.contains('/path/to/photo.jpg'), true);
      expect(str.contains('equipment-123'), true);
      expect(str.contains('true'), true);
    });

    test('equality based on id', () {
      final timestamp = DateTime.now();
      final photo1 = Photo(
        id: 'same-id',
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo1.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
      );
      final photo2 = Photo(
        id: 'same-id',
        equipmentId: 'equipment-456',
        filePath: '/path/to/photo2.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-456',
        fileSize: 2048,
      );

      expect(photo1 == photo2, true);
    });

    test('hashCode based on id', () {
      final timestamp = DateTime.now();
      final photo = Photo(
        id: 'test-id',
        equipmentId: 'equipment-123',
        filePath: '/path/to/photo.jpg',
        latitude: 45.5,
        longitude: -122.6,
        timestamp: timestamp,
        capturedBy: 'user-123',
        fileSize: 1024,
      );

      expect(photo.hashCode, 'test-id'.hashCode);
    });
  });
}
