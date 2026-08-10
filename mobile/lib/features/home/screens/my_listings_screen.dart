import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../../listings/providers/my_listings_provider.dart';
import '../../listings/widgets/listing_card.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final myListings = ref.watch(myListingsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myListingsProvider),
        child: myListings.when(
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
                  l10n.myListingsLoadError,
                  style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          data: (listings) => listings.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(LedgerSpacing.xl),
                  children: [
                    const SizedBox(height: 100),
                    Icon(Icons.inventory_2_outlined, size: 40, color: scheme.onSurfaceVariant),
                    const SizedBox(height: LedgerSpacing.md),
                    Center(
                      child: Text(
                        l10n.myListingsEmptyState,
                        style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(LedgerSpacing.xl, LedgerSpacing.lg, LedgerSpacing.xl, LedgerSpacing.xxxl),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: listings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: LedgerSpacing.md),
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return ListingCard(listing: listing, onTap: () => context.push('/listings/${listing.id}'));
                  },
                ),
        ),
      ),
    );
  }
}
