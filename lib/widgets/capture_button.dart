import 'package:flutter/material.dart';

/// Large circular capture button for taking photos
class CaptureButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isDisabled;

  const CaptureButton({
    Key? key,
    required this.onPressed,
    required this.isDisabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FR-004: Large capture button (bottom-center)
        GestureDetector(
          onTap: isDisabled ? null : onPressed,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDisabled ? Colors.grey : Colors.white,
              border: Border.all(
                color: isDisabled ? Colors.grey.shade600 : Colors.grey.shade400,
                width: 4,
              ),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
          ),
        ),
        // FR-027b: Show limit message when disabled
        if (isDisabled)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Photo limit reached (20/20)',
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
