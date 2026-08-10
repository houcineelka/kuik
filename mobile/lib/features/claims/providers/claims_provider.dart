import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/claims_repository.dart';
import '../models/listing_claim.dart';

final claimsRepositoryProvider = Provider<ClaimsRepository>((ref) {
  return ClaimsRepository(apiClient: ref.watch(apiClientProvider));
});

/// `/claims` only ever returns pending claims, so accepting/rejecting one
/// just removes it from the local list — optimistic, with rollback on
/// failure, same shape as `matches_provider.dart`'s `respond()`.
class ClaimsController extends AsyncNotifier<List<ListingClaim>> {
  @override
  Future<List<ListingClaim>> build() => ref.read(claimsRepositoryProvider).index();

  /// Returns the opened conversation id when [status] is `'accepted'`, so
  /// the caller can navigate straight into it; null otherwise or on failure.
  Future<int?> respond(int claimId, String status) async {
    final repo = ref.read(claimsRepositoryProvider);
    final current = state.valueOrNull ?? const <ListingClaim>[];

    state = AsyncData(current.where((claim) => claim.id != claimId).toList());

    try {
      return await repo.update(claimId, status);
    } catch (_) {
      state = AsyncData(current);
      return null;
    }
  }
}

final claimsControllerProvider = AsyncNotifierProvider<ClaimsController, List<ListingClaim>>(ClaimsController.new);
