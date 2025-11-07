# Serverpod Integration Usage Guide

This guide shows how to use the Serverpod client in your Flutter app.

## 1. Initialize the Client

In your `main.dart`, initialize the Serverpod client before running the app:

```dart
import 'package:flutter/material.dart';
import 'services/serverpod_client_service.dart';

void main() {
  // Initialize Serverpod client
  ServerpodClientService().initialize(
    serverUrl: 'http://localhost:8080', // Change for production
  );

  runApp(const MyApp());
}
```

## 2. Authentication

### Login
```dart
import 'package:sitepictures_server_client/sitepictures_server_client.dart';
import 'services/serverpod_client_service.dart';

class AuthService {
  final client = ServerpodClientService().client;

  Future<User?> login(String email, String password) async {
    try {
      final user = await client.auth.login(email, password);
      return user;
    } catch (e) {
      print('Login failed: $e');
      return null;
    }
  }

  Future<User?> register(String email, String name, String password, String role) async {
    try {
      final user = await client.auth.register(email, name, password, role);
      return user;
    } catch (e) {
      print('Registration failed: $e');
      return null;
    }
  }

  Future<User?> getCurrentUser(String uuid) async {
    return await client.auth.getCurrentUser(uuid);
  }
}
```

## 3. Company Management

```dart
import 'services/serverpod_client_service.dart';

class CompanyService {
  final client = ServerpodClientService().client;

  // Get all companies
  Future<List<Company>> getAllCompanies() async {
    return await client.company.getAllCompanies(includeSystem: false);
  }

  // Get single company
  Future<Company?> getCompany(String uuid) async {
    return await client.company.getCompanyByUuid(uuid);
  }

  // Create company
  Future<Company> createCompany(String name, String? description, String createdBy) async {
    return await client.company.createCompany(name, description, createdBy);
  }

  // Update company
  Future<Company> updateCompany(String uuid, String name, String? description) async {
    return await client.company.updateCompany(uuid, name, description);
  }

  // Delete company (soft delete)
  Future<void> deleteCompany(String uuid) async {
    await client.company.deleteCompany(uuid);
  }
}
```

## 4. Site Management

```dart
class SiteService {
  final client = ServerpodClientService().client;

  // Main Sites
  Future<List<MainSite>> getMainSites(String clientId) async {
    return await client.site.getMainSitesByCompany(clientId);
  }

  Future<MainSite> createMainSite(
    String clientId,
    String name,
    String? address,
    double? latitude,
    double? longitude,
    String createdBy,
  ) async {
    return await client.site.createMainSite(
      clientId,
      name,
      address,
      latitude,
      longitude,
      createdBy,
    );
  }

  // Sub Sites
  Future<List<SubSite>> getSubSitesByMainSite(String mainSiteId) async {
    return await client.site.getSubSitesByParent(mainSiteId: mainSiteId);
  }

  Future<SubSite> createSubSite(
    String name,
    String? description,
    String createdBy, {
    String? clientId,
    String? mainSiteId,
  }) async {
    return await client.site.createSubSite(
      name,
      description,
      createdBy,
      clientId: clientId,
      mainSiteId: mainSiteId,
    );
  }
}
```

## 5. Equipment Management

```dart
class EquipmentService {
  final client = ServerpodClientService().client;

  Future<List<Equipment>> getEquipmentByClient(String clientId) async {
    return await client.equipment.getEquipmentByParent(clientId: clientId);
  }

  Future<Equipment> createEquipment(
    String name,
    String? serialNumber,
    String? manufacturer,
    String? model,
    String createdBy, {
    required String clientId,
  }) async {
    return await client.equipment.createEquipment(
      name,
      serialNumber,
      manufacturer,
      model,
      createdBy,
      clientId: clientId,
    );
  }
}
```

## 6. Photo Upload

```dart
import 'dart:typed_data';
import 'dart:io';

class PhotoService {
  final client = ServerpodClientService().client;

  // Upload photo with file
  Future<Photo> uploadPhoto(
    String equipmentId,
    File photoFile,
    double latitude,
    double longitude,
    DateTime timestamp,
    String capturedBy,
  ) async {
    // Read file as bytes
    final bytes = await photoFile.readAsBytes();
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));

    return await client.photo.uploadPhoto(
      equipmentId,
      byteData,
      photoFile.path.split('/').last, // filename
      latitude,
      longitude,
      timestamp,
      capturedBy,
      'camera',
    );
  }

  // Get photos for equipment (paginated)
  Future<List<Photo>> getPhotos(String equipmentId, {int limit = 50, int offset = 0}) async {
    return await client.photo.getPhotosByEquipment(equipmentId, limit: limit, offset: offset);
  }

  // Get download URL for photo
  Future<String?> getPhotoUrl(String photoUuid) async {
    return await client.photo.getPhotoUrl(photoUuid);
  }

  // Delete photo
  Future<void> deletePhoto(String photoUuid) async {
    await client.photo.deletePhoto(photoUuid);
  }
}
```

## 7. Folder Management

```dart
class FolderService {
  final client = ServerpodClientService().client;

  Future<List<PhotoFolder>> getFolders(String equipmentId) async {
    return await client.folder.getFoldersByEquipment(equipmentId);
  }

  Future<PhotoFolder> createFolder(
    String equipmentId,
    String name,
    String workOrder,
    String createdBy,
  ) async {
    return await client.folder.createFolder(equipmentId, name, workOrder, createdBy);
  }

  Future<FolderPhoto> addPhotoToFolder(
    String folderId,
    String photoId,
    String beforeAfter, // 'before' or 'after'
  ) async {
    return await client.folder.addPhotoToFolder(folderId, photoId, beforeAfter);
  }

  Future<List<FolderPhoto>> getPhotosInFolder(String folderId) async {
    return await client.folder.getPhotosInFolder(folderId);
  }
}
```

## 8. Sync Operations

```dart
import 'services/serverpod_sync_service.dart';

class SyncManager {
  final syncService = ServerpodSyncService();

  Future<void> performSync() async {
    if (syncService.isSyncing) {
      print('Sync already in progress');
      return;
    }

    final results = await syncService.performSync();

    if (results.containsKey('error')) {
      print('Sync failed: ${results['error']}');
    } else {
      print('Sync complete:');
      print('  Pulled: ${results['pulled']} items');
      print('  Pushed: ${results['pushed']} items');
      print('  Conflicts: ${results['conflicts']}');
    }
  }

  bool get isSyncing => syncService.isSyncing;
  DateTime? get lastSyncTime => syncService.lastSyncTime;
}
```

## 9. Error Handling

All Serverpod calls can throw exceptions. Wrap them in try-catch:

```dart
try {
  final companies = await client.company.getAllCompanies();
  // Success
} on ServerpodClientException catch (e) {
  print('API error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
```

## 10. Widget Example

Here's a complete widget example:

```dart
import 'package:flutter/material.dart';
import 'package:sitepictures_server_client/sitepictures_server_client.dart';
import 'services/serverpod_client_service.dart';

class CompanyListScreen extends StatefulWidget {
  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final client = ServerpodClientService().client;
  List<Company> companies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() => isLoading = true);

    try {
      final result = await client.company.getAllCompanies();
      setState(() {
        companies = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load companies: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: companies.length,
      itemBuilder: (context, index) {
        final company = companies[index];
        return ListTile(
          title: Text(company.name),
          subtitle: Text(company.description ?? 'No description'),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            // Navigate to company details
          },
        );
      },
    );
  }
}
```

## Notes

- **Offline Support**: SQLite database still used for offline storage
- **Sync Queue**: Local changes are queued and synced when online
- **Type Safety**: All models are type-safe with generated Dart classes
- **File Storage**: Photos stored on server with temporary download URLs
- **Authentication**: Store user UUID in secure storage for session management
