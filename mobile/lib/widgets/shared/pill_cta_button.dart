import 'package:flutter/material.dart';

import 'spark_accent.dart';

/// The primary pill CTA button: full-width, a white circular icon badge
/// at the trailing edge, and small spark accents flanking the corners.
class PillCtaButton extends StatelessWidget {
  const PillCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon = Icons.arrow_forward,
    this.sparks = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData icon;
  final bool sparks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final button = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: Row(
          children: [
            const SizedBox(width: 40),
            Expanded(
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: scheme.onPrimary),
                      )
                    : Text(label),
              ),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: scheme.onPrimary,
              child: Icon(icon, color: scheme.primary, size: 18),
            ),
          ],
        ),
      ),
    );

    if (!sparks) return button;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          left: -8,
          top: -8,
          child: SparkAccent(size: 16, color: scheme.primary),
        ),
        Positioned(
          right: -8,
          top: -8,
          child: Transform.flip(flipX: true, child: SparkAccent(size: 16, color: scheme.primary)),
        ),
      ],
    );
  }
}
