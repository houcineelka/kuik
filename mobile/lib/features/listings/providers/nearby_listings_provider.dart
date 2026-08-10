import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/location/location_service.dart';
import '../data/listings_repository.dart';
import '../models/listing.dart';
import 'listings_providers.dart';

class NearbyListingsResult {
  const NearbyListingsResult({required this.center, required this.isPrecise, required this.listings});

  final LatLng center;
  final bool isPrecise;
  final List<Listing> listings;
}

const double _mapSearchRadiusKm = 15;

/// Resolves the user's position, then fetches nearby listings for the Map
/// screen. A single page (15 results) is enough for a map view.
final nearbyListingsProvider = FutureProvider.autoDispose<NearbyListingsResult>((ref) async {
  final locationResult = await ref.watch(locationServiceProvider).resolveCurrentPosition();

  final page = await ref.watch(listingsRepositoryProvider).search(
        ListingSearchFilters(
          lat: locationResult.position.latitude,
          lng: locationResult.position.longitude,
          radiusKm: _mapSearchRadiusKm,
        ),
      );

  return NearbyListingsResult(
    center: locationResult.position,
    isPrecise: locationResult.isPrecise,
    listings: page.listings,
  );
});
