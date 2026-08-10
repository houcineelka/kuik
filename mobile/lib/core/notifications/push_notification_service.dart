import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _channel = AndroidNotificationChannel(
  'kuik_default_channel',
  'Notifications Kuik',
  description: 'Correspondances et nouveaux messages',
  importance: Importance.high,
);

/// Wraps [FirebaseMessaging] + [FlutterLocalNotificationsPlugin]: requests
/// permission, shows a system notification while the app is foregrounded
/// (FCM notification-messages don't auto-display in that state), and routes
/// every tap (foreground local notification, background, or cold start)
/// through the same [onNotificationTap] callback.
class PushNotificationService {
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize({required void Function(Map<String, dynamic> data) onNotificationTap}) async {
    await FirebaseMessaging.instance.requestPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) onNotificationTap(_decodePayload(payload));
      },
    );

    FirebaseMessaging.onMessage.listen(_showLocalNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((message) => onNotificationTap(message.data));
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(_channel.id, _channel.name, channelDescription: _channel.description),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Map<String, dynamic> _decodePayload(String payload) {
    try {
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return const {};
    }
  }

  Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  Future<RemoteMessage?> getInitialMessage() => FirebaseMessaging.instance.getInitialMessage();

  /// Fires whenever Firebase rotates the device's token (reinstall, app
  /// data restore, periodic refresh) — without re-registering the new
  /// token, the backend keeps sending pushes to a dead token and they
  /// silently stop arriving.
  Stream<String> get onTokenRefresh => FirebaseMessaging.instance.onTokenRefresh;
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) => PushNotificationService());
