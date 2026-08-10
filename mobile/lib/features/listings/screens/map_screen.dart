import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../providers/nearby_listings_provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final nearby = ref.watch(nearbyListingsProvider);

    return nearby.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(LedgerSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 40, color: scheme.onSurface.withValues(alpha: 0.4)),
              const SizedBox(height: LedgerSpacing.md),
              Text(l10n.mapLoadError),
              const SizedBox(height: LedgerSpacing.md),
              OutlinedButton(
                onPressed: () => ref.invalidate(nearbyListingsProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
      data: (result) => Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: result.center, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kuik.mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: result.center,
                    width: 30,
                    height: 30,
                    child: Icon(Icons.my_location, color: scheme.secondary, size: 26),
                  ),
                  for (final listing in result.listings)
                    Marker(
                      point: LatLng(listing.latitude, listing.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => context.push('/listings/${listing.id}'),
                        child: Icon(
                          listing.isLost ? Icons.location_on_outlined : Icons.location_on,
                          color: scheme.primary,
                          size: 36,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (!result.isPrecise)
            Positioned(
              top: LedgerSpacing.md,
              left: LedgerSpacing.md,
              right: LedgerSpacing.md,
              child: _Banner(
                text: l10n.mapImpreciseLocationBanner,
                scheme: scheme,
              ),
            ),
          if (result.listings.isEmpty)
            Positioned(
              bottom: LedgerSpacing.xl,
              left: LedgerSpacing.md,
              right: LedgerSpacing.md,
              child: _Banner(text: l10n.mapEmptyState, scheme: scheme),
            ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.scheme});

  final String text;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: LedgerSpacing.md, vertical: LedgerSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
    );
  }
}
