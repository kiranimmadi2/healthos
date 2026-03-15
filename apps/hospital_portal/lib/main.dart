import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseClientInitializer.initialize(
    url: const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'https://jeantydukopukfvydixl.supabase.co'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImplYW50eWR1a29wdWtmdnlkaXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1ODUxMzAsImV4cCI6MjA4OTE2MTEzMH0.TdZAU3iN5OPT9NmlhtISBme4GnKjd7lEG1vG4YH9byw'),
  );

  runApp(
    const ProviderScope(
      child: HealthOSHospitalPortal(),
    ),
  );
}
