import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import 'app.dart';

/// Riverpod observer — logs every provider error to AppLogger.
class _ProviderLogger extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.e('Riverpod[${provider.name ?? provider.runtimeType}]',
        'provider failed', error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch uncaught Flutter framework errors (widget build failures, etc.)
  FlutterError.onError = (details) {
    AppLogger.e('FlutterError', details.exceptionAsString(),
        details.exception, details.stack);
    FlutterError.presentError(details);
  };

  // Catch uncaught async/platform errors outside the Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.e('PlatformDispatcher', 'uncaught error', error, stack);
    return false;
  };

  AppLogger.i('main', 'initializing Supabase');
  await SupabaseClientInitializer.initialize(
    url: const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'https://gmozpsolmfwrihktdeqh.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdtb3pwc29sbWZ3cmloa3RkZXFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3NjQxMTEsImV4cCI6MjA5MDM0MDExMX0.itV_0F4iuSvepl5cw4SAj52gFy_Vb2lu8QTEu-mhDHs'),
  );

  // Clear any stale auth sessions that can't be refreshed
  try {
    final session = SupabaseClientInitializer.client.auth.currentSession;
    if (session != null && session.isExpired) {
      AppLogger.w('main', 'session expired — signing out');
      await SupabaseClientInitializer.client.auth.signOut();
    }
  } catch (e, st) {
    AppLogger.e('main', 'session check failed — forcing signOut', e, st);
    try {
      await SupabaseClientInitializer.client.auth.signOut();
    } catch (_) {}
  }

  AppLogger.i('main', 'starting HospitalPortal');
  runApp(
    ProviderScope(
      observers: [_ProviderLogger()],
      child: const HealthOSHospitalPortal(),
    ),
  );
}
