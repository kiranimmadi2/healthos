import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseClientInitializer.initialize(
    url: const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'http://localhost:54321'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'your-anon-key'),
  );

  runApp(
    const ProviderScope(
      child: HealthOSHospitalPortal(),
    ),
  );
}
