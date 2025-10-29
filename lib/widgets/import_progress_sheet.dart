import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/import_flow_provider.dart';
import '../services/import_service.dart';

Future<ImportResult?> showImportProgressSheet(
  BuildContext context, {
  required ImportFlowProvider provider,
  required Future<ImportResult?> Function() onStart,
}) {
  return showModalBottomSheet<ImportResult?>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (sheetContext) {
      return ChangeNotifierProvider.value(
        value: provider,
        child: _ImportProgressSheet(onStart: onStart),
      );
    },
  );
}

class _ImportProgressSheet extends StatefulWidget {
  const _ImportProgressSheet({required this.onStart});

  final Future<ImportResult?> Function() onStart;

  @override
  State<_ImportProgressSheet> createState() => _ImportProgressSheetState();
}

class _ImportProgressSheetState extends State<_ImportProgressSheet> {
  ImportProgress? _progress;
  ImportResult? _result;
  String? _error;
  StreamSubscription<ImportProgress>? _subscription;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(_launchImport);
  }

  Future<void> _launchImport() async {
    final provider = context.read<ImportFlowProvider>();
    _subscription = provider.progress().listen((event) {
      setState(() => _progress = event);
    });
    try {
      final result = await widget.onStart();
      if (!mounted) return;
      setState(() {
        _result = result ?? provider.lastResult;
        _completed = provider.state == ImportFlowState.completed;
        _error = provider.state == ImportFlowState.error
            ? provider.errorMessage
            : null;
      });
      if (!mounted) {
        return;
      }
      if (_completed) {
        Navigator.of(context).pop(_result);
        return;
      }
      if (_error == null && result == null) {
        Navigator.of(context).pop(null);
        return;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ImportFlowProvider>();

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(
          context,
        ).viewInsets.add(const EdgeInsets.all(16)),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Importing photos', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              if (!_completed && _error == null) ...[
                _buildProgressContent(provider),
              ] else if (_error != null) ...[
                _buildErrorContent(theme),
              ] else ...[
                _buildResultSummary(theme, provider),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressContent(ImportFlowProvider provider) {
    final progress = _progress;
    final total = progress?.total ?? 0;
    final processed = progress?.processed ?? 0;
    final percent = total == 0 ? 0.0 : processed / total;
    final elapsed = _formatElapsed(progress?.elapsedMilliseconds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: total == 0 ? null : percent),
        const SizedBox(height: 8),
        Text('${processed.clamp(0, total)}/$total photos processed'),
        if (elapsed != null)
          Text('Elapsed: $elapsed', style: const TextStyle(color: Colors.grey)),
        if (progress?.currentAssetId != null)
          Text(
            'Current asset: ${progress!.currentAssetId}',
            style: const TextStyle(color: Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 16),
        const Text('Keep this sheet open while the import completes.'),
      ],
    );
  }

  Widget _buildErrorContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error ?? 'Import failed',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(_result),
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSummary(ThemeData theme, ImportFlowProvider provider) {
    final batch = provider.lastBatch;
    final imported = batch?.importedCount ?? 0;
    final duplicates = batch?.duplicateCount ?? 0;
    final failed = batch?.failedCount ?? 0;
    final elapsed = _formatElapsed(_progress?.elapsedMilliseconds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Import complete', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Imported: $imported'),
        Text('Duplicates skipped: $duplicates'),
        Text('Failed: $failed'),
        if (elapsed != null) Text('Elapsed: $elapsed'),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(_result),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  String? _formatElapsed(int? milliseconds) {
    if (milliseconds == null) {
      return null;
    }
    final duration = Duration(milliseconds: milliseconds);
    final seconds = duration.inSeconds;
    if (seconds < 60) {
      return '$seconds s';
    }
    final minutes = duration.inMinutes;
    final remSeconds = seconds - minutes * 60;
    return '${minutes}m ${remSeconds}s';
  }
}
