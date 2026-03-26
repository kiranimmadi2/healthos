import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppNotification', () {
    test('fromJson and toJson round-trip', () {
      final json = {
        'id': 'n1-12345678-abcd-ef01-2345-678901234567',
        'patient_id': 'p1-12345678-abcd-ef01-2345-678901234567',
        'doctor_id': 'd1-12345678-abcd-ef01-2345-678901234567',
        'title': 'Lab Report Ready',
        'body':
            'Your Complete Blood Count report is now available for review.',
        'type': 'lab_report',
        'read_at': '2024-10-02T09:15:00.000',
        'action_route': '/reports/lr-001',
        'metadata': {
          'report_id': 'lr-001',
          'report_type': 'CBC',
        },
        'created_at': '2024-10-01T14:00:00.000',
      };

      final notification = AppNotification.fromJson(json);

      expect(notification.id, 'n1-12345678-abcd-ef01-2345-678901234567');
      expect(notification.patientId,
          'p1-12345678-abcd-ef01-2345-678901234567');
      expect(notification.doctorId,
          'd1-12345678-abcd-ef01-2345-678901234567');
      expect(notification.title, 'Lab Report Ready');
      expect(notification.body, contains('Complete Blood Count'));
      expect(notification.type, 'lab_report');
      expect(notification.readAt,
          DateTime.parse('2024-10-02T09:15:00.000'));
      expect(notification.actionRoute, '/reports/lr-001');
      expect(notification.metadata?['report_id'], 'lr-001');
      expect(notification.metadata?['report_type'], 'CBC');

      final serialized = notification.toJson();
      final roundTripped = AppNotification.fromJson(serialized);
      expect(roundTripped, notification);
    });

    test('copyWith creates modified copy', () {
      final notification = AppNotification(
        id: 'n-1',
        title: 'Appointment Reminder',
        body: 'You have an appointment tomorrow at 10 AM.',
      );

      final updated = notification.copyWith(
        readAt: DateTime(2024, 10, 2, 9, 0),
        type: 'appointment',
      );

      expect(updated.readAt, DateTime(2024, 10, 2, 9, 0));
      expect(updated.type, 'appointment');
      expect(updated.id, 'n-1');
      expect(updated.title, 'Appointment Reminder');
      expect(updated.body, 'You have an appointment tomorrow at 10 AM.');
    });

    test('defaults are applied', () {
      final notification = AppNotification(
        id: 'n-1',
        title: 'Test',
        body: 'Test body',
      );

      expect(notification.type, 'info');
      expect(notification.patientId, isNull);
      expect(notification.doctorId, isNull);
      expect(notification.readAt, isNull);
      expect(notification.actionRoute, isNull);
      expect(notification.metadata, isNull);
      expect(notification.createdAt, isNull);
    });
  });
}
