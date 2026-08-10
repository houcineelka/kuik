import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../models/listing.dart';
import 'listings_providers.dart';

const _maxPagesScanned = 10;

/// The current user's own listings. No backend endpoint scopes `/listings`
/// to the caller, so this pages through the general index (newest first,
/// capped at [_maxPagesScanned] pages) and filters client-side — fine at
/// this app's current scale, not a substitute for a real "mine" endpoint.
final myListingsProvider = FutureProvider.autoDispose<List<Listing>>((ref) async {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user == null) return const [];

  final repo = ref.watch(listingsRepositoryProvider);
  final mine = <Listing>[];
  var page = 1;

  while (page <= _maxPagesScanned) {
    final result = await repo.index(page: page);
    mine.addAll(result.listings.where((listing) => listing.userId == user.id));
    if (!result.hasMore) break;
    page++;
  }

  return mine;
});
