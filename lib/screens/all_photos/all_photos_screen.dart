import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/photo.dart';
import '../../providers/all_photos_provider.dart';
import '../../widgets/photo_grid_tile.dart';

class AllPhotosScreen extends StatefulWidget {
  const AllPhotosScreen({super.key});

  @override
  State<AllPhotosScreen> createState() => _AllPhotosScreenState();
}

class _AllPhotosScreenState extends State<AllPhotosScreen>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AllPhotosProvider>();
      provider.loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _handleScroll() {
    if (!mounted) return;
    final provider = context.read<AllPhotosProvider>();
    if (!provider.hasMore ||
        provider.isLoadingMore ||
        provider.isLoading ||
        provider.isRefreshing) {
      return;
    }
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.extentAfter < 320) {
      provider.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('All Photos')),
      body: Consumer<AllPhotosProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.photos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.photos.isEmpty) {
            return _ErrorState(
              message: provider.error!,
              onRetry: () => provider.loadInitial(force: true),
            );
          }

          if (provider.photos.isEmpty) {
            return const _EmptyState();
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: provider.refresh,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (provider.error != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: _ErrorBanner(message: provider.error!),
                        ),
                      ),
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 0,
                        childAspectRatio: 1,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final photo = provider.photos[index];
                        return PhotoGridTile(
                          photo: photo,
                          cornerRadius: 0,
                          onTap: () => _openPhotoViewer(index, provider.photos),
                        );
                      }, childCount: provider.photos.length),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: provider.isLoadingMore
                              ? const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(),
                                )
                              : (provider.hasMore
                                  ? const SizedBox.shrink()
                                  : const Text(
                                      'Showing latest photos',
                                      style: TextStyle(color: Colors.grey),
                                    )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.isRefreshing)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openPhotoViewer(int index, List<Photo> photos) {
    context.push(
      '/photo-viewer',
      extra: {'photos': photos, 'initialIndex': index},
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No photos yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture new photos to populate the gallery.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Unable to load photos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
