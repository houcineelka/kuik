import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/message.dart';
import '../providers/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final int conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await ref.read(chatControllerProvider(widget.conversationId).notifier).sendMessage(text);
      _controller.clear();
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final messages = ref.watch(chatControllerProvider(widget.conversationId));
    final currentUserId = ref.watch(authControllerProvider).valueOrNull?.id;

    ref.listen(chatControllerProvider(widget.conversationId), (previous, next) {
      if (next.valueOrNull != null && previous?.valueOrNull != next.valueOrNull) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatAppBarTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text(l10n.chatLoadError, style: textTheme.bodyMedium),
                ),
                data: (list) => list.isEmpty
                    ? Center(child: Text(l10n.chatEmptyState, style: textTheme.bodyMedium))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(LedgerSpacing.lg),
                        itemCount: list.length,
                        itemBuilder: (context, index) => _MessageBubble(
                          message: list[index],
                          isMine: list[index].senderId == currentUserId,
                        ),
                      ),
              ),
            ),
            _Composer(controller: _controller, sending: _sending, onSend: _send, hint: l10n.chatComposerHint),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final time = '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: LedgerSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: LedgerSpacing.md, vertical: LedgerSpacing.sm),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMine ? scheme.primary : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: textTheme.bodyMedium?.copyWith(color: isMine ? scheme.onPrimary : scheme.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: textTheme.labelSmall?.copyWith(
                color: (isMine ? scheme.onPrimary : scheme.onSurface).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.sending, required this.onSend, required this.hint});

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(LedgerSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(hintText: hint),
            ),
          ),
          const SizedBox(width: LedgerSpacing.sm),
          CircleAvatar(
            backgroundColor: scheme.primary,
            child: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : IconButton(icon: Icon(Icons.send, color: scheme.onPrimary), onPressed: onSend),
          ),
        ],
      ),
    );
  }
}
