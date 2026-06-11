import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

class AIService {
  final GenerativeModel _flashModel = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-1.5-flash',
  );
  
  final GenerativeModel _proModel = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-1.5-pro',
  );

  Future<String> getTriage(String symptoms) async {
    final prompt = '''
    You are a medical triage assistant. Analyze the following symptoms and categorize them into:
    1. EMERGENCY: Go to ER immediately.
    2. SEE DOCTOR: Book an appointment soon.
    3. HOME CARE: Rest and monitor.
    
    Provide a concise explanation for your choice.
    
    Symptoms: $symptoms
    ''';

    final response = await _flashModel.generateContent([Content.text(prompt)]);
    return response.text ?? 'Error generating triage.';
  }

  Future<String> getClinicalSummary(String medicalHistory) async {
    final prompt = '''
    You are a clinical assistant. Summarize the following patient medical history into 3 clear, actionable bullet points for a doctor.
    
    History: $medicalHistory
    ''';

    final response = await _proModel.generateContent([Content.text(prompt)]);
    return response.text ?? 'Error generating summary.';
  }
}
