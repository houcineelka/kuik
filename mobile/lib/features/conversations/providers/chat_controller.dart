import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import 'conversations_provider.dart';

/// No websockets for this version — polls the conversation's messages every
/// few seconds while a chat screen is open.
class ChatController extends FamilyAsyncNotifier<List<Message>, int> {
  Timer? _timer;

  @override
  Future<List<Message>> build(int conversationId) async {
    ref.onDispose(() => _timer?.cancel());
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
    final messages = await ref.read(conversationsRepositoryProvider).messages(conversationId);
    ref.invalidate(conversationsProvider);
    return messages;
  }

  Future<void> _poll() async {
    try {
      final messages = await ref.read(conversationsRepositoryProvider).messages(arg);
      state = AsyncData(messages);
    } catch (_) {
      // Silent — keep showing the last known messages on a transient poll failure.
    }
  }

  Future<void> sendMessage(String content) async {
    await ref.read(conversationsRepositoryProvider).sendMessage(arg, content);
    await _poll();
  }
}

final chatControllerProvider = AsyncNotifierProvider.family<ChatController, List<Message>, int>(ChatController.new);
