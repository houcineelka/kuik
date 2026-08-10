import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/conversations_provider.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final conversations = ref.watch(conversationsProvider);
    final currentUserId = ref.watch(authControllerProvider).valueOrNull?.id;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.conversationsAppBarTitle)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(conversationsProvider),
          child: conversations.when(
            loading: () => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 200), Center(child: CircularProgressIndicator())],
            ),
            error: (error, stack) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(LedgerSpacing.xl),
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Text(
                    l10n.conversationsLoadError,
                    style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            data: (list) => list.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(LedgerSpacing.xl),
                    children: [
                      const SizedBox(height: 100),
                      Icon(Icons.chat_bubble_outline, size: 40, color: scheme.onSurfaceVariant),
                      const SizedBox(height: LedgerSpacing.md),
                      Center(
                        child: Text(
                          l10n.conversationsEmptyState,
                          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: LedgerSpacing.sm),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: scheme.outlineVariant),
                    itemBuilder: (context, index) {
                      final conversation = list[index];
                      final other = currentUserId == null ? conversation.userOne : conversation.otherParticipant(currentUserId);
                      final hasUnread = conversation.unreadCount > 0;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: LedgerSpacing.xl, vertical: LedgerSpacing.xs),
                        leading: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              backgroundColor: scheme.primaryContainer,
                              child: Icon(Icons.person_outline, color: scheme.onPrimaryContainer),
                            ),
                            if (hasUnread)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: scheme.surfaceContainerLowest, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          other.name,
                          style: TextStyle(fontWeight: hasUnread ? FontWeight.w700 : FontWeight.normal),
                        ),
                        subtitle: Text(
                          conversation.listing.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                        onTap: () => context.push('/conversations/${conversation.id}'),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
