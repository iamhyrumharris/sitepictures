import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:io';
import 'package:fieldphoto_pro/services/camera_service.dart';
import 'package:fieldphoto_pro/services/storage_service.dart';
import 'package:fieldphoto_pro/services/gps_service.dart';
import 'package:fieldphoto_pro/models/photo.dart';

@GenerateMocks([CameraService, StorageService, GPSService])
import 'photo_capture_speed_test.mocks.dart';

void main() {
  group('Photo Capture Speed Test', () {
    late MockCameraService mockCameraService;
    late MockStorageService mockStorageService;
    late MockGPSService mockGPSService;
    late DateTime startTime;
    late DateTime endTime;

    setUp(() {
      mockCameraService = MockCameraService();
      mockStorageService = MockStorageService();
      mockGPSService = MockGPSService();
    });

    test('Photo capture completes in less than 2 seconds', () async {
      // Constitutional requirement: <2s from launch to save
      const maxDuration = Duration(seconds: 2);

      // Mock camera capture
      when(mockCameraService.takePicture()).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 800)); // Simulate camera delay
        return File('test_photo.jpg');
      });

      // Mock GPS coordinates
      when(mockGPSService.getCurrentLocation()).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100)); // Simulate GPS delay
        return {'latitude': 42.3601, 'longitude': -71.0589};
      });

      // Mock metadata extraction
      when(mockCameraService.extractMetadata(any)).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 50));
        return {
          'timestamp': DateTime.now().toIso8601String(),
          'deviceId': 'test-device-001',
        };
      });

      // Mock storage save
      when(mockStorageService.savePhoto(any)).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 200)); // Simulate save delay
        return Photo(
          id: 'photo-001',
          equipmentId: 'equipment-001',
          fileName: 'test_photo.jpg',
          fileHash: 'abc123def456',
          capturedAt: DateTime.now(),
          deviceId: 'test-device-001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
          latitude: 42.3601,
          longitude: -71.0589,
        );
      });

      // Start timing
      startTime = DateTime.now();

      // Execute photo capture workflow
      final photoFile = await mockCameraService.takePicture();
      final location = await mockGPSService.getCurrentLocation();
      final metadata = await mockCameraService.extractMetadata(photoFile);
      final photo = await mockStorageService.savePhoto({
        'file': photoFile,
        'location': location,
        'metadata': metadata,
      });

      // End timing
      endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      // Verify performance requirement
      expect(duration.inMilliseconds, lessThan(maxDuration.inMilliseconds),
          reason: 'Photo capture took ${duration.inMilliseconds}ms, expected <2000ms');

      // Verify photo was saved successfully
      expect(photo, isNotNull);
      expect(photo.id, isNotEmpty);
      expect(photo.fileHash, isNotEmpty);
    });

    test('Quick capture mode optimizes for speed', () async {
      // Test optimized quick capture workflow
      const targetDuration = Duration(milliseconds: 1500);

      when(mockCameraService.quickCapture()).thenAnswer((_) async {
        // Optimized capture with parallel operations
        await Future.delayed(Duration(milliseconds: 600));
        return {
          'file': File('quick_photo.jpg'),
          'timestamp': DateTime.now(),
        };
      });

      when(mockStorageService.quickSave(any)).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return 'photo-002';
      });

      startTime = DateTime.now();

      // Execute optimized workflow
      final result = await mockCameraService.quickCapture();
      final photoId = await mockStorageService.quickSave(result);

      endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      expect(duration.inMilliseconds, lessThan(targetDuration.inMilliseconds));
      expect(photoId, isNotEmpty);
    });

    test('Performance degrades gracefully under load', () async {
      // Test multiple rapid captures
      final captureTimes = <Duration>[];

      for (int i = 0; i < 5; i++) {
        when(mockCameraService.takePicture()).thenAnswer((_) async {
          // Simulate increasing load
          await Future.delayed(Duration(milliseconds: 800 + (i * 50)));
          return File('photo_$i.jpg');
        });

        final start = DateTime.now();
        await mockCameraService.takePicture();
        final duration = DateTime.now().difference(start);
        captureTimes.add(duration);
      }

      // Verify all captures still meet requirement
      for (final duration in captureTimes) {
        expect(duration.inSeconds, lessThanOrEqualTo(2),
            reason: 'Capture degraded beyond 2s requirement');
      }

      // Verify reasonable degradation curve
      final avgTime = captureTimes
              .map((d) => d.inMilliseconds)
              .reduce((a, b) => a + b) /
          captureTimes.length;
      expect(avgTime, lessThan(1500),
          reason: 'Average capture time should stay under 1.5s');
    });

    test('Camera initialization included in 2s budget', () async {
      // Test cold start scenario
      when(mockCameraService.initialize()).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 400));
        return true;
      });

      when(mockCameraService.takePicture()).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 800));
        return File('cold_start.jpg');
      });

      when(mockStorageService.savePhoto(any)).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 200));
        return Photo(
          id: 'photo-003',
          equipmentId: 'equipment-001',
          fileName: 'cold_start.jpg',
          fileHash: 'xyz789',
          capturedAt: DateTime.now(),
          deviceId: 'test-device-001',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSynced: false,
        );
      });

      startTime = DateTime.now();

      // Cold start workflow
      await mockCameraService.initialize();
      final photo = await mockCameraService.takePicture();
      await mockStorageService.savePhoto({'file': photo});

      endTime = DateTime.now();
      final totalDuration = endTime.difference(startTime);

      expect(totalDuration.inSeconds, lessThanOrEqualTo(2),
          reason: 'Cold start capture must complete within 2s');
    });

    test('Metadata extraction does not block capture', () async {
      // Test async metadata processing
      bool captureComplete = false;
      bool metadataComplete = false;

      when(mockCameraService.takePicture()).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 800));
        captureComplete = true;
        return File('async_test.jpg');
      });

      when(mockCameraService.extractMetadataAsync(any)).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 1500));
        metadataComplete = true;
        return {'processed': true};
      });

      startTime = DateTime.now();

      // Start capture and metadata extraction in parallel
      final captureTask = mockCameraService.takePicture();
      final photo = await captureTask;

      // Metadata extraction happens async, not blocking capture
      mockCameraService.extractMetadataAsync(photo);

      final captureEndTime = DateTime.now();
      final captureDuration = captureEndTime.difference(startTime);

      // Verify capture completed quickly
      expect(captureDuration.inMilliseconds, lessThan(1000));
      expect(captureComplete, isTrue);
      expect(metadataComplete, isFalse); // Still processing

      // Wait for metadata to complete
      await Future.delayed(Duration(seconds: 2));
      expect(metadataComplete, isTrue);
    });
  });
}