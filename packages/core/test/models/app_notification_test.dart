import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppNotification', () {
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

    test('fromJson parses all fields correctly', () {
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
      expect(notification.createdAt,
          DateTime.parse('2024-10-01T14:00:00.000'));
    });

    test('fromJson and toJson round-trip', () {
      final notification = AppNotification.fromJson(json);
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

    test('copyWith preserves all fields when none changed', () {
      final notification = AppNotification.fromJson(json);
      final copy = notification.copyWith();
      expect(copy, notification);
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

    test('fromJson handles minimal JSON (only required fields)', () {
      final minimalJson = {
        'id': 'n-min',
        'title': 'Minimal Notification',
        'body': 'Just a body.',
      };

      final notification = AppNotification.fromJson(minimalJson);
      expect(notification.id, 'n-min');
      expect(notification.title, 'Minimal Notification');
      expect(notification.body, 'Just a body.');
      expect(notification.type, 'info');
      expect(notification.patientId, isNull);
      expect(notification.doctorId, isNull);
      expect(notification.readAt, isNull);
      expect(notification.actionRoute, isNull);
      expect(notification.metadata, isNull);
    });

    test('fromJson handles null optional fields explicitly', () {
      final jsonWithNulls = {
        'id': 'n-null',
        'title': 'Null Test',
        'body': 'Null body',
        'patient_id': null,
        'doctor_id': null,
        'read_at': null,
        'action_route': null,
        'metadata': null,
        'created_at': null,
      };

      final notification = AppNotification.fromJson(jsonWithNulls);
      expect(notification.patientId, isNull);
      expect(notification.doctorId, isNull);
      expect(notification.readAt, isNull);
      expect(notification.actionRoute, isNull);
      expect(notification.metadata, isNull);
      expect(notification.createdAt, isNull);
    });

    test('metadata preserves nested map structure', () {
      final notification = AppNotification.fromJson(json);
      expect(notification.metadata, isA<Map<String, dynamic>>());
      expect(notification.metadata!.keys,
          containsAll(['report_id', 'report_type']));
    });

    test('different notification types are preserved', () {
      final appointmentJson = {
        'id': 'n-apt',
        'title': 'Appointment',
        'body': 'Your appointment is confirmed.',
        'type': 'appointment',
      };

      final notification = AppNotification.fromJson(appointmentJson);
      expect(notification.type, 'appointment');
    });

    test('unread notification has null readAt', () {
      final unreadJson = {
        'id': 'n-unread',
        'title': 'New Message',
        'body': 'You have a new message.',
      };

      final notification = AppNotification.fromJson(unreadJson);
      expect(notification.readAt, isNull);
    });
  });
}
