import 'dart:io' show Platform;

import '../../../core/api/api_client.dart';

class DeviceTokensRepository {
  DeviceTokensRepository({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  Future<void> register(String token) => _api.post('/device-tokens', data: {
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      });

  Future<void> unregister(String token) => _api.delete('/device-tokens', query: {'token': token});
}
