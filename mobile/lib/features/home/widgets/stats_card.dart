import 'package:flutter/material.dart';

import '../../../theme/spacing.dart';

class StatItem {
  const StatItem({required this.icon, required this.iconBackground, required this.iconColor, required this.value, required this.label});

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final int value;
  final String label;
}

/// A row of stat cells (icon badge + number + label) separated by thin
/// dividers, in a single card.
class StatsCard extends StatelessWidget {
  const StatsCard({super.key, required this.items});

  final List<StatItem> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: LedgerSpacing.lg, horizontal: LedgerSpacing.sm),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i != 0)
                Container(
                  width: 1,
                  height: 36,
                  color: scheme.outlineVariant,
                  margin: const EdgeInsets.symmetric(horizontal: LedgerSpacing.xs),
                ),
              Expanded(child: _StatCell(item: items[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.item});

  final StatItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: item.iconBackground, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(item.icon, color: item.iconColor, size: 18),
        ),
        const SizedBox(width: LedgerSpacing.sm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${item.value}', style: textTheme.titleLarge?.copyWith(fontSize: 20)),
              Text(item.label, style: textTheme.bodySmall, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}
