import '../../../core/api/api_client.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ConversationsRepository {
  ConversationsRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<List<Conversation>> index() async {
    final json = await _api.get('/conversations');
    return (json['data'] as List<dynamic>? ?? [])
        .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Messages are paginated ascending (oldest first) at 15/page, so the most
  /// recent messages live on the last page — fetch page 1 to learn
  /// `last_page`, then fetch that page directly. No older-history
  /// infinite-scroll for this MVP (simple periodic refresh, per spec).
  Future<List<Message>> messages(int conversationId) async {
    final first = await _api.get('/conversations/$conversationId/messages');
    final lastPage = first['last_page'] as int? ?? 1;
    final json = lastPage == 1
        ? first
        : await _api.get('/conversations/$conversationId/messages', query: {'page': lastPage});
    return (json['data'] as List<dynamic>? ?? [])
        .map((item) => Message.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Message> sendMessage(int conversationId, String content) async {
    final json = await _api.post('/conversations/$conversationId/messages', data: {'content': content});
    return Message.fromJson(json);
  }
}
