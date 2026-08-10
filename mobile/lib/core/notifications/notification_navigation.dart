import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../router/app_router.dart';
import 'push_notification_service.dart';

/// Sets up notification-tap routing once at app start: a tapped
/// notification (foreground, background, or cold start) navigates to the
/// matching match or conversation screen based on its `type` data field.
final notificationNavigationProvider = Provider<void>((ref) {
  final service = ref.watch(pushNotificationServiceProvider);
  final router = ref.watch(goRouterProvider);

  void handleData(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == 'match') {
      router.push('/matches');
    } else if (type == 'message') {
      final conversationId = data['conversation_id'];
      if (conversationId != null) router.push('/conversations/$conversationId');
    } else if (type == 'claim') {
      router.push('/claims');
    } else if (type == 'claim_accepted') {
      final conversationId = data['conversation_id'];
      if (conversationId != null) router.push('/conversations/$conversationId');
    } else if (type == 'claim_rejected') {
      final listingId = data['listing_id'];
      if (listingId != null) router.push('/listings/$listingId');
    }
  }

  // Best-effort: a Firebase/Play-Services hiccup on some device must never
  // take down the rest of the app.
  service.initialize(onNotificationTap: handleData).catchError((_) {});
  service.getInitialMessage().then((message) {
    if (message != null) handleData(message.data);
  }).catchError((_) {});
});
