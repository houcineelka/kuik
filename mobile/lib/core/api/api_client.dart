import 'package:dio/dio.dart';

import '../env.dart';
import '../storage/secure_token_storage.dart';
import 'api_exception.dart';

/// Thin wrapper around [Dio] that attaches the Sanctum bearer token to
/// every request and normalizes failures into [ApiException].
class ApiClient {
  ApiClient({required SecureTokenStorage tokenStorage})
      : _tokenStorage = tokenStorage,
        _dio = Dio(
          BaseOptions(
            baseUrl: Env.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Accept': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final SecureTokenStorage _tokenStorage;
  final Dio _dio;

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return response.data ?? {};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
      return response.data ?? {};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
      return response.data ?? {};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> postMultipart(String path, FormData data) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return response.data ?? {};
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String path, {Map<String, dynamic>? query}) async {
    try {
      await _dio.delete<dynamic>(path, queryParameters: query);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String? ?? 'Une erreur est survenue.';
      final errors = <String, List<String>>{};
      final rawErrors = data['errors'];
      if (rawErrors is Map) {
        for (final entry in rawErrors.entries) {
          final value = entry.value;
          if (value is List) {
            errors[entry.key as String] = value.map((v) => v.toString()).toList();
          }
        }
      }
      return ApiException(message, errors);
    }

    return const ApiException('Impossible de contacter le serveur. Vérifiez votre connexion.');
  }
}
