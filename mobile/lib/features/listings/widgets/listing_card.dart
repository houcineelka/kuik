import 'package:flutter/material.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../models/categories.dart';
import '../models/category_icons.dart';
import '../models/listing.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing, this.onTap});

  final Listing listing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final thumbnail = listing.photos.isEmpty ? null : listing.photos.first.photoUrl;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(LedgerSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: thumbnail != null
                      ? Image.network(
                          thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => _Placeholder(listing: listing, scheme: scheme),
                          loadingBuilder: (context, child, progress) =>
                              progress == null ? child : _Placeholder(listing: listing, scheme: scheme),
                        )
                      : _Placeholder(listing: listing, scheme: scheme),
                ),
              ),
              const SizedBox(width: LedgerSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _CategoryBadgeIcon(category: listing.category, scheme: scheme),
                        const SizedBox(width: LedgerSpacing.xs),
                        Expanded(
                          child: Text(
                            categoryLabel(l10n, listing.category),
                            style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusPill(isLost: listing.isLost),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: LedgerSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: scheme.secondary),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            _subtitle(listing),
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(color: scheme.secondary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(Listing listing) {
    final parts = <String>[listing.city];
    if (listing.distanceM != null) {
      parts.add('${(listing.distanceM! / 1000).toStringAsFixed(1)} km');
    }
    return parts.join(' · ');
  }
}

class _CategoryBadgeIcon extends StatelessWidget {
  const _CategoryBadgeIcon({required this.category, required this.scheme});

  final String category;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(iconForCategory(category), size: 12, color: scheme.onPrimaryContainer),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.listing, required this.scheme});

  final Listing listing;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(iconForCategory(listing.category), color: scheme.onPrimaryContainer, size: 28),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isLost});

  final bool isLost;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final color = isLost ? scheme.primary : scheme.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(
        (isLost ? l10n.statusLost : l10n.statusFound).toUpperCase(),
        style: textTheme.labelLarge?.copyWith(fontSize: 10, color: Colors.white, letterSpacing: 0.4),
      ),
    );
  }
}
