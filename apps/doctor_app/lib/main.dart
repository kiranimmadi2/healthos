import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import 'app.dart';
import 'firebase_options.dart';

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

  AppLogger.i('main', 'initializing Firebase');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AppLogger.i('main', 'initializing Supabase');
  await SupabaseClientInitializer.initialize(
    url: const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'https://gmozpsolmfwrihktdeqh.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdtb3pwc29sbWZ3cmloa3RkZXFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3NjQxMTEsImV4cCI6MjA5MDM0MDExMX0.itV_0F4iuSvepl5cw4SAj52gFy_Vb2lu8QTEu-mhDHs'),
  );

  AppLogger.i('main', 'starting DoctorApp');
  runApp(
    ProviderScope(
      observers: [_ProviderLogger()],
      child: const HealthOSDoctorApp(),
    ),
  );
}
