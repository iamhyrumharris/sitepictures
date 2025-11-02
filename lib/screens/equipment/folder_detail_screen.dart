import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../models/destination_context.dart';
import '../../models/equipment.dart';
import '../../models/import_batch.dart';
import '../../models/folder_photo.dart';
import '../../models/photo.dart';
import '../../models/site.dart';
import '../../providers/app_state.dart';
import '../../providers/folder_provider.dart';
import '../../providers/import_flow_provider.dart';
import '../../providers/needs_assigned_provider.dart';
import '../../services/database_service.dart';
import '../../services/import_service.dart';
import '../../services/photo_storage_service.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/import_progress_sheet.dart';
import '../../widgets/photo_delete_dialog.dart';
import '../../router.dart';

class FolderDetailScreen extends StatefulWidget {
  const FolderDetailScreen({
    super.key,
    required this.equipmentId,
    required this.folderId,
  });

  final String equipmentId;
  final String folderId;

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTabIndex = 0;
  List<Photo> _beforePhotos = <Photo>[];
  List<Photo> _afterPhotos = <Photo>[];
  bool _isLoading = true;
  String _folderName = '';
  Equipment? _equipment;
  Client? _client;
  MainSite? _mainSite;
  SubSite? _subSite;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _activeTabIndex = _tabController.index;
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadContext();
      await _loadPhotos();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    final newIndex = _tabController.index;
    if (newIndex != _activeTabIndex) {
      setState(() => _activeTabIndex = newIndex);
    }
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final folderProvider = context.read<FolderProvider>();
    final beforePhotos = await folderProvider.getBeforePhotos(widget.folderId);
    final afterPhotos = await folderProvider.getAfterPhotos(widget.folderId);

    if (!mounted) return;
    setState(() {
      _beforePhotos = beforePhotos;
      _afterPhotos = afterPhotos;
      _isLoading = false;
    });
  }

  Future<void> _loadContext() async {
    final appState = context.read<AppState>();
    final equipment = await appState.getEquipment(widget.equipmentId);

    Client? client;
    MainSite? mainSite;
    SubSite? subSite;

    if (equipment != null) {
      if (equipment.clientId != null) {
        client = await appState.getClient(equipment.clientId!);
      } else if (equipment.mainSiteId != null) {
        mainSite = await appState.getMainSite(equipment.mainSiteId!);
        if (mainSite != null) {
          client = await appState.getClient(mainSite.clientId);
        }
      } else if (equipment.subSiteId != null) {
        subSite = await appState.getSubSite(equipment.subSiteId!);
        if (subSite != null) {
          if (subSite.mainSiteId != null) {
            mainSite = await appState.getMainSite(subSite.mainSiteId!);
            if (mainSite != null) {
              client = await appState.getClient(mainSite.clientId);
            }
          } else if (subSite.clientId != null) {
            client = await appState.getClient(subSite.clientId!);
          }
        }
      }
    }

    final folderMap = await DatabaseService().getFolderById(widget.folderId);

    if (!mounted) return;
    setState(() {
      _equipment = equipment;
      _client = client;
      _mainSite = mainSite;
      _subSite = subSite;
      if (folderMap != null && folderMap['name'] is String) {
        _folderName = folderMap['name'] as String;
      }
    });
  }

  void _capturePhotos() async {
    final beforeAfter = _activeTabIndex == 0
        ? BeforeAfter.before
        : BeforeAfter.after;
    final contextStr = _activeTabIndex == 0
        ? 'equipment-before'
        : 'equipment-after';

    await context.push(
      '/camera-capture',
      extra: {
        'context': contextStr,
        'folderId': widget.folderId,
        'equipmentId': widget.equipmentId,
        'beforeAfter': beforeAfter.name,
      },
    );

    if (mounted) {
      await _loadPhotos();
    }
  }

  Future<void> _deletePhoto(Photo photo) async {
    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (context) => PhotoDeleteDialog(
        photoId: photo.id,
        onConfirm: () {
          confirmed = true;
        },
      ),
    );

    if (!confirmed) {
      return;
    }

    try {
      final dbService = DatabaseService();
      final db = await dbService.database;
      await db.delete('photos', where: 'id = ?', whereArgs: [photo.id]);

      final photoFile = PhotoStorageService.tryResolveLocalFile(photo.filePath);
      if (photoFile != null && await photoFile.exists()) {
        await photoFile.delete();
      }

      if (photo.thumbnailPath != null) {
        final thumbFile = PhotoStorageService.tryResolveLocalFile(
          photo.thumbnailPath!,
        );
        if (thumbFile != null && await thumbFile.exists()) {
          await thumbFile.delete();
        }
      }

      await _loadPhotos();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Photo deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleImport() async {
    if (_equipment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipment context unavailable.')),
      );
      return;
    }

    final choice = _activeTabIndex == 0
        ? BeforeAfterChoice.before
        : BeforeAfterChoice.after;
    final entryPoint = choice == BeforeAfterChoice.before
        ? ImportEntryPoint.equipmentBefore
        : ImportEntryPoint.equipmentAfter;

    final importFlow = context.read<ImportFlowProvider>();
    importFlow.configure(
      entryPoint: entryPoint,
      defaultDestination: _buildDestination(choice),
      beforeAfterChoice: choice,
      navigatorKey: AppRouter.router.routerDelegate.navigatorKey,
      initialPermissionState: importFlow.permissionState,
    );

    final result = await showImportProgressSheet(
      context,
      provider: importFlow,
      onStart: () => importFlow.startImport(pickerContext: context),
    );

    if (!mounted) return;

    if (result != null) {
      await _loadPhotos();
      final batch = result.batch;
      final summary =
          '${batch.importedCount} imported, ${batch.duplicateCount} duplicate(s) skipped, ${batch.failedCount} failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(summary)));
    } else if (importFlow.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(importFlow.errorMessage!)));
    }
  }

  DestinationContext _buildDestination(BeforeAfterChoice choice) {
    final equipment = _equipment!;
    final type = choice == BeforeAfterChoice.before
        ? DestinationType.equipmentBefore
        : DestinationType.equipmentAfter;

    final clientId =
        _client?.id ??
        equipment.clientId ??
        NeedsAssignedProvider.globalClientId;

    return DestinationContext(
      type: type,
      clientId: clientId,
      mainSiteId: _mainSite?.id ?? equipment.mainSiteId,
      subSiteId: _subSite?.id ?? equipment.subSiteId,
      equipmentId: equipment.id,
      folderId: widget.folderId,
      label: equipment.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_folderName.isEmpty ? 'Folder' : _folderName),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: _activeTabIndex == 0
                ? 'Import to Before'
                : 'Import to After',
            onPressed: _equipment == null ? null : _handleImport,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (_activeTabIndex != index) {
              setState(() => _activeTabIndex = index);
            }
          },
          tabs: [
            Tab(text: 'Before (${_beforePhotos.length})'),
            Tab(text: 'After (${_afterPhotos.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _BeforeAfterPhotoTab(
                  photos: _beforePhotos,
                  label: 'before',
                  onDeletePhoto: _deletePhoto,
                ),
                _BeforeAfterPhotoTab(
                  photos: _afterPhotos,
                  label: 'after',
                  onDeletePhoto: _deletePhoto,
                ),
              ],
            ),
      bottomNavigationBar: const BottomNav(currentIndex: -1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _capturePhotos,
        icon: const Icon(Icons.camera_alt),
        label: Text(
          _activeTabIndex == 0
              ? 'Capture Before Photos'
              : 'Capture After Photos',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _BeforeAfterPhotoTab extends StatefulWidget {
  const _BeforeAfterPhotoTab({
    required this.photos,
    required this.label,
    required this.onDeletePhoto,
  });

  final List<Photo> photos;
  final String label;
  final void Function(Photo) onDeletePhoto;

  @override
  State<_BeforeAfterPhotoTab> createState() => _BeforeAfterPhotoTabState();
}

class _BeforeAfterPhotoTabState extends State<_BeforeAfterPhotoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${widget.label} photos',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Tap camera to capture'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        childAspectRatio: 1,
      ),
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        final photo = widget.photos[index];
        return _buildPhotoTile(photo);
      },
    );
  }

  Widget _buildPhotoTile(Photo photo) {
    final photoIndex = widget.photos.indexOf(photo);

    return GestureDetector(
      onTap: () {
        context.push(
          '/photo-viewer',
          extra: {'photos': widget.photos, 'initialIndex': photoIndex},
        );
      },
      onLongPress: () => _showPhotoContextMenu(photo),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildPhotoImage(photo),
        ),
      ),
    );
  }

  Widget _buildPhotoImage(Photo photo) {
    final imagePath = photo.thumbnailPath ?? photo.filePath;
    final localFile = PhotoStorageService.tryResolveLocalFile(imagePath);

    if (localFile != null) {
      return Image.file(
        localFile,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image, size: 40, color: Colors.grey),
      );
    }

    if (photo.remoteUrl != null && photo.remoteUrl!.isNotEmpty) {
      return Image.network(
        photo.remoteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) =>
            const Icon(Icons.image, size: 40, color: Colors.grey),
      );
    }

    return const Icon(Icons.image, size: 40, color: Colors.grey);
  }

  void _showPhotoContextMenu(Photo photo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Photo'),
              onTap: () {
                Navigator.pop(context);
                widget.onDeletePhoto(photo);
              },
            ),
          ],
        ),
      ),
    );
  }
}
