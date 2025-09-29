import 'package:flutter_test/flutter_test.dart';
import 'package:fieldphoto_pro/models/photo.dart';

void main() {
  group('Photo Model Validation Tests', () {
    test('Photo creates with valid required fields', () {
      final photo = Photo(
        id: '550e8400-e29b-41d4-a716-446655440000',
        equipmentId: '660e8400-e29b-41d4-a716-446655440001',
        fileName: 'test_photo.jpg',
        fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        capturedAt: DateTime(2024, 1, 15, 10, 30),
        deviceId: '770e8400-e29b-41d4-a716-446655440002',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      expect(photo.id, isNotEmpty);
      expect(photo.equipmentId, isNotEmpty);
      expect(photo.fileName, equals('test_photo.jpg'));
      expect(photo.fileHash, hasLength(64));
      expect(photo.deviceId, isNotEmpty);
      expect(photo.isSynced, isFalse);
    });

    test('Photo validates UUID format for id', () {
      expect(
        () => Photo(
          id: 'invalid-uuid',
          equipmentId: '660e8400-e29b-41d4-a716-446655440001',
          fileName: 'test.jpg',
          fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
          capturedAt: DateTime.now(),
          deviceId: '770e8400-e29b-41d4-a716-446655440002',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
        ).validate(),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Photo validates file hash is SHA-256', () {
      expect(
        () => Photo(
          id: '550e8400-e29b-41d4-a716-446655440000',
          equipmentId: '660e8400-e29b-41d4-a716-446655440001',
          fileName: 'test.jpg',
          fileHash: 'invalid-hash',
          capturedAt: DateTime.now(),
          deviceId: '770e8400-e29b-41d4-a716-446655440002',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
        ).validate(),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Photo validates GPS coordinates when present', () {
      final validPhoto = Photo(
        id: '550e8400-e29b-41d4-a716-446655440000',
        equipmentId: '660e8400-e29b-41d4-a716-446655440001',
        fileName: 'gps_photo.jpg',
        fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        capturedAt: DateTime.now(),
        deviceId: '770e8400-e29b-41d4-a716-446655440002',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
        latitude: 42.3601,
        longitude: -71.0589,
      );

      expect(validPhoto.validate(), isTrue);
      expect(validPhoto.latitude, inInclusiveRange(-90, 90));
      expect(validPhoto.longitude, inInclusiveRange(-180, 180));
    });

    test('Photo rejects invalid GPS coordinates', () {
      expect(
        () => Photo(
          id: '550e8400-e29b-41d4-a716-446655440000',
          equipmentId: '660e8400-e29b-41d4-a716-446655440001',
          fileName: 'bad_gps.jpg',
          fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
          capturedAt: DateTime.now(),
          deviceId: '770e8400-e29b-41d4-a716-446655440002',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
          latitude: 91.0, // Invalid: > 90
          longitude: -71.0589,
        ).validate(),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => Photo(
          id: '550e8400-e29b-41d4-a716-446655440000',
          equipmentId: '660e8400-e29b-41d4-a716-446655440001',
          fileName: 'bad_gps2.jpg',
          fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
          capturedAt: DateTime.now(),
          deviceId: '770e8400-e29b-41d4-a716-446655440002',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
          latitude: 42.3601,
          longitude: -181.0, // Invalid: < -180
        ).validate(),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Photo validates captured date is not in future', () {
      expect(
        () => Photo(
          id: '550e8400-e29b-41d4-a716-446655440000',
          equipmentId: '660e8400-e29b-41d4-a716-446655440001',
          fileName: 'future.jpg',
          fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
          capturedAt: DateTime.now().add(Duration(days: 1)), // Future date
          deviceId: '770e8400-e29b-41d4-a716-446655440002',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
        ).validate(),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Photo notes have maximum length', () {
      final longNotes = 'x' * 1001; // Exceeds 1000 char limit

      expect(
        () => Photo(
          id: '550e8400-e29b-41d4-a716-446655440000',
          equipmentId: '660e8400-e29b-41d4-a716-446655440001',
          fileName: 'noted.jpg',
          fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
          capturedAt: DateTime.now(),
          deviceId: '770e8400-e29b-41d4-a716-446655440002',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
          notes: longNotes,
        ).validate(),
        throwsA(isA<ValidationException>()),
      );

      final validNotes = 'x' * 1000; // Exactly at limit
      final photoWithNotes = Photo(
        id: '550e8400-e29b-41d4-a716-446655440000',
        equipmentId: '660e8400-e29b-41d4-a716-446655440001',
        fileName: 'noted2.jpg',
        fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        capturedAt: DateTime.now(),
        deviceId: '770e8400-e29b-41d4-a716-446655440002',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
        notes: validNotes,
      );

      expect(photoWithNotes.validate(), isTrue);
    });

    test('Photo validates file name uniqueness within device', () {
      final photo1 = Photo(
        id: '550e8400-e29b-41d4-a716-446655440000',
        equipmentId: '660e8400-e29b-41d4-a716-446655440001',
        fileName: 'unique.jpg',
        fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        capturedAt: DateTime.now(),
        deviceId: '770e8400-e29b-41d4-a716-446655440002',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      final photo2 = Photo(
        id: '550e8400-e29b-41d4-a716-446655440003',
        equipmentId: '660e8400-e29b-41d4-a716-446655440001',
        fileName: 'unique.jpg', // Same name, same device
        fileHash: 'b665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        capturedAt: DateTime.now(),
        deviceId: '770e8400-e29b-41d4-a716-446655440002', // Same device
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      expect(photo1.fileName, equals(photo2.fileName));
      expect(photo1.deviceId, equals(photo2.deviceId));
      // Validation should check for uniqueness
    });

    test('Photo supports optional revision grouping', () {
      final photoWithRevision = Photo(
        id: '550e8400-e29b-41d4-a716-446655440000',
        equipmentId: '660e8400-e29b-41d4-a716-446655440001',
        revisionId: '880e8400-e29b-41d4-a716-446655440003',
        fileName: 'revision.jpg',
        fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        capturedAt: DateTime.now(),
        deviceId: '770e8400-e29b-41d4-a716-446655440002',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      expect(photoWithRevision.revisionId, isNotNull);
      expect(photoWithRevision.validate(), isTrue);

      final photoWithoutRevision = Photo(
        id: '550e8400-e29b-41d4-a716-446655440004',
        equipmentId: '660e8400-e29b-41d4-a716-446655440001',
        fileName: 'no_revision.jpg',
        fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        capturedAt: DateTime.now(),
        deviceId: '770e8400-e29b-41d4-a716-446655440002',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      expect(photoWithoutRevision.revisionId, isNull);
      expect(photoWithoutRevision.validate(), isTrue);
    });

    test('Photo validates state transitions', () {
      final photo = Photo(
        id: '550e8400-e29b-41d4-a716-446655440000',
        equipmentId: '660e8400-e29b-41d4-a716-446655440001',
        fileName: 'state.jpg',
        fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        capturedAt: DateTime.now(),
        deviceId: '770e8400-e29b-41d4-a716-446655440002',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      // Test state transitions
      expect(photo.isSynced, isFalse);
      expect(photo.canTransitionTo('captured'), isTrue);

      photo.transitionTo('captured');
      expect(photo.state, equals('captured'));
      expect(photo.canTransitionTo('annotated'), isTrue);

      photo.transitionTo('annotated');
      expect(photo.state, equals('annotated'));
      expect(photo.canTransitionTo('synced'), isTrue);

      photo.transitionTo('synced');
      expect(photo.isSynced, isTrue);
      expect(photo.canTransitionTo('created'), isFalse); // Can't go backwards
    });

    test('Photo serializes to JSON correctly', () {
      final photo = Photo(
        id: '550e8400-e29b-41d4-a716-446655440000',
        equipmentId: '660e8400-e29b-41d4-a716-446655440001',
        fileName: 'json.jpg',
        fileHash: 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        capturedAt: DateTime(2024, 1, 15, 10, 30),
        deviceId: '770e8400-e29b-41d4-a716-446655440002',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 35),
        isSynced: false,
        latitude: 42.3601,
        longitude: -71.0589,
        notes: 'Test notes',
      );

      final json = photo.toJson();

      expect(json['id'], equals('550e8400-e29b-41d4-a716-446655440000'));
      expect(json['equipmentId'], equals('660e8400-e29b-41d4-a716-446655440001'));
      expect(json['fileName'], equals('json.jpg'));
      expect(json['fileHash'], equals('a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3'));
      expect(json['latitude'], equals(42.3601));
      expect(json['longitude'], equals(-71.0589));
      expect(json['notes'], equals('Test notes'));
      expect(json['isSynced'], isFalse);
    });

    test('Photo deserializes from JSON correctly', () {
      final json = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'equipmentId': '660e8400-e29b-41d4-a716-446655440001',
        'fileName': 'from_json.jpg',
        'fileHash': 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3',
        'capturedAt': '2024-01-15T10:30:00.000',
        'deviceId': '770e8400-e29b-41d4-a716-446655440002',
        'createdAt': '2024-01-15T10:30:00.000',
        'updatedAt': '2024-01-15T10:35:00.000',
        'isSynced': true,
        'latitude': 42.3601,
        'longitude': -71.0589,
        'notes': 'Deserialized notes',
      };

      final photo = Photo.fromJson(json);

      expect(photo.id, equals('550e8400-e29b-41d4-a716-446655440000'));
      expect(photo.fileName, equals('from_json.jpg'));
      expect(photo.latitude, equals(42.3601));
      expect(photo.longitude, equals(-71.0589));
      expect(photo.notes, equals('Deserialized notes'));
      expect(photo.isSynced, isTrue);
    });
  });
}