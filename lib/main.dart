import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'src/app/health_os_app.dart';
import 'src/services/reminders_service.dart';

export 'src/app/health_os_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _activateAppCheck();
  await RemindersService().init();

  runApp(const ProviderScope(child: HealthOSApp()));
}

/// Attests that requests come from a genuine build of this app.
///
/// The Firebase config in `firebase_options.dart` is necessarily public — it
/// ships in the web bundle and the APK — so without App Check anyone holding it
/// can call this project's Firestore and Firebase AI Logic endpoints. Removing
/// the hardcoded Gemini key from the client was necessary but not sufficient on
/// its own.
///
/// Setup, in this order, or you will lock yourself out:
///  1. Register providers in the Firebase console and leave enforcement OFF.
///  2. Run a debug build, copy the debug token it logs, and register it under
///     App Check > Apps > Manage debug tokens.
///  3. Only then turn enforcement on, per-service, watching the metrics.
///
/// Web needs a reCAPTCHA v3 site key; until one is configured the web path is
/// skipped rather than failing startup.
Future<void> _activateAppCheck() async {
  const recaptchaSiteKey = String.fromEnvironment('RECAPTCHA_V3_SITE_KEY');

  if (kIsWeb && recaptchaSiteKey.isEmpty) {
    debugPrint(
      'App Check skipped on web: pass --dart-define=RECAPTCHA_V3_SITE_KEY=...',
    );
    return;
  }

  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
      webProvider:
          recaptchaSiteKey.isEmpty ? null : ReCaptchaV3Provider(recaptchaSiteKey),
    );
  } catch (error) {
    // Never block startup on attestation setup.
    debugPrint('App Check activation failed: $error');
  }
}
