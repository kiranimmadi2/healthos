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
        defaultValue: 'http://localhost:54321'),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'your-anon-key'),
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
