import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/medical_record.dart';

class RecordRepository {
  final FirebaseFirestore _db;
  RecordRepository(this._db);

  CollectionReference<Map<String, dynamic>> _records(String uid) =>
      _db.collection('users').doc(uid).collection('records');

  Stream<List<MedicalRecord>> watchRecords(String uid) {
    return _records(uid).snapshots().map(
      (snapshot) =>
          snapshot.docs.map(MedicalRecord.fromDoc).toList()
            ..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  Future<void> addRecord(String uid, MedicalRecord record) {
    return _records(uid).add(record.toMap());
  }

  Future<void> deleteRecord(String uid, String recordId) {
    return _records(uid).doc(recordId).delete();
  }
}
