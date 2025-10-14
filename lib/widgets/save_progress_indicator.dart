import 'package:flutter/material.dart';
import '../services/photo_save_service.dart';

/// Loading UI widget for multi-photo save operations
/// Shows progress bar and current status during incremental saves
class SaveProgressIndicator extends StatelessWidget {
  final Stream<SaveProgress> progressStream;
  final String? message;

  const SaveProgressIndicator({
    Key? key,
    required this.progressStream,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SaveProgress>(
      stream: progressStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message ?? 'Preparing to save...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        final progress = snapshot.data!;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 250,
                child: LinearProgressIndicator(
                  value: progress.percentage / 100,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Saving photo ${progress.current} of ${progress.total}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${progress.percentage.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Compact version for dialogs
class SaveProgressDialog extends StatelessWidget {
  final Stream<SaveProgress> progressStream;
  final String title;

  const SaveProgressDialog({
    Key? key,
    required this.progressStream,
    this.title = 'Saving Photos',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 300,
        height: 150,
        child: SaveProgressIndicator(progressStream: progressStream),
      ),
    );
  }
}
