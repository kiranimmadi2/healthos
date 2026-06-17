import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/appointment.dart';

class AppointmentRepository {
  final FirebaseFirestore _db;
  AppointmentRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('appointments');

  // Sorting happens client-side so no composite Firestore index is needed.
  Stream<List<Appointment>> watchForPatient(String patientId) {
    return _collection
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map(_toSortedList);
  }

  Stream<List<Appointment>> watchForDoctor(String doctorId) {
    return _collection
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map(_toSortedList);
  }

  List<Appointment> _toSortedList(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final uniqueAppointments = <String, Appointment>{};
    for (final doc in snapshot.docs) {
      final appointment = Appointment.fromDoc(doc);
      final key =
          '${appointment.patientId}|${appointment.doctorId}|'
          '${appointment.dateTime.millisecondsSinceEpoch}';
      final existing = uniqueAppointments[key];
      if (existing == null ||
          _statusPriority(appointment.status) >
              _statusPriority(existing.status)) {
        uniqueAppointments[key] = appointment;
      }
    }

    final appointments = uniqueAppointments.values.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return appointments;
  }

  int _statusPriority(String status) {
    return switch (status) {
      AppointmentStatus.confirmed => 4,
      AppointmentStatus.pending => 3,
      AppointmentStatus.completed => 2,
      AppointmentStatus.cancelled => 1,
      _ => 0,
    };
  }

  String _slotId(Appointment appointment) {
    return '${appointment.doctorId}_${appointment.dateTime.millisecondsSinceEpoch}';
  }

  Future<void> book(Appointment appointment) async {
    final slot = _collection.doc(_slotId(appointment));
    await _db.runTransaction((transaction) async {
      final existing = await transaction.get(slot);
      if (existing.exists) {
        final status =
            existing.data()?['status'] as String? ?? AppointmentStatus.pending;
        if (status == AppointmentStatus.pending ||
            status == AppointmentStatus.confirmed) {
          throw const AppointmentSlotUnavailableException();
        }
      }
      transaction.set(slot, appointment.toMap());
    });
  }

  Future<void> updateStatus(String appointmentId, String status) {
    return _collection.doc(appointmentId).update({'status': status});
  }
}

class AppointmentSlotUnavailableException implements Exception {
  const AppointmentSlotUnavailableException();

  @override
  String toString() => 'This time was already booked. Please choose another.';
}
