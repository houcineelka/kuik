import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/matches_repository.dart';
import '../models/listing_match.dart';

final matchesRepositoryProvider = Provider<MatchesRepository>((ref) {
  return MatchesRepository(apiClient: ref.watch(apiClientProvider));
});

/// `/matches` only ever returns 'suggested' matches, so confirming/rejecting
/// one just removes it from the local list — optimistic, with rollback on
/// failure, same shape as `bookmarks_provider.dart`'s `toggle()`.
class MatchesController extends AsyncNotifier<List<ListingMatch>> {
  @override
  Future<List<ListingMatch>> build() => ref.read(matchesRepositoryProvider).index();

  Future<void> respond(int matchId, String status) async {
    final repo = ref.read(matchesRepositoryProvider);
    final current = state.valueOrNull ?? const <ListingMatch>[];

    state = AsyncData(current.where((match) => match.id != matchId).toList());

    try {
      await repo.update(matchId, status);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

final matchesControllerProvider = AsyncNotifierProvider<MatchesController, List<ListingMatch>>(MatchesController.new);
