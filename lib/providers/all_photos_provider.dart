import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/photo.dart';
import 'app_state.dart';

/// Provider managing the global All Photos gallery state with pagination.
class AllPhotosProvider extends ChangeNotifier {
  AllPhotosProvider({int pageSize = 50}) : _pageSize = pageSize;

  /// Visible photo list (newest-first).
  final List<Photo> _photos = <Photo>[];

  /// Page size used for pagination; defaults aligned with research R0.1.
  final int _pageSize;

  AppState? _appState;
  bool _isLoadingInitial = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isInvalidated = false;
  String? _error;
  int _offset = 0;
  Future<void>? _ongoingInitialLoad;
  Future<void>? _ongoingPagination;

  /// Exposes an unmodifiable view of the current photos.
  UnmodifiableListView<Photo> get photos =>
      UnmodifiableListView<Photo>(_photos);

  bool get isLoading => _isLoadingInitial;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  int get pageSize => _pageSize;

  /// Updates the backing [AppState] dependency (wired via ChangeNotifierProxyProvider).
  void updateAppState(AppState appState) {
    _appState = appState;
  }

  /// Loads the first page unless data is already present and valid.
  Future<void> loadInitial({bool force = false}) async {
    if (_appState == null) {
      return;
    }
    if (_isRefreshing) {
      return;
    }

    if (!force && !_isInvalidated && _photos.isNotEmpty) {
      return;
    }

    if (_ongoingInitialLoad != null) {
      return _ongoingInitialLoad!;
    }

    final future = _performInitialLoad();
    _ongoingInitialLoad = future;
    await future;
    _ongoingInitialLoad = null;
  }

  /// Refreshes the gallery, resetting pagination.
  Future<void> refresh() async {
    if (_appState == null) {
      return;
    }
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _fetchPhotos(offset: 0);
      _photos
        ..clear()
        ..addAll(results);
      _offset = _photos.length;
      _hasMore = results.length == _pageSize;
      _isInvalidated = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isRefreshing = false;
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  /// Loads the next page if available.
  Future<void> loadMore() async {
    if (_appState == null) {
      return;
    }
    if (_isLoadingInitial || _isRefreshing || _isLoadingMore) {
      return;
    }
    if (!_hasMore) {
      return;
    }
    if (_ongoingPagination != null) {
      return _ongoingPagination!;
    }

    final future = _performPagination();
    _ongoingPagination = future;
    await future;
    _ongoingPagination = null;
  }

  /// Marks cache as stale so the next load fetches fresh data.
  void invalidate() {
    _isInvalidated = true;
    notifyListeners();
  }

  /// Removes a photo from the local cache by ID (used after deletions).
  void removePhoto(String photoId) {
    final originalLength = _photos.length;
    _photos.removeWhere((photo) => photo.id == photoId);
    if (_photos.length != originalLength) {
      _offset = _photos.length;
      _hasMore = true;
      notifyListeners();
    }
  }

  /// Inserts or replaces photos in cache (used when external flows add updates).
  void upsertPhotos(List<Photo> updated) {
    if (updated.isEmpty) {
      return;
    }
    final map = {for (final photo in _photos) photo.id: photo};
    for (final photo in updated) {
      map[photo.id] = photo;
    }
    final sorted = map.values.toList()
      ..sort((a, b) {
        final timestampCompare = b.timestamp.compareTo(a.timestamp);
        if (timestampCompare != 0) {
          return timestampCompare;
        }
        final createdCompare = b.createdAt.compareTo(a.createdAt);
        if (createdCompare != 0) {
          return createdCompare;
        }
        return b.id.compareTo(a.id);
      });
    _photos
      ..clear()
      ..addAll(sorted);
    _offset = _photos.length;
    notifyListeners();
  }

  Future<void> _performInitialLoad() async {
    _isLoadingInitial = true;
    _isRefreshing = false;
    _error = null;
    notifyListeners();

    try {
      final results = await _fetchPhotos(offset: 0);
      _photos
        ..clear()
        ..addAll(results);
      _offset = _photos.length;
      _hasMore = results.length == _pageSize;
      _isInvalidated = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> _performPagination() async {
    _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _fetchPhotos(offset: _offset);
      if (results.isEmpty) {
        _hasMore = false;
        return;
      }

      _photos.addAll(results);
      _offset = _photos.length;
      _hasMore = results.length == _pageSize;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<List<Photo>> _fetchPhotos({required int offset}) async {
    final appState = _appState;
    if (appState == null) {
      throw StateError('AppState not attached');
    }
    final results = await appState.getAllPhotos(
      limit: _pageSize,
      offset: offset,
    );
    return results;
  }
}
