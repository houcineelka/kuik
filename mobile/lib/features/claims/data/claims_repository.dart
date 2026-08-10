import '../../../core/api/api_client.dart';
import '../models/listing_claim.dart';

class ClaimsRepository {
  ClaimsRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<List<ListingClaim>> index() async {
    final json = await _api.get('/claims');
    return (json['data'] as List<dynamic>? ?? [])
        .map((item) => ListingClaim.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Returns the conversation id when a claim is accepted (null otherwise).
  Future<int?> update(int claimId, String status) async {
    final json = await _api.patch('/claims/$claimId', data: {'status': status});
    return json['conversation_id'] as int?;
  }
}
