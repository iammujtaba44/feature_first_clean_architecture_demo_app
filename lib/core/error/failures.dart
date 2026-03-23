// ─────────────────────────────────────────────────────────────────────────────
// FAILURES  (Domain / Presentation Layer concerns)
// ─────────────────────────────────────────────────────────────────────────────
//
// Failures are the clean, domain-friendly representation of errors.
// Unlike exceptions they are not tied to any framework or data source.
//
// The Presentation layer pattern-matches on Failure subtypes to display the
// right error message to the user — without ever knowing HOW the error
// was originally produced (HTTP 500? JSON parse error? No internet?).
//
// We use `equatable` so two failures of the same type with the same data
// compare as equal — important for BLoC state change detection.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// Base class for all domain failures.
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Maps to [ServerException] — something went wrong on the server.
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error. Please try again.'});
}

/// Maps to [CacheException] — nothing in local cache.
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'No cached data available.'});
}

/// Maps to [NetworkException] — device is offline.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection.'});
}
