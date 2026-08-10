import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/models/user.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../../notifications/data/device_tokens_repository.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SecureTokenStorage tokenStorage,
    required PushNotificationService pushNotificationService,
    required DeviceTokensRepository deviceTokensRepository,
  })  : _api = apiClient,
        _tokenStorage = tokenStorage,
        _pushNotificationService = pushNotificationService,
        _deviceTokensRepository = deviceTokensRepository;

  final ApiClient _api;
  final SecureTokenStorage _tokenStorage;
  final PushNotificationService _pushNotificationService;
  final DeviceTokensRepository _deviceTokensRepository;
  bool _tokenRefreshListenerStarted = false;

  Future<User> register({
    required String name,
    required String phone,
    required String password,
    required String city,
  }) async {
    final json = await _api.post('/register', data: {
      'name': name,
      'phone': phone,
      'password': password,
      'city': city,
    });
    await _tokenStorage.saveToken(json['token'] as String);
    await _registerDeviceToken();
    _startTokenRefreshListener();
    return User.fromJson(json['user'] as Map<String, dynamic>);
  }

  Future<User> login({required String phone, required String password}) async {
    final json = await _api.post('/login', data: {
      'phone': phone,
      'password': password,
    });
    await _tokenStorage.saveToken(json['token'] as String);
    await _registerDeviceToken();
    _startTokenRefreshListener();
    return User.fromJson(json['user'] as Map<String, dynamic>);
  }

  /// Returns the current user if a stored token is still valid, otherwise
  /// clears the token and returns null. Called once at startup (Splash).
  Future<User?> currentUser() async {
    final token = await _tokenStorage.readToken();
    if (token == null) return null;

    try {
      final json = await _api.get('/me');
      final user = User.fromJson(json);
      // The FCM token can rotate (reinstall, app data restore) between app
      // launches — re-registering here (not just on login/register) is what
      // keeps push notifications actually arriving on a returning session.
      await _registerDeviceToken();
      _startTokenRefreshListener();
      return user;
    } on ApiException {
      await _tokenStorage.deleteToken();
      return null;
    }
  }

  Future<void> logout() async {
    await _unregisterDeviceToken();
    try {
      await _api.post('/logout');
    } on ApiException {
      // Server call failed or token already invalid — still clear the local token below.
    }
    await _tokenStorage.deleteToken();
  }

  /// Best-effort: a failed FCM registration shouldn't block login/register.
  Future<void> _registerDeviceToken() async {
    try {
      final token = await _pushNotificationService.getToken();
      if (token != null) await _deviceTokensRepository.register(token);
    } catch (_) {
      // Ignored — push notifications are a nice-to-have, not a login blocker.
    }
  }

  /// Firebase can rotate the device token at any time (not just on
  /// reinstall) — without this, a stale token lingers on the backend and
  /// push notifications silently stop arriving until the next login.
  /// Guarded to attach once per app run: this repository is a long-lived
  /// singleton, so calling this from every login/register/currentUser would
  /// otherwise stack duplicate listeners.
  void _startTokenRefreshListener() {
    if (_tokenRefreshListenerStarted) return;
    _tokenRefreshListenerStarted = true;
    _pushNotificationService.onTokenRefresh.listen((token) {
      _deviceTokensRepository.register(token).catchError((_) {});
    });
  }

  /// Must run before the bearer token is cleared — the unregister call
  /// needs to go out authenticated.
  Future<void> _unregisterDeviceToken() async {
    try {
      final token = await _pushNotificationService.getToken();
      if (token != null) await _deviceTokensRepository.unregister(token);
    } catch (_) {
      // Ignored — best-effort cleanup, must not block logout.
    }
  }
}
