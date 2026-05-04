import 'package:ai_client/ai_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Provides an [AiService] instance configured with Supabase credentials
/// and the current Firebase user's ID token as the access token.
final aiServiceProvider = FutureProvider<AiService>((ref) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  final accessToken = await firebaseUser?.getIdToken();

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
  final aiService = await ref.read(aiServiceProvider.future);
  return aiService.getPatientSummary(
    SummaryRequest(patientId: patientId),
  );
});
