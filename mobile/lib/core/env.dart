/// API base URL, overridable per environment via:
///   flutter run --dart-define=API_BASE_URL=https://api.kuik.example.com/api
///
/// Default targets a Laravel dev server on the same machine. For a physical
/// Android device over USB, forward the port first: `adb reverse tcp:8000 tcp:8000`.
class Env {
  Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );
}
