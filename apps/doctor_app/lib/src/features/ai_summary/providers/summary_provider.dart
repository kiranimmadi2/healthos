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
        defaultValue: 'https://gmozpsolmfwrihktdeqh.supabase.co'),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY',
        defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdtb3pwc29sbWZ3cmloa3RkZXFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3NjQxMTEsImV4cCI6MjA5MDM0MDExMX0.itV_0F4iuSvepl5cw4SAj52gFy_Vb2lu8QTEu-mhDHs'),
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
