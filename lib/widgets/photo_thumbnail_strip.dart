import 'package:flutter/material.dart';
import '../models/photo_session.dart';

/// Horizontal scrolling strip of photo thumbnails
class PhotoThumbnailStrip extends StatelessWidget {
  final List<TempPhoto> photos;
  final void Function(String photoId) onDeletePhoto;

  const PhotoThumbnailStrip({
    Key? key,
    required this.photos,
    required this.onDeletePhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Stack(
              children: [
                // FR-007: Thumbnail display
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: photo.thumbnailData != null
                        ? Image.memory(
                            photo.thumbnailData!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image, color: Colors.white),
                  ),
                ),
                // FR-009: X delete overlay
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => onDeletePhoto(photo.id),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
