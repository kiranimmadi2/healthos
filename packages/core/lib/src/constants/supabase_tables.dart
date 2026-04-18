class SupabaseTables {
  SupabaseTables._();

  static const String patients = 'patients';
  static const String doctors = 'doctors';
  static const String hospitals = 'hospitals';
  static const String accessGrants = 'access_grants';
  static const String visits = 'visits';
  static const String labReports = 'lab_reports';
  static const String biomarkers = 'biomarkers';
  static const String prescriptions = 'prescriptions';
  static const String symptomSessions = 'symptom_sessions';
  static const String patientEmbeddings = 'patient_embeddings';
  static const String notifications = 'notifications';
  static const String appointments = 'appointments';
  static const String familyMembers = 'family_members';
  static const String visitVitals = 'visit_vitals';
  static const String doctorNotes = 'doctor_notes';
}

class SupabaseBuckets {
  SupabaseBuckets._();

  static const String labReports = 'lab-reports';
  static const String avatars = 'avatars';
  static const String prescriptionImages = 'prescription-images';
}

class SupabaseFunctions {
  SupabaseFunctions._();

  // Legacy function names (kept for backward compatibility)
  static const String aiSymptom = 'ai-symptom';
  static const String aiSummary = 'ai-summary';
  static const String ocrReport = 'ocr-report';
  static const String sendNotification = 'notifications';
}

/// Microservice edge function names and route helpers.
class HealthOSServices {
  HealthOSServices._();

  // Service function names
  static const String patientService = 'patient-service';
  static const String clinicalService = 'clinical-service';
  static const String appointmentService = 'appointment-service';
  static const String aiService = 'ai-service';
  static const String notificationService = 'notification-service';
  static const String familyService = 'family-service';
}
