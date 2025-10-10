import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/photo_folder.dart';
import '../models/photo.dart';
import '../models/folder_photo.dart';
import '../services/folder_service.dart';

class FolderProvider extends ChangeNotifier {
  final FolderService _folderService;

  List<PhotoFolder> _folders = [];
  bool _isLoading = false;
  String? _errorMessage;

  FolderProvider({FolderService? folderService})
    : _folderService = folderService ?? FolderService();

  List<PhotoFolder> get folders => _folders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Load all folders for an equipment
  Future<void> loadFolders(String equipmentId) async {
    _setLoading(true);
    _setError(null);

    try {
      _folders = await _folderService.getFolders(equipmentId);
      debugPrint('FolderProvider: Loaded ${_folders.length} folders for equipment $equipmentId');
      for (final folder in _folders) {
        debugPrint('  - ${folder.name} (${folder.id})');
      }
    } catch (e) {
      debugPrint('FolderProvider: Error loading folders: $e');
      _setError('Failed to load folders: $e');
      _folders = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new folder
  Future<PhotoFolder?> createFolder({
    required String equipmentId,
    required String workOrder,
    required String userId,
  }) async {
    _setError(null);

    try {
      // Validate work order
      if (workOrder.trim().isEmpty) {
        _setError('Work order cannot be empty');
        return null;
      }

      if (workOrder.length > 50) {
        _setError('Work order too long (max 50 characters)');
        return null;
      }

      final folder = await _folderService.createFolder(
        equipmentId: equipmentId,
        workOrder: workOrder.trim(),
        createdBy: userId,
      );

      // Reload folders to update the list
      await loadFolders(equipmentId);

      return folder;
    } catch (e) {
      _setError('Failed to create folder: $e');
      return null;
    }
  }

  /// Delete a folder
  Future<bool> deleteFolder({
    required String folderId,
    required String equipmentId,
    required bool deletePhotos,
  }) async {
    _setError(null);

    try {
      await _folderService.deleteFolder(
        folderId: folderId,
        deletePhotos: deletePhotos,
      );

      // Reload folders to update the list
      await loadFolders(equipmentId);

      return true;
    } catch (e) {
      _setError('Failed to delete folder: $e');
      return false;
    }
  }

  /// Get before photos for a folder
  Future<List<Photo>> getBeforePhotos(String folderId) async {
    try {
      return await _folderService.getBeforePhotos(folderId);
    } catch (e) {
      _setError('Failed to load before photos: $e');
      return [];
    }
  }

  /// Get after photos for a folder
  Future<List<Photo>> getAfterPhotos(String folderId) async {
    try {
      return await _folderService.getAfterPhotos(folderId);
    } catch (e) {
      _setError('Failed to load after photos: $e');
      return [];
    }
  }

  /// Get photo counts for a folder
  Future<Map<String, int>> getPhotoCountsForFolder(String folderId) async {
    try {
      return await _folderService.getPhotoCountsForFolder(folderId);
    } catch (e) {
      _setError('Failed to load photo counts: $e');
      return {'before': 0, 'after': 0};
    }
  }

  /// Add a photo to a folder
  Future<bool> addPhotoToFolder({
    required String folderId,
    required String photoId,
    required BeforeAfter beforeAfter,
  }) async {
    try {
      await _folderService.addPhotoToFolder(
        folderId: folderId,
        photoId: photoId,
        beforeAfter: beforeAfter,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add photo to folder: $e');
      return false;
    }
  }
}
