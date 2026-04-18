import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';
import 'repository_logger.dart';

class PatientDocumentRepository with RepositoryLogger {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<List<PatientDocument>> getForPatient(String patientId) => loggedOp(
        'getForPatient(patientId=$patientId)',
        () async {
          final response = await _client
              .from(SupabaseTables.patientDocuments)
              .select()
              .eq('patient_id', patientId)
              .order('uploaded_at', ascending: false);
          return response
              .map((e) => PatientDocument.fromJson(e))
              .toList();
        },
      );

  Future<PatientDocument?> getById(String id) => loggedOp(
        'getById(id=$id)',
        () async {
          final response = await _client
              .from(SupabaseTables.patientDocuments)
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response == null) return null;
          return PatientDocument.fromJson(response);
        },
      );

  /// Uploads [bytes] to the patient-documents storage bucket and inserts a
  /// row in patient_documents. Returns the created document.
  Future<PatientDocument> uploadAndCreate({
    required String patientId,
    required String title,
    required String kind,
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? notes,
  }) =>
      loggedOp(
        'uploadAndCreate(kind=$kind, name=$fileName)',
        () async {
          final storagePath = '$patientId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
          await _client.storage
              .from(SupabaseBuckets.patientDocuments)
              .uploadBinary(
                storagePath,
                bytes,
                fileOptions: FileOptions(contentType: mimeType, upsert: false),
              );

          final signed = await _client.storage
              .from(SupabaseBuckets.patientDocuments)
              .createSignedUrl(storagePath, 60 * 60 * 24 * 30); // 30 days

          final response = await _client
              .from(SupabaseTables.patientDocuments)
              .insert({
                'patient_id': patientId,
                'title': title,
                'kind': kind,
                'notes': notes,
                'storage_path': storagePath,
                'file_url': signed,
                'mime_type': mimeType,
                'size_bytes': bytes.length,
              })
              .select()
              .single();

          return PatientDocument.fromJson(response);
        },
      );

  Future<String> freshSignedUrl(String storagePath) => loggedOp(
        'freshSignedUrl(path=$storagePath)',
        () => _client.storage
            .from(SupabaseBuckets.patientDocuments)
            .createSignedUrl(storagePath, 60 * 60),
      );

  Future<void> delete(String id, String storagePath) => loggedOp(
        'delete(id=$id)',
        () async {
          await _client.storage
              .from(SupabaseBuckets.patientDocuments)
              .remove([storagePath]);
          await _client
              .from(SupabaseTables.patientDocuments)
              .delete()
              .eq('id', id);
        },
      );
}
