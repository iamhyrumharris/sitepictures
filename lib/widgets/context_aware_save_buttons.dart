import 'package:flutter/material.dart';
import '../models/camera_context.dart';

/// Renders context-aware save buttons on camera Done tap
class ContextAwareSaveButtons extends StatelessWidget {
  final CameraContext cameraContext;
  final VoidCallback onNext; // Home context
  final VoidCallback onQuickSave; // Home context
  final VoidCallback onEquipmentSave; // Equipment all photos context
  final VoidCallback onBeforeSave; // Equipment before context
  final VoidCallback onAfterSave; // Equipment after context

  const ContextAwareSaveButtons({
    super.key,
    required this.cameraContext,
    required this.onNext,
    required this.onQuickSave,
    required this.onEquipmentSave,
    required this.onBeforeSave,
    required this.onAfterSave,
  });

  @override
  Widget build(BuildContext context) {
    switch (cameraContext.type) {
      case CameraContextType.home:
        return _buildHomeButtons(context);

      case CameraContextType.equipmentAllPhotos:
        return _buildEquipmentButton(context);

      case CameraContextType.equipmentBefore:
        return _buildBeforeButton(context);

      case CameraContextType.equipmentAfter:
        return _buildAfterButton(context);
    }
  }

  /// Home context: Modal with "Next" and "Quick Save" buttons
  Widget _buildHomeButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Next',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onQuickSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Quick Save',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  /// Equipment all photos context: Single "Save to Equipment" button
  Widget _buildEquipmentButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onEquipmentSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Save to Equipment',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Equipment before context: Single "Capture as Before" button
  Widget _buildBeforeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onBeforeSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Capture as Before',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Equipment after context: Single "Capture as After" button
  Widget _buildAfterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onAfterSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Capture as After',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
