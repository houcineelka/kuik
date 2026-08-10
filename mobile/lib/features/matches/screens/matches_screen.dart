import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../../listings/models/category_icons.dart';
import '../../listings/models/listing.dart';
import '../models/listing_match.dart';
import '../providers/matches_provider.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final matches = ref.watch(matchesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.matchesAppBarTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(matchesControllerProvider),
          child: matches.when(
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 200), Center(child: CircularProgressIndicator())],
            ),
            error: (error, stack) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(LedgerSpacing.xl),
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Text(
                    l10n.matchesLoadError,
                    style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            data: (list) => list.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(LedgerSpacing.xl),
                    children: [
                      const SizedBox(height: 100),
                      Icon(Icons.auto_awesome_outlined, size: 40, color: scheme.onSurfaceVariant),
                      const SizedBox(height: LedgerSpacing.md),
                      Center(
                        child: Text(
                          l10n.matchesEmptyState,
                          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(LedgerSpacing.xl, LedgerSpacing.lg, LedgerSpacing.xl, LedgerSpacing.xxxl),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: LedgerSpacing.md),
                    itemBuilder: (context, index) => _MatchCard(match: list[index]),
                  ),
          ),
        ),
      ),
    );
  }
}

class _MatchCard extends ConsumerWidget {
  const _MatchCard({required this.match});

  final ListingMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LedgerSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _ListingTile(listing: match.lostListing, onTap: () => context.push('/listings/${match.lostListing.id}'))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: LedgerSpacing.sm),
                  child: Icon(Icons.compare_arrows, color: scheme.primary),
                ),
                Expanded(child: _ListingTile(listing: match.foundListing, onTap: () => context.push('/listings/${match.foundListing.id}'))),
              ],
            ),
            const SizedBox(height: LedgerSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(matchesControllerProvider.notifier).respond(match.id, 'rejected'),
                    child: Text(l10n.matchesRejectButton),
                  ),
                ),
                const SizedBox(width: LedgerSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ref.read(matchesControllerProvider.notifier).respond(match.id, 'confirmed'),
                    child: Text(l10n.matchesConfirmButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({required this.listing, required this.onTap});

  final Listing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final thumbnail = listing.photos.isEmpty ? null : listing.photos.first.photoUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 1,
              child: thumbnail != null
                  ? Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => _placeholder(scheme),
                    )
                  : _placeholder(scheme),
            ),
          ),
          const SizedBox(height: LedgerSpacing.xs),
          Text(
            listing.isLost ? l10n.statusLost : l10n.statusFound,
            style: textTheme.labelSmall?.copyWith(color: listing.isLost ? scheme.primary : scheme.tertiary),
          ),
          Text(
            listing.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) => Container(
        color: scheme.primaryContainer,
        alignment: Alignment.center,
        child: Icon(iconForCategory(listing.category), color: scheme.onPrimaryContainer),
      );
}
