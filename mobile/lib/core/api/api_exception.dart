/// A normalized API failure: a user-facing [message] plus, for 422
/// validation responses, per-field [errors] as returned by Laravel.
class ApiException implements Exception {
  const ApiException(this.message, [this.errors = const {}]);

  final String message;
  final Map<String, List<String>> errors;

  String? firstErrorFor(String field) => errors[field]?.first;

  @override
  String toString() => message;
}
