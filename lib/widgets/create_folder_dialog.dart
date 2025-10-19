import 'package:flutter/material.dart';

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController _controller = TextEditingController();
  final int _maxLength = 50;
  bool _isValid = false;
  bool _hasInvalidCharacters = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    _controller.dispose();
    super.dispose();
  }

  void _validateInput() {
    final trimmed = _controller.text.trim();
    final sanitized = _sanitizeInput(trimmed);

    setState(() {
      _isValid = sanitized.isNotEmpty;
      _hasInvalidCharacters = trimmed.isNotEmpty && sanitized.isEmpty;
    });
  }

  String _sanitizeInput(String input) {
    // Allow alphanumeric + -, _, #, /
    return input.replaceAll(RegExp(r'[^\w\s\-_#/]'), '');
  }

  void _handleCreate() {
    final trimmed = _controller.text.trim();
    final sanitized = _sanitizeInput(trimmed);

    if (sanitized.isEmpty) {
      setState(() {
        _isValid = false;
        _hasInvalidCharacters = trimmed.isNotEmpty;
      });
      return;
    }

    Navigator.of(context).pop(sanitized);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Folder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter work order or job number:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: _maxLength,
            decoration: InputDecoration(
              hintText: 'e.g., WO-789',
              border: const OutlineInputBorder(),
              counterText: '${_controller.text.length}/$_maxLength',
              errorText: _hasInvalidCharacters
                  ? 'Use letters, numbers, spaces, -, _, #, or /.'
                  : null,
            ),
            onSubmitted: (_) => _handleCreate(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isValid ? _handleCreate : null,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
