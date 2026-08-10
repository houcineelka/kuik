import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/conversations_repository.dart';
import '../models/conversation.dart';

final conversationsRepositoryProvider = Provider<ConversationsRepository>((ref) {
  return ConversationsRepository(apiClient: ref.watch(apiClientProvider));
});

final conversationsProvider = FutureProvider.autoDispose<List<Conversation>>((ref) {
  return ref.watch(conversationsRepositoryProvider).index();
});

final totalUnreadCountProvider = Provider.autoDispose<int>((ref) {
  final conversations = ref.watch(conversationsProvider).valueOrNull ?? const [];
  return conversations.fold(0, (total, conversation) => total + conversation.unreadCount);
});
