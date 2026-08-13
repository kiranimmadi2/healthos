import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthos/src/features/appointments/data/appointment_repository.dart';
import 'package:healthos/src/features/appointments/domain/appointment.dart';

/// Regression coverage for the transactional slot lock in
/// [AppointmentRepository.book].
///
/// This is the most logic-dense method in the codebase and had zero tests.
/// These are pinned down *before* any refactor touches the file, so that
/// changes to `toMap()` (e.g. adding `hospitalId`) or to `firestore.rules`
/// cannot silently change the double-booking behaviour.
void main() {
  late FakeFirebaseFirestore db;
  late AppointmentRepository repo;

  final slotTime = DateTime(2026, 9, 1, 10);

  Appointment appointmentFor({
    required String patientId,
    String status = AppointmentStatus.pending,
    DateTime? at,
    String doctorId = 'doc-1',
  }) {
    return Appointment(
      id: '',
      patientId: patientId,
      patientName: 'Patient $patientId',
      doctorId: doctorId,
      doctorName: 'Dr Who',
      specialization: 'Cardiology',
      dateTime: at ?? slotTime,
      status: status,
      symptoms: 'chest tightness',
    );
  }

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = AppointmentRepository(db);
  });

  group('book() slot locking', () {
    test('writes the appointment to a deterministic slot id', () async {
      await repo.book(appointmentFor(patientId: 'pat-1'));

      final expectedId = 'doc-1_${slotTime.millisecondsSinceEpoch}';
      final doc = await db.collection('appointments').doc(expectedId).get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['patientId'], 'pat-1');
      expect(doc.data()!['doctorId'], 'doc-1');
      expect(doc.data()!['status'], AppointmentStatus.pending);
    });

    test('rejects a second booking of a pending slot', () async {
      await repo.book(appointmentFor(patientId: 'pat-1'));

      expect(
        () => repo.book(appointmentFor(patientId: 'pat-2')),
        throwsA(isA<AppointmentSlotUnavailableException>()),
      );
    });

    test('rejects a second booking of a confirmed slot', () async {
      await repo.book(
        appointmentFor(patientId: 'pat-1', status: AppointmentStatus.confirmed),
      );

      expect(
        () => repo.book(appointmentFor(patientId: 'pat-2')),
        throwsA(isA<AppointmentSlotUnavailableException>()),
      );
    });

    test('does not overwrite the original booking when rejected', () async {
      await repo.book(appointmentFor(patientId: 'pat-1'));
      try {
        await repo.book(appointmentFor(patientId: 'pat-2'));
      } on AppointmentSlotUnavailableException {
        // expected
      }

      final doc = await db
          .collection('appointments')
          .doc('doc-1_${slotTime.millisecondsSinceEpoch}')
          .get();
      expect(doc.data()!['patientId'], 'pat-1');
    });

    test('allows rebooking a cancelled slot', () async {
      await repo.book(
        appointmentFor(patientId: 'pat-1', status: AppointmentStatus.cancelled),
      );

      await repo.book(appointmentFor(patientId: 'pat-2'));

      final doc = await db
          .collection('appointments')
          .doc('doc-1_${slotTime.millisecondsSinceEpoch}')
          .get();
      expect(doc.data()!['patientId'], 'pat-2');
    });

    test('allows rebooking a completed slot', () async {
      await repo.book(
        appointmentFor(patientId: 'pat-1', status: AppointmentStatus.completed),
      );

      await repo.book(appointmentFor(patientId: 'pat-2'));

      final doc = await db
          .collection('appointments')
          .doc('doc-1_${slotTime.millisecondsSinceEpoch}')
          .get();
      expect(doc.data()!['patientId'], 'pat-2');
    });

    test('different times on the same doctor are independent slots', () async {
      await repo.book(appointmentFor(patientId: 'pat-1'));
      await repo.book(
        appointmentFor(
          patientId: 'pat-2',
          at: slotTime.add(const Duration(hours: 1)),
        ),
      );

      final all = await db.collection('appointments').get();
      expect(all.docs, hasLength(2));
    });

    test('the same time on different doctors are independent slots', () async {
      await repo.book(appointmentFor(patientId: 'pat-1'));
      await repo.book(appointmentFor(patientId: 'pat-2', doctorId: 'doc-2'));

      final all = await db.collection('appointments').get();
      expect(all.docs, hasLength(2));
    });
  });

  group('watch queries', () {
    test('watchForPatient returns only that patient, sorted by time', () async {
      await repo.book(
        appointmentFor(
          patientId: 'pat-1',
          at: slotTime.add(const Duration(hours: 2)),
        ),
      );
      await repo.book(appointmentFor(patientId: 'pat-1'));
      await repo.book(appointmentFor(patientId: 'pat-2', doctorId: 'doc-9'));

      final result = await repo.watchForPatient('pat-1').first;

      expect(result, hasLength(2));
      expect(result.every((a) => a.patientId == 'pat-1'), isTrue);
      expect(result.first.dateTime.isBefore(result.last.dateTime), isTrue);
    });

    test('watchForDoctor returns only that doctor', () async {
      await repo.book(appointmentFor(patientId: 'pat-1'));
      await repo.book(appointmentFor(patientId: 'pat-2', doctorId: 'doc-2'));

      final result = await repo.watchForDoctor('doc-1').first;

      expect(result, hasLength(1));
      expect(result.single.doctorId, 'doc-1');
    });
  });

  group('updateStatus', () {
    test('changes only the status field', () async {
      await repo.book(appointmentFor(patientId: 'pat-1'));
      final id = 'doc-1_${slotTime.millisecondsSinceEpoch}';

      await repo.updateStatus(id, AppointmentStatus.confirmed);

      final doc = await db.collection('appointments').doc(id).get();
      expect(doc.data()!['status'], AppointmentStatus.confirmed);
      expect(doc.data()!['patientId'], 'pat-1');
    });
  });

  group('Appointment mapping', () {
    test('round-trips through Firestore', () async {
      await repo.book(appointmentFor(patientId: 'pat-1'));
      final doc = await db
          .collection('appointments')
          .doc('doc-1_${slotTime.millisecondsSinceEpoch}')
          .get();

      final parsed = Appointment.fromDoc(
        doc as DocumentSnapshot<Map<String, dynamic>>,
      );

      expect(parsed.patientId, 'pat-1');
      expect(parsed.doctorName, 'Dr Who');
      expect(parsed.specialization, 'Cardiology');
      expect(parsed.symptoms, 'chest tightness');
      expect(parsed.dateTime, slotTime);
    });
  });
}
