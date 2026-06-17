import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class AppointmentStatus {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
}

class Appointment {
  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.dateTime,
    required this.status,
    this.specialization = '',
    this.symptoms,
  });

  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String specialization;
  final DateTime dateTime;
  final String status;
  final String? symptoms;

  bool get isUpcoming =>
      dateTime.isAfter(DateTime.now()) &&
      (status == AppointmentStatus.pending ||
          status == AppointmentStatus.confirmed);

  factory Appointment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Appointment(
      id: doc.id,
      patientId: data['patientId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? 'Patient',
      doctorId: data['doctorId'] as String? ?? '',
      doctorName: data['doctorName'] as String? ?? 'Doctor',
      specialization: data['specialization'] as String? ?? '',
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? AppointmentStatus.pending,
      symptoms: data['symptoms'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialization': specialization,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      if (symptoms != null && symptoms!.isNotEmpty) 'symptoms': symptoms,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
