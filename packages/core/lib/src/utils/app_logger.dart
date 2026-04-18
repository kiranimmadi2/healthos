import 'package:flutter/foundation.dart';

/// Centralized debug logger. Only emits output in debug builds (kDebugMode).
///
/// Usage:
///   AppLogger.d('PatientRepo', 'getByAuthId called — authId=$id');
///   AppLogger.e('AuthService', 'signIn failed', error, stackTrace);
class AppLogger {
  AppLogger._();

  static bool _enabled = kDebugMode;

  /// Override to enable/disable at runtime (e.g. force-enable in profile builds).
  static set enabled(bool value) => _enabled = value;

  static String _ts() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}.'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  /// Debug — verbose tracing, state transitions.
  static void d(String tag, String message) {
    if (!_enabled) return;
    debugPrint('[${_ts()}] 🔵 DEBUG [$tag] $message');
  }

  /// Info — significant lifecycle events.
  static void i(String tag, String message) {
    if (!_enabled) return;
    debugPrint('[${_ts()}] 🟢 INFO  [$tag] $message');
  }

  /// Warning — unexpected but recoverable state.
  static void w(String tag, String message) {
    if (!_enabled) return;
    debugPrint('[${_ts()}] 🟡 WARN  [$tag] $message');
  }

  /// Error — caught exception with full context.
  static void e(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!_enabled) return;
    debugPrint('[${_ts()}] 🔴 ERROR [$tag] $message');
    if (error != null) debugPrint('           error: $error');
    if (stackTrace != null) {
      // Print top 8 frames to stay readable in the console.
      final frames = stackTrace.toString().split('\n').take(8).join('\n');
      debugPrint('           stack:\n$frames');
    }
  }
}
