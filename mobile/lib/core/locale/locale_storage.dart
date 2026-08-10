import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the user's chosen app language ('fr' or 'ar').
class LocaleStorage {
  LocaleStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _localeKey = 'app_locale';

  final FlutterSecureStorage _storage;

  Future<void> saveLanguageCode(String languageCode) => _storage.write(key: _localeKey, value: languageCode);

  Future<String?> readLanguageCode() => _storage.read(key: _localeKey);
}
