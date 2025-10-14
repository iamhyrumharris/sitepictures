import 'package:flutter/foundation.dart';
import '../models/client.dart';
import '../models/photo.dart';
import '../models/photo_folder.dart';
import '../services/database_service.dart';

/// Provider for managing global "Needs Assigned" functionality
class NeedsAssignedProvider extends ChangeNotifier {
  final DatabaseService _db;

  // Global "Needs Assigned" state
  Client? _globalClient;
  List<Photo> _globalPhotos = [];
  List<PhotoFolder> _globalFolders = [];

  // Loading and error state
  bool _isLoading = false;
  String? _errorMessage;

  // Constant for global client ID
  static const String globalClientId = 'GLOBAL_NEEDS_ASSIGNED';

  NeedsAssignedProvider({DatabaseService? databaseService})
      : _db = databaseService ?? DatabaseService();

  // Getters
  Client? get globalClient => _globalClient;
  List<Photo> get globalPhotos => _globalPhotos;
  List<PhotoFolder> get globalFolders => _globalFolders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// T054: Load global "Needs Assigned" data (photos and folders)
  Future<void> loadGlobalNeedsAssigned() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final db = await _db.database;

      // Load global client
      final clientMaps = await db.query(
        'clients',
        where: 'id = ?',
        whereArgs: [globalClientId],
      );

      if (clientMaps.isEmpty) {
        throw Exception('Global "Needs Assigned" client not found. Run database migration 004.');
      }

      _globalClient = Client.fromMap(clientMaps.first);

      // Load photos in global "Needs Assigned"
      // Photos are stored under equipment that belongs to global client
      final photoMaps = await db.rawQuery('''
        SELECT p.* FROM photos p
        JOIN equipment e ON p.equipment_id = e.id
        WHERE e.client_id = ?
        ORDER BY p.timestamp DESC
      ''', [globalClientId]);

      _globalPhotos = photoMaps.map((map) => Photo.fromMap(map)).toList();

      // Load folders in global "Needs Assigned"
      final folderMaps = await db.rawQuery('''
        SELECT pf.* FROM photo_folders pf
        JOIN equipment e ON pf.equipment_id = e.id
        WHERE e.client_id = ?
        AND pf.is_deleted = 0
        ORDER BY pf.created_at DESC
      ''', [globalClientId]);

      _globalFolders = folderMaps.map((map) => PhotoFolder.fromMap(map)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint('Error loading global Needs Assigned: $e');
    }
  }

  /// Filter out system clients from client list
  List<Client> filterUserClients(List<Client> clients) {
    return clients.where((client) => !client.isSystem).toList();
  }

  /// Helper: Check if photo is in any folder
  bool _isPhotoInAnyFolder(String photoId, List<PhotoFolder> folders) {
    // This is a simplified check - in production would query folder_photos table
    // For now, return false to show all photos
    return false;
  }

  /// Helper: Get photo IDs for a folder
  Future<List<String>> _getFolderPhotoIds(String folderId) async {
    try {
      final db = await _db.database;
      final maps = await db.query(
        'folder_photos',
        columns: ['photo_id'],
        where: 'folder_id = ?',
        whereArgs: [folderId],
      );
      return maps.map((m) => m['photo_id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting folder photo IDs: $e');
      return [];
    }
  }
}
