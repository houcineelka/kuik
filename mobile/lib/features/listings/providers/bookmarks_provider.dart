import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/bookmarks_repository.dart';

const _maxPagesScanned = 10;

final bookmarksRepositoryProvider = Provider<BookmarksRepository>((ref) {
  return BookmarksRepository(apiClient: ref.watch(apiClientProvider));
});

/// Tracks the current user's bookmarked listing ids so any screen can check
/// or toggle bookmark state. Backed by the `/bookmarks` API — capped at
/// [_maxPagesScanned] pages, same pragmatic compromise as `myListingsProvider`.
class BookmarksController extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final repo = ref.read(bookmarksRepositoryProvider);
    final ids = <int>{};
    var page = 1;

    while (page <= _maxPagesScanned) {
      final result = await repo.index(page: page);
      ids.addAll(result.listings.map((listing) => listing.id));
      if (!result.hasMore) break;
      page++;
    }

    return ids;
  }

  Future<void> toggle(int listingId) async {
    final repo = ref.read(bookmarksRepositoryProvider);
    final current = state.valueOrNull ?? const <int>{};
    final wasBookmarked = current.contains(listingId);

    state = AsyncData({...current}..toggle(listingId, wasBookmarked));

    try {
      if (wasBookmarked) {
        await repo.remove(listingId);
      } else {
        await repo.add(listingId);
      }
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

extension on Set<int> {
  void toggle(int id, bool wasPresent) => wasPresent ? remove(id) : add(id);
}

final bookmarksControllerProvider = AsyncNotifierProvider<BookmarksController, Set<int>>(BookmarksController.new);
