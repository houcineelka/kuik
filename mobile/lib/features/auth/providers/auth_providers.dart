import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/models/user.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../../../core/storage/secure_token_storage.dart';
import '../../notifications/data/device_tokens_repository.dart';
import '../data/auth_repository.dart';

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.watch(secureTokenStorageProvider));
});

final deviceTokensRepositoryProvider = Provider<DeviceTokensRepository>((ref) {
  return DeviceTokensRepository(apiClient: ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(secureTokenStorageProvider),
    pushNotificationService: ref.watch(pushNotificationServiceProvider),
    deviceTokensRepository: ref.watch(deviceTokensRepositoryProvider),
  );
});

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(AuthController.new);

/// Holds the current session: null when logged out, a [User] when logged
/// in. [build] runs once at app start to check for a persisted token.
class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() {
    return ref.read(authRepositoryProvider).currentUser();
  }

  /// On failure, restores the previous state and rethrows so the calling
  /// screen can show field-level errors — the global session state never
  /// lands on AsyncError from a bad login/register attempt.
  Future<void> register({
    required String name,
    required String phone,
    required String password,
    required String city,
  }) async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).register(
            name: name,
            phone: phone,
            password: password,
            city: city,
          );
      state = AsyncData(user);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> login({required String phone, required String password}) async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();
    try {
      final user = await ref.read(authRepositoryProvider).login(phone: phone, password: password);
      state = AsyncData(user);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
