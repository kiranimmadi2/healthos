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
}

class SupabaseBuckets {
  SupabaseBuckets._();

  static const String labReports = 'lab-reports';
  static const String avatars = 'avatars';
  static const String prescriptionImages = 'prescription-images';
}

class SupabaseFunctions {
  SupabaseFunctions._();

  static const String aiSymptom = 'ai-symptom';
  static const String aiSummary = 'ai-summary';
  static const String ocrReport = 'ocr-report';
  static const String sendNotification = 'notifications';
}
