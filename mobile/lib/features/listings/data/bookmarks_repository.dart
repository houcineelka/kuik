import '../../../core/api/api_client.dart';
import '../models/listing.dart';
import 'listings_repository.dart';

class BookmarksRepository {
  BookmarksRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<ListingsPage> index({int page = 1}) async {
    final json = await _api.get('/bookmarks', query: {'page': page});
    final data = (json['data'] as List<dynamic>? ?? [])
        .map((item) => Listing.fromJson(item as Map<String, dynamic>))
        .toList();
    return ListingsPage(
      listings: data,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
    );
  }

  Future<void> add(int listingId) => _api.post('/listings/$listingId/bookmark');

  Future<void> remove(int listingId) => _api.delete('/listings/$listingId/bookmark');
}
