// ─────────────────────────────────────────────────────────────────────────────
// EXCEPTIONS  (Data Layer concerns)
// ─────────────────────────────────────────────────────────────────────────────
//
// Exceptions are RAW errors thrown by the Data layer (network calls, DB ops).
// They are implementation-specific and should NEVER leak into Domain or
// Presentation. The repository implementation catches them and converts them
// into Failures (see failures.dart) before returning to upper layers.
//
// Rule of thumb:
//   Data Layer  → throws Exception
//   Repository  → catches Exception, returns Either<Failure, T>
//   Domain/UI   → only sees Failure, never Exception
// ─────────────────────────────────────────────────────────────────────────────

/// Thrown when an HTTP request fails (non-2xx status code).
class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'An unexpected server error occurred.'});
}

/// Thrown when there is no data in the local cache / shared preferences.
class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'No cached data found.'});
}

/// Thrown when the device has no internet connection.
class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection.'});
}
