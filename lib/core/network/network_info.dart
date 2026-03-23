// ─────────────────────────────────────────────────────────────────────────────
// NETWORK INFO
// ─────────────────────────────────────────────────────────────────────────────
//
// Abstracts connectivity checking behind an interface so the repository
// implementation doesn't import connectivity_plus directly.
// This makes it easy to mock in unit tests.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:connectivity_plus/connectivity_plus.dart';

/// Contract for checking network connectivity.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Production implementation using the connectivity_plus package.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  const NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    // checkConnectivity returns List<ConnectivityResult> in connectivity_plus 5+
    if (results is List) {
      return (results as List<ConnectivityResult>)
          .any((r) => r != ConnectivityResult.none);
    }
    return results != ConnectivityResult.none;
  }
}
