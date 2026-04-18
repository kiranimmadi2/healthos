import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';

final labReportRepoProvider = Provider((ref) => LabReportRepository());
final patientRepoProvider = Provider((ref) => PatientRepository());
final biomarkerRepoProvider = Provider((ref) => BiomarkerRepository());
