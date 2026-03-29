import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      await SupabaseClientInitializer.client.auth.signOut();
    }
  } catch (_) {
    // If session check fails, clear it to prevent crash loops
    try {
      await SupabaseClientInitializer.client.auth.signOut();
    } catch (_) {}
  }

  runApp(
    const ProviderScope(
      child: HealthOSHospitalPortal(),
    ),
  );
}
