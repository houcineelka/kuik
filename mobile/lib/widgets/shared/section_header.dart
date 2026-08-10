import 'package:flutter/material.dart';

import '../../l10n/app_localizations_x.dart';

/// A bold section title with a short accent underline, and an optional
/// "Voir tout" link.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: textTheme.headlineMedium?.copyWith(fontSize: 22)),
              const SizedBox(height: 4),
              Container(
                width: 56,
                height: 3,
                decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.sectionHeaderSeeAllLabel),
                Icon(Icons.chevron_right, size: 18, color: scheme.secondary),
              ],
            ),
          ),
      ],
    );
  }
}
