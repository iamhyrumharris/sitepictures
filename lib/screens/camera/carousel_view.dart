import 'dart:io';
import 'package:flutter/material.dart';

/// Carousel view for browsing captured photos
/// Implements FR-008, FR-009
class PhotoCarouselView extends StatefulWidget {
  final List<String> photoPaths;
  final String equipmentId;
  final Function(int) onSave;

  const PhotoCarouselView({
    Key? key,
    required this.photoPaths,
    required this.equipmentId,
    required this.onSave,
  }) : super(key: key);

  @override
  State<PhotoCarouselView> createState() => _PhotoCarouselViewState();
}

class _PhotoCarouselViewState extends State<PhotoCarouselView> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Photo ${_currentIndex + 1} of ${widget.photoPaths.length}',
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _deleteCurrentPhoto,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete photo',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: widget.photoPaths.length,
              itemBuilder: (context, index) {
                return _buildPhotoPage(widget.photoPaths[index]);
              },
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildPhotoPage(String photoPath) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(photoPath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Quick save button (FR-009)
          ElevatedButton.icon(
            onPressed: () => _quickSave(),
            icon: const Icon(Icons.save),
            label: const Text('Quick Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(width: 16),
          // Next button (FR-010)
          ElevatedButton.icon(
            onPressed: _currentIndex < widget.photoPaths.length - 1
                ? _nextPhoto
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentIndex < widget.photoPaths.length - 1
                  ? Colors.green
                  : Colors.grey,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _previousPhoto() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPhoto() {
    if (_currentIndex < widget.photoPaths.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _quickSave() async {
    await widget.onSave(_currentIndex);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo saved successfully'),
        duration: Duration(seconds: 1),
      ),
    );

    // Move to next photo if available
    if (_currentIndex < widget.photoPaths.length - 1) {
      _nextPhoto();
    }
  }

  void _deleteCurrentPhoto() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              setState(() {
                widget.photoPaths.removeAt(_currentIndex);

                if (widget.photoPaths.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

                if (_currentIndex >= widget.photoPaths.length) {
                  _currentIndex = widget.photoPaths.length - 1;
                  _pageController = PageController(initialPage: _currentIndex);
                }
              });

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Photo deleted')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
