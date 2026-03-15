import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';

class StorageService {
  SupabaseClient get _client => SupabaseClientInitializer.client;

  Future<String> uploadLabReport({
    required String patientId,
    required String fileName,
    required Uint8List fileBytes,
    String? mimeType,
  }) async {
    final path = '$patientId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from(SupabaseBuckets.labReports).uploadBinary(
      path,
      fileBytes,
      fileOptions: FileOptions(contentType: mimeType),
    );
    return _client.storage
        .from(SupabaseBuckets.labReports)
        .getPublicUrl(path);
  }

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List fileBytes,
    String? mimeType,
  }) async {
    final path = '$userId/avatar.jpg';
    await _client.storage.from(SupabaseBuckets.avatars).uploadBinary(
      path,
      fileBytes,
      fileOptions: FileOptions(contentType: mimeType ?? 'image/jpeg', upsert: true),
    );
    return _client.storage
        .from(SupabaseBuckets.avatars)
        .getPublicUrl(path);
  }

  Future<Uint8List> downloadFile({
    required String bucket,
    required String path,
  }) async {
    return await _client.storage.from(bucket).download(path);
  }

  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }
}
