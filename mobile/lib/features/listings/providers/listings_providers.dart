import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/listings_local_cache.dart';
import '../data/listings_repository.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepository(apiClient: ref.watch(apiClientProvider));
});

final listingsLocalCacheProvider = Provider<ListingsLocalCache>((ref) {
  return ListingsLocalCache();
});
