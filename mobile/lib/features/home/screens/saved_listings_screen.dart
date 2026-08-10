import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../../listings/providers/bookmarks_provider.dart';
import '../../listings/providers/saved_listings_provider.dart';
import '../../listings/widgets/listing_card.dart';

class SavedListingsScreen extends ConsumerWidget {
  const SavedListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final saved = ref.watch(savedListingsProvider);
    final bookmarkedIds = ref.watch(bookmarksControllerProvider).valueOrNull;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(savedListingsProvider),
        child: saved.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 200),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, stack) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(LedgerSpacing.xl),
            children: [
              const SizedBox(height: 100),
              Center(
                child: Text(
                  l10n.savedListingsLoadError,
                  style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          data: (listings) {
            final visible = bookmarkedIds == null
                ? listings
                : listings.where((listing) => bookmarkedIds.contains(listing.id)).toList();

            if (visible.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(LedgerSpacing.xl),
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.bookmark_border, size: 40, color: scheme.onSurfaceVariant),
                  const SizedBox(height: LedgerSpacing.md),
                  Center(
                    child: Text(
                      l10n.savedListingsEmptyState,
                      style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(LedgerSpacing.xl, LedgerSpacing.lg, LedgerSpacing.xl, LedgerSpacing.xxxl),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: visible.length,
              separatorBuilder: (context, index) => const SizedBox(height: LedgerSpacing.md),
              itemBuilder: (context, index) {
                final listing = visible[index];
                return ListingCard(listing: listing, onTap: () => context.push('/listings/${listing.id}'));
              },
            );
          },
        ),
      ),
    );
  }
}
