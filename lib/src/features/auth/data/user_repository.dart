import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _db;
  UserRepository(this._db);

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> createUserData(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).set(data);
  }

  Stream<List<Map<String, dynamic>>> watchPatients() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['uid'] = doc.id;
                return data;
              }).toList()
                ..sort(
                  (a, b) =>
                      (a['name'] as String? ?? '').compareTo(
                        b['name'] as String? ?? '',
                      ),
                ),
        );
  }
}
