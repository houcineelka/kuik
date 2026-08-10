import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/listing.dart';
import 'bookmarks_provider.dart';

final savedListingsProvider = FutureProvider.autoDispose<List<Listing>>((ref) async {
  final repo = ref.watch(bookmarksRepositoryProvider);
  final result = await repo.index();
  return result.listings;
});
