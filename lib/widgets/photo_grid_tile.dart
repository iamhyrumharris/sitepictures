import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/photo.dart';
import '../services/photo_storage_service.dart';
import 'folder_badge.dart';

/// Grid tile widget shared between equipment tabs and the All Photos gallery.
class PhotoGridTile extends StatelessWidget {
  PhotoGridTile({
    super.key,
    required this.photo,
    this.onTap,
    this.onLongPress,
    this.showMetadata = false,
    this.cornerRadius = 0,
  });

  final Photo photo;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showMetadata;
  final double cornerRadius;

  static final DateFormat _timestampFormat = DateFormat('MMM d, yyyy • h:mm a');

  @override
  Widget build(BuildContext context) {
    final metadata = _buildMetadata();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'photo-${photo.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(cornerRadius),
              child: _buildImage(),
            ),
          ),
          if (photo.folderId != null && photo.folderName != null)
            Positioned(
              top: 8,
              left: 8,
              child: FolderBadge(folderName: photo.folderName!),
            ),
          if (metadata != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: metadata,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final imagePath = photo.thumbnailPath ?? photo.filePath;
    final localFile = PhotoStorageService.tryResolveLocalFile(imagePath);

    if (localFile != null) {
      return Image.file(
        localFile,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (photo.remoteUrl != null && photo.remoteUrl!.isNotEmpty) {
            return Image.network(
              photo.remoteUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => _buildFallback(),
            );
          }
          return _buildFallback();
        },
      );
    }

    if (photo.remoteUrl != null && photo.remoteUrl!.isNotEmpty) {
      return Image.network(
        photo.remoteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => _buildFallback(),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white70,
      ),
    );
  }

  Widget? _buildMetadata() {
    if (!showMetadata) {
      return null;
    }

    final location = photo.locationSummary?.trim();
    final equipment = photo.equipmentName?.trim();
    final lines = <String>[
      if (location != null && location.isNotEmpty) location,
      if (equipment != null && equipment.isNotEmpty) equipment,
      _timestampFormat.format(photo.timestamp),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines
          .map(
            (line) => Text(
              line,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
