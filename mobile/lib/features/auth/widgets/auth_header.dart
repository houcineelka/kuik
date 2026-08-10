import 'package:flutter/material.dart';

import '../../../widgets/shared/spark_accent.dart';

/// Shared auth-screen header: an optional rounded back button and the
/// centered "Kuik" wordmark with its spark accent.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: onBack == null
              ? null
              : Material(
                  color: scheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onBack,
                    child: Icon(Icons.arrow_back, color: scheme.primary),
                  ),
                ),
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kuik',
                  style: textTheme.headlineMedium?.copyWith(color: scheme.primary, fontSize: 28),
                ),
                const SizedBox(width: 2),
                SparkAccent(size: 16, color: scheme.primary),
              ],
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}
