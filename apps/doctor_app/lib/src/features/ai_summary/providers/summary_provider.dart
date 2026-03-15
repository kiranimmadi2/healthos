import 'package:ai_client/ai_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../providers/auth_provider.dart';

/// Provides an [AiService] instance configured with Supabase credentials
/// and the current user's access token.
final aiServiceProvider = Provider<AiService>((ref) {
  final client = SupabaseClientInitializer.client;
  final accessToken = client.auth.currentSession?.accessToken;

  return AiService(
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL',
        defaultValue: 'https://jeantydukopukfvydixl.supabase.co'),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImplYW50eWR1a29wdWtmdnlkaXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1ODUxMzAsImV4cCI6MjA4OTE2MTEzMH0.TdZAU3iN5OPT9NmlhtISBme4GnKjd7lEG1vG4YH9byw'),
    accessToken: accessToken,
  );
});

/// Fetches an AI-generated patient summary by calling the ai-summary
/// Edge Function. Keyed by patient ID so each patient's summary is cached.
final patientSummaryProvider =
    FutureProvider.family<AiSummaryResponse, String>((ref, patientId) async {
  final aiService = ref.read(aiServiceProvider);
  return aiService.getPatientSummary(
    SummaryRequest(patientId: patientId),
  );
});
