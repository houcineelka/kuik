import '../../../core/api/api_client.dart';
import '../models/listing_match.dart';

class MatchesRepository {
  MatchesRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<List<ListingMatch>> index() async {
    final json = await _api.get('/matches');
    return (json['data'] as List<dynamic>? ?? [])
        .map((item) => ListingMatch.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> update(int matchId, String status) => _api.patch('/matches/$matchId', data: {'status': status});
}
