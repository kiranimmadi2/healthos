import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'src/app/health_os_app.dart';
import 'src/services/reminders_service.dart';

export 'src/app/health_os_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await RemindersService().init();

  runApp(const ProviderScope(child: HealthOSApp()));
}
