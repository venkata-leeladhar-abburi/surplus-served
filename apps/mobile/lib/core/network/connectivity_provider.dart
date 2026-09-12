import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Real device connectivity — independent of whether any repository has
/// live network calls yet. Every current repository is fixture-backed
/// (§16 vertical slice), so losing connectivity breaks nothing in-app
/// today; this exists so the signal is already wired for the moment a
/// repository starts making a real Dio call, and so `RoleScaffold` can
/// show the banner ARCHITECTURE.md §2 promises ("an NGO on a two-bar
/// connection sees food, not a spinner") ahead of that backend landing.
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(_isOnline);
});

/// Exposed separately so a screen that needs a one-shot check (rather than
/// a stream) — e.g. before a manual retry — doesn't have to wait on a new
/// event.
final connectivityCheckProvider = FutureProvider<bool>((ref) async {
  final result = await Connectivity().checkConnectivity();
  return _isOnline(result);
});

bool _isOnline(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);
