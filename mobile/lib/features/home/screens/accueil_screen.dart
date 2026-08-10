import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/locale_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/shared/section_header.dart';
import '../../../widgets/shared/skyline_illustration.dart';
import '../../../widgets/shared/spark_accent.dart';
import '../../auth/providers/auth_providers.dart';
import '../../claims/providers/claims_provider.dart';
import '../../listings/providers/my_listings_provider.dart';
import '../../listings/providers/nearby_listings_provider.dart';
import '../../listings/widgets/listing_card.dart';
import '../../conversations/providers/conversations_provider.dart';
import '../../matches/providers/matches_provider.dart';
import '../widgets/stats_card.dart';

class AccueilScreen extends ConsumerWidget {
  const AccueilScreen({super.key, required this.onSeeMap});

  final VoidCallback onSeeMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).valueOrNull;
    final myListings = ref.watch(myListingsProvider);
    final nearby = ref.watch(nearbyListingsProvider);
    final matchCount = ref.watch(matchesControllerProvider).valueOrNull?.length ?? 0;
    final unreadCount = ref.watch(totalUnreadCountProvider);
    final claimCount = ref.watch(claimsControllerProvider).valueOrNull?.length ?? 0;

    final lostCount = myListings.valueOrNull?.where((l) => l.isLost).length ?? 0;
    final foundCount = myListings.valueOrNull?.where((l) => !l.isLost).length ?? 0;
    final totalCount = myListings.valueOrNull?.length ?? 0;
    final hasActiveLost = myListings.valueOrNull?.any((l) => l.isLost && l.isActive) ?? false;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myListingsProvider);
          ref.invalidate(nearbyListingsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(LedgerSpacing.xl, LedgerSpacing.md, LedgerSpacing.xl, LedgerSpacing.xxxl),
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Text('Kuik', style: textTheme.headlineMedium?.copyWith(color: scheme.primary, fontSize: 24)),
                    const SizedBox(width: 2),
                    SparkAccent(size: 14, color: scheme.primary),
                  ],
                ),
                const Spacer(),
                _HeaderIconButton(
                  icon: Icons.notifications_outlined,
                  badgeCount: matchCount,
                  onTap: () => context.push('/matches'),
                ),
                const SizedBox(width: LedgerSpacing.sm),
                _HeaderIconButton(
                  icon: Icons.fact_check_outlined,
                  badgeCount: claimCount,
                  onTap: () => context.push('/claims'),
                ),
                const SizedBox(width: LedgerSpacing.sm),
                _HeaderIconButton(
                  icon: Icons.chat_bubble_outline,
                  badgeCount: unreadCount,
                  onTap: () => context.push('/conversations'),
                ),
                const SizedBox(width: LedgerSpacing.sm),
                PopupMenuButton<String>(
                  tooltip: l10n.accueilProfileTooltip,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) async {
                    if (value == 'language') {
                      await showDialog<void>(context: context, builder: (_) => const _LanguageDialog());
                    } else if (value == 'logout') {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'language',
                      child: Row(
                        children: [
                          Icon(Icons.language, size: 18, color: scheme.onSurfaceVariant),
                          const SizedBox(width: LedgerSpacing.sm),
                          Text(l10n.accueilLanguageMenuItem),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18, color: scheme.error),
                          const SizedBox(width: LedgerSpacing.sm),
                          Text(l10n.accueilLogoutMenuItem),
                        ],
                      ),
                    ),
                  ],
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: scheme.primaryContainer,
                        backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                        child: user?.avatarUrl == null
                            ? Icon(Icons.person_outline, color: scheme.onPrimaryContainer)
                            : null,
                      ),
                      if (hasActiveLost)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: scheme.surfaceContainerLowest, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: LedgerSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: textTheme.displayLarge?.copyWith(fontSize: 40),
                          children: [
                            TextSpan(text: l10n.accueilGreeting),
                            TextSpan(text: ' !', style: TextStyle(color: scheme.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: LedgerSpacing.xs),
                      Text(
                        l10n.accueilSubtitle,
                        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                SkylineIllustration(size: 110, pinColor: scheme.primary),
              ],
            ),
            const SizedBox(height: LedgerSpacing.xl),
            _SearchBar(l10n: l10n, onTap: () => context.push('/search')),
            const SizedBox(height: LedgerSpacing.lg),
            StatsCard(
              items: [
                StatItem(
                  icon: Icons.inventory_2_outlined,
                  iconBackground: scheme.primaryContainer,
                  iconColor: scheme.onPrimaryContainer,
                  value: totalCount,
                  label: l10n.accueilStatObjectsLabel,
                ),
                StatItem(
                  icon: Icons.notifications_outlined,
                  iconBackground: scheme.primaryContainer,
                  iconColor: scheme.onPrimaryContainer,
                  value: lostCount,
                  label: l10n.accueilStatLostLabel,
                ),
                StatItem(
                  icon: Icons.check_circle_outline,
                  iconBackground: scheme.secondaryContainer,
                  iconColor: scheme.onSecondaryContainer,
                  value: foundCount,
                  label: l10n.accueilStatFoundLabel,
                ),
              ],
            ),
            const SizedBox(height: LedgerSpacing.xl),
            SectionHeader(title: l10n.accueilNearbySectionTitle, onSeeAll: onSeeMap),
            const SizedBox(height: LedgerSpacing.lg),
            nearby.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: LedgerSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Text(
                l10n.accueilNearbyLoadError,
                style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              data: (result) => result.listings.isEmpty
                  ? Text(
                      l10n.accueilNearbyEmptyState,
                      style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    )
                  : Column(
                      children: [
                        for (final listing in result.listings.take(3)) ...[
                          ListingCard(listing: listing, onTap: () => context.push('/listings/${listing.id}')),
                          const SizedBox(height: LedgerSpacing.md),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: LedgerSpacing.lg),
            _DeclareCta(label: l10n.accueilDeclareCtaLabel, onTap: () => context.push('/declare')),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap, this.badgeCount = 0});

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: scheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Icon(icon, color: scheme.primary),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.surfaceContainerLowest, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.l10n, required this.onTap});

  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: LedgerSpacing.lg, vertical: LedgerSpacing.md),
          child: Row(
            children: [
              Icon(Icons.search, color: scheme.onSurface),
              const SizedBox(width: LedgerSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.accueilSearchBarTitle, style: textTheme.titleMedium),
                    Text(
                      l10n.accueilSearchBarSubtitle,
                      style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.primary,
                child: Icon(Icons.search, color: scheme.onPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeclareCta extends StatelessWidget {
  const _DeclareCta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 14, backgroundColor: scheme.onPrimary, child: Icon(Icons.add, color: scheme.primary, size: 18)),
                const SizedBox(width: LedgerSpacing.md),
                Text(label),
              ],
            ),
          ),
        ),
        Positioned(left: -8, top: -8, child: SparkAccent(size: 16, color: scheme.primary)),
        Positioned(
          right: -8,
          top: -8,
          child: Transform.flip(flipX: true, child: SparkAccent(size: 16, color: scheme.primary)),
        ),
      ],
    );
  }
}

class _LanguageDialog extends ConsumerWidget {
  const _LanguageDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeControllerProvider);

    return AlertDialog(
      title: Text(context.l10n.languageDialogTitle),
      contentPadding: const EdgeInsets.symmetric(vertical: LedgerSpacing.md),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final locale in supportedAppLocales)
            ListTile(
              title: Text(locale.languageCode == 'ar' ? 'العربية' : 'Français'),
              trailing: locale == current ? const Icon(Icons.check) : null,
              onTap: () {
                ref.read(localeControllerProvider.notifier).setLocale(locale);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
