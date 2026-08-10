import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';

typedef _NavItem = ({IconData icon, IconData activeIcon, String label});

List<_NavItem> _items(AppLocalizations l10n) => [
      (icon: Icons.home_outlined, activeIcon: Icons.home, label: l10n.navHomeLabel),
      (icon: Icons.map_outlined, activeIcon: Icons.map, label: l10n.navMapLabel),
      (icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: l10n.navMyListingsLabel),
      (icon: Icons.bookmark_border, activeIcon: Icons.bookmark, label: l10n.navSavedLabel),
    ];

/// Floating pill-shaped bottom navigation with a small dot under the
/// active tab, matching the app's rounded, friendly visual language.
class KuikBottomNav extends StatelessWidget {
  const KuikBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final items = _items(context.l10n);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(LedgerSpacing.lg, 0, LedgerSpacing.lg, LedgerSpacing.sm),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == currentIndex,
                    label: items[i].label,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTap: () => onTap(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            i == currentIndex ? items[i].activeIcon : items[i].icon,
                            color: i == currentIndex ? scheme.primary : scheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i].label,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: i == currentIndex ? scheme.primary : scheme.onSurfaceVariant,
                              fontWeight: i == currentIndex ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: 4,
                            child: i == currentIndex
                                ? Container(width: 4, height: 4, decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle))
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
