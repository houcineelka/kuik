import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/listings_repository.dart';
import '../models/listing.dart';
import 'listings_providers.dart';

class ListingsSearchState {
  const ListingsSearchState({
    required this.listings,
    required this.filters,
    required this.page,
    required this.hasMore,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isOffline,
  });

  factory ListingsSearchState.initial() => const ListingsSearchState(
        listings: [],
        filters: ListingSearchFilters(),
        page: 1,
        hasMore: true,
        isLoading: false,
        isLoadingMore: false,
        isOffline: false,
      );

  final List<Listing> listings;
  final ListingSearchFilters filters;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isOffline;
}

/// Drives the listings list screen: paginated search against the API,
/// falling back to the sqflite cache of last-viewed results when the
/// network call fails (degraded offline mode).
class ListingsSearchController extends Notifier<ListingsSearchState> {
  @override
  ListingsSearchState build() {
    Future.microtask(refresh);
    return ListingsSearchState.initial();
  }

  Future<void> refresh() async {
    final filters = state.filters;
    state = ListingsSearchState(
      listings: state.listings,
      filters: filters,
      page: state.page,
      hasMore: state.hasMore,
      isLoading: true,
      isLoadingMore: false,
      isOffline: false,
    );

    try {
      final result = await ref.read(listingsRepositoryProvider).search(filters, page: 1);
      state = ListingsSearchState(
        listings: result.listings,
        filters: filters,
        page: 1,
        hasMore: result.hasMore,
        isLoading: false,
        isLoadingMore: false,
        isOffline: false,
      );
      await ref.read(listingsLocalCacheProvider).upsertAll(result.listings);
    } catch (_) {
      final cached = await ref.read(listingsLocalCacheProvider).recent();
      state = ListingsSearchState(
        listings: cached,
        filters: filters,
        page: 1,
        hasMore: false,
        isLoading: false,
        isLoadingMore: false,
        isOffline: true,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore || state.isOffline) return;

    state = ListingsSearchState(
      listings: state.listings,
      filters: state.filters,
      page: state.page,
      hasMore: state.hasMore,
      isLoading: false,
      isLoadingMore: true,
      isOffline: false,
    );

    try {
      final nextPage = state.page + 1;
      final result = await ref.read(listingsRepositoryProvider).search(state.filters, page: nextPage);
      state = ListingsSearchState(
        listings: [...state.listings, ...result.listings],
        filters: state.filters,
        page: nextPage,
        hasMore: result.hasMore,
        isLoading: false,
        isLoadingMore: false,
        isOffline: false,
      );
    } catch (_) {
      state = ListingsSearchState(
        listings: state.listings,
        filters: state.filters,
        page: state.page,
        hasMore: state.hasMore,
        isLoading: false,
        isLoadingMore: false,
        isOffline: false,
      );
    }
  }

  void applyFilters(ListingSearchFilters filters) {
    state = ListingsSearchState(
      listings: state.listings,
      filters: filters,
      page: state.page,
      hasMore: state.hasMore,
      isLoading: state.isLoading,
      isLoadingMore: state.isLoadingMore,
      isOffline: state.isOffline,
    );
    refresh();
  }
}

final listingsSearchControllerProvider = NotifierProvider<ListingsSearchController, ListingsSearchState>(
  ListingsSearchController.new,
);
