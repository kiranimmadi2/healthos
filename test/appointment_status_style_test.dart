import 'package:flutter_test/flutter_test.dart';
import 'package:healthos/src/features/appointments/domain/appointment.dart';
import 'package:healthos/src/features/appointments/presentation/appointment_status_style.dart';

void main() {
  group('AppointmentStatusStyle.of', () {
    test('maps every known status', () {
      expect(
        AppointmentStatusStyle.of(AppointmentStatus.pending),
        AppointmentStatusStyle.pending,
      );
      expect(
        AppointmentStatusStyle.of(AppointmentStatus.confirmed),
        AppointmentStatusStyle.confirmed,
      );
      expect(
        AppointmentStatusStyle.of(AppointmentStatus.completed),
        AppointmentStatusStyle.completed,
      );
      expect(
        AppointmentStatusStyle.of(AppointmentStatus.cancelled),
        AppointmentStatusStyle.cancelled,
      );
    });

    test('falls back to pending for unknown values', () {
      // Preserves the previous `default:` behaviour of the three call sites.
      expect(AppointmentStatusStyle.of(''), AppointmentStatusStyle.pending);
      expect(
        AppointmentStatusStyle.of('something-new'),
        AppointmentStatusStyle.pending,
      );
    });

    test('labels are stable and human readable', () {
      expect(
        AppointmentStatusStyle.values.map((s) => s.label),
        ['Pending', 'Confirmed', 'Completed', 'Cancelled'],
      );
    });

    test('every status has a distinct colour pair', () {
      final foregrounds =
          AppointmentStatusStyle.values.map((s) => s.foreground).toSet();
      expect(foregrounds, hasLength(AppointmentStatusStyle.values.length));
    });
  });

  group('toPill', () {
    test('carries the style through and honours showIcon', () {
      final withIcon = AppointmentStatusStyle.confirmed.toPill();
      expect(withIcon.label, 'Confirmed');
      expect(withIcon.foreground, AppointmentStatusStyle.confirmed.foreground);
      expect(withIcon.icon, isNotNull);

      expect(
        AppointmentStatusStyle.confirmed.toPill(showIcon: false).icon,
        isNull,
      );
    });
  });

  group('forAppointment', () {
    test('reads the status off the appointment', () {
      final appointment = Appointment(
        id: 'a1',
        patientId: 'p1',
        patientName: 'Pat',
        doctorId: 'd1',
        doctorName: 'Dr Who',
        dateTime: DateTime(2026, 9, 1),
        status: AppointmentStatus.cancelled,
      );
      expect(
        AppointmentStatusStyle.forAppointment(appointment),
        AppointmentStatusStyle.cancelled,
      );
    });
  });
}
