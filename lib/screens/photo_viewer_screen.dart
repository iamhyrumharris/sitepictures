import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/photo.dart';
import '../widgets/photo_delete_dialog.dart';
import '../services/database_service.dart';

/// Full-screen photo viewer with swipe navigation
/// Supports viewing multiple photos with carousel navigation,
/// pinch-to-zoom, and photo deletion
class PhotoViewerScreen extends StatefulWidget {
  final List<Photo> photos;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    this.initialIndex = 0,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late CarouselSliderController _carouselController;
  late List<Photo> _photos;
  int _currentIndex = 0;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
    _photos = List.from(widget.photos);
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) {
      // No photos left after deletions
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main photo carousel
          GestureDetector(
            onTap: () {
              setState(() {
                _showOverlay = !_showOverlay;
              });
            },
            child: Center(
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: _photos.length,
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  initialPage: _currentIndex,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return _buildPhotoPage(_photos[index]);
                },
              ),
            ),
          ),

          // Top overlay (app bar)
          if (_showOverlay)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopOverlay(),
            ),

          // Bottom overlay (photo info)
          if (_showOverlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomOverlay(),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoPage(Photo photo) {
    // Use full resolution photo, fallback to thumbnail if full photo not available
    final imagePath = photo.filePath;
    final imageFile = File(imagePath);

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: FutureBuilder<bool>(
          future: imageFile.exists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: Colors.white,
              );
            }

            if (snapshot.hasData && snapshot.data == true) {
              return Image.file(
                imageFile,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget();
                },
              );
            }

            return _buildErrorWidget();
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Photo ${_currentIndex + 1} of ${_photos.length}',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteCurrentPhoto,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomOverlay() {
    final photo = _photos[_currentIndex];
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date/Time
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(photo.timestamp),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${photo.latitude.toStringAsFixed(6)}, ${photo.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Folder info (if applicable)
              if (photo.folderName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.folder, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      photo.folderName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    if (photo.beforeAfter != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: photo.beforeAfter!.name == 'before'
                              ? Colors.blue
                              : Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          photo.beforeAfter!.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // File size
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.image, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _formatFileSize(photo.fileSize),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _deleteCurrentPhoto() async {
    final photo = _photos[_currentIndex];
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

    if (confirmed) {
      try {
        final dbService = DatabaseService();
        final db = await dbService.database;

        // Delete photo record from database
        await db.delete('photos', where: 'id = ?', whereArgs: [photo.id]);

        // Delete photo files from storage
        try {
          final photoFile = File(photo.filePath);
          if (await photoFile.exists()) {
            await photoFile.delete();
          }

          if (photo.thumbnailPath != null) {
            final thumbnailFile = File(photo.thumbnailPath!);
            if (await thumbnailFile.exists()) {
              await thumbnailFile.delete();
            }
          }
        } catch (e) {
          debugPrint('Error deleting photo files: $e');
        }

        // Remove from local list
        setState(() {
          _photos.removeAt(_currentIndex);

          // If no photos left, pop the screen
          if (_photos.isEmpty) {
            Navigator.of(context).pop();
            return;
          }

          // Adjust index if needed
          if (_currentIndex >= _photos.length) {
            _currentIndex = _photos.length - 1;
          }

          // Update carousel to show correct photo
          if (_photos.isNotEmpty) {
            _carouselController.animateToPage(_currentIndex);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo deleted'),
              duration: Duration(seconds: 2),
            ),
          );
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
  }
}
