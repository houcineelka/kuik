import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../../listings/models/categories.dart';
import '../../listings/widgets/photo_viewer_screen.dart';
import '../models/listing_claim.dart';
import '../providers/claims_provider.dart';

class ClaimsScreen extends ConsumerWidget {
  const ClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final claims = ref.watch(claimsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.claimsAppBarTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(claimsControllerProvider),
          child: claims.when(
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
                    l10n.claimsLoadError,
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
                      Icon(Icons.fact_check_outlined, size: 40, color: scheme.onSurfaceVariant),
                      const SizedBox(height: LedgerSpacing.md),
                      Center(
                        child: Text(
                          l10n.claimsEmptyState,
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
                    itemBuilder: (context, index) => _ClaimCard(
                      claim: list[index],
                      // Accepting removes the card from the list immediately
                      // (optimistic update), which disposes the card's own
                      // BuildContext before the network call resolves — the
                      // navigation must run through this still-mounted
                      // screen-level context instead.
                      onAccepted: (conversationId) {
                        if (context.mounted) context.pushReplacement('/conversations/$conversationId');
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ClaimCard extends ConsumerWidget {
  const _ClaimCard({required this.claim, required this.onAccepted});

  final ListingClaim claim;
  final void Function(int conversationId) onAccepted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LedgerSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.person_outline, size: 18, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: LedgerSpacing.sm),
                Expanded(
                  child: Text(claim.claimant.name, style: textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: LedgerSpacing.sm),
            InkWell(
              onTap: () => context.push('/listings/${claim.listing.id}'),
              child: Text(
                '${l10n.claimsForLabel} ${categoryLabel(l10n, claim.listing.category)} — ${claim.listing.description}',
                style: textTheme.bodySmall?.copyWith(color: scheme.secondary, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: LedgerSpacing.sm),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PhotoViewerScreen(photoUrls: [claim.photoUrl], initialIndex: 0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    claim.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: scheme.surfaceContainerHigh,
                      alignment: Alignment.center,
                      child: Icon(Icons.image_outlined, color: scheme.onSurface.withValues(alpha: 0.35)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: LedgerSpacing.sm),
            Text(claim.description, style: textTheme.bodyMedium),
            const SizedBox(height: LedgerSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(claimsControllerProvider.notifier).respond(claim.id, 'rejected'),
                    child: Text(l10n.matchesRejectButton),
                  ),
                ),
                const SizedBox(width: LedgerSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final conversationId = await ref.read(claimsControllerProvider.notifier).respond(claim.id, 'accepted');
                      if (conversationId != null) onAccepted(conversationId);
                    },
                    child: Text(l10n.claimsAcceptButton),
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
