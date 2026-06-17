import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/doctor_profile.dart';

class DoctorRepository {
  final FirebaseFirestore _db;
  DoctorRepository(this._db);

  Stream<List<DoctorProfile>> watchAvailableDoctors() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => DoctorProfile.fromMap(doc.id, doc.data()))
                  .toList()
                ..sort((a, b) => a.name.compareTo(b.name)),
        );
  }
}
