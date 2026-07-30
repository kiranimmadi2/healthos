import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _db;
  UserRepository(this._db);

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  Future<void> createUserData(String uid, Map<String, dynamic> data) {
    final merged = {
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    return _db.collection('users').doc(uid).set(merged, SetOptions(merge: true));
  }

  /// Records an authentication provider (e.g. 'password', 'emailLink', 'google.com')
  /// against the user's Firestore document.
  Future<void> recordSignInProvider(
    String uid,
    String providerId, {
    String? email,
    String? name,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'authProviders': FieldValue.arrayUnion([providerId]),
        'lastSignInAt': FieldValue.serverTimestamp(),
        if (email != null) 'email': email.toLowerCase(),
        if (name != null) 'name': name,
      };
      await _db.collection('users').doc(uid).set(updateData, SetOptions(merge: true));
    } catch (_) {
      // Graceful fallback if Firestore is uninitialized or offline
    }
  }

  /// Searches for an existing user document by email address.
  Future<String?> findUidByEmail(String email) async {
    try {
      final query = await _db
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
    } catch (_) {}
    return null;
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
