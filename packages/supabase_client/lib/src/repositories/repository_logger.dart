import 'package:core/core.dart';

/// Mixin that wraps repository operations with structured debug logging.
///
/// Add `with RepositoryLogger` to any repository class, then wrap
/// async calls with `loggedOp('methodName', () => ...)`.
mixin RepositoryLogger {
  String get _tag => runtimeType.toString();

  /// Logs the start of [op], runs [fn], logs success, and on error logs
  /// the full exception + stack trace before rethrowing.
  Future<T> loggedOp<T>(String op, Future<T> Function() fn) async {
    AppLogger.d(_tag, '$op →');
    try {
      final result = await fn();
      AppLogger.d(_tag, '$op ✓');
      return result;
    } catch (e, st) {
      AppLogger.e(_tag, '$op ✗', e, st);
      rethrow;
    }
  }
}
