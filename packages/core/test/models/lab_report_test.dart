import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LabReport', () {
    final json = {
      'id': 'lr-12345678-abcd-ef01-2345-678901234567',
      'patient_id': 'p1-12345678-abcd-ef01-2345-678901234567',
      'visit_id': 'v1-12345678-abcd-ef01-2345-678901234567',
      'report_type': 'Complete Blood Count',
      'report_date': '2024-08-20T10:00:00.000',
      'file_url': 'https://storage.example.com/reports/cbc-001.pdf',
      'parsed_data': {
        'hemoglobin': 14.5,
        'wbc': 7200,
        'platelets': 250000,
      },
      'ai_summary':
          'All values within normal range. No abnormalities detected.',
      'status': 'completed',
      'lab_name': 'Apollo Diagnostics',
      'created_at': '2024-08-20T10:30:00.000',
    };

    test('fromJson parses all fields correctly', () {
      final report = LabReport.fromJson(json);

      expect(report.id, 'lr-12345678-abcd-ef01-2345-678901234567');
      expect(report.patientId, 'p1-12345678-abcd-ef01-2345-678901234567');
      expect(report.visitId, 'v1-12345678-abcd-ef01-2345-678901234567');
      expect(report.reportType, 'Complete Blood Count');
      expect(report.reportDate, DateTime.parse('2024-08-20T10:00:00.000'));
      expect(
          report.fileUrl, 'https://storage.example.com/reports/cbc-001.pdf');
      expect(report.parsedData?['hemoglobin'], 14.5);
      expect(report.parsedData?['wbc'], 7200);
      expect(report.parsedData?['platelets'], 250000);
      expect(report.aiSummary,
          'All values within normal range. No abnormalities detected.');
      expect(report.status, 'completed');
      expect(report.labName, 'Apollo Diagnostics');
      expect(report.createdAt, DateTime.parse('2024-08-20T10:30:00.000'));
    });

    test('fromJson and toJson round-trip', () {
      final report = LabReport.fromJson(json);
      final serialized = report.toJson();
      final roundTripped = LabReport.fromJson(serialized);
      expect(roundTripped, report);
    });

    test('copyWith creates modified copy', () {
      final report = LabReport(
        id: 'lr-1',
        patientId: 'p-1',
        reportType: 'Blood Sugar',
        reportDate: DateTime(2024, 8, 20),
      );

      final updated = report.copyWith(
        status: 'completed',
        aiSummary: 'Fasting blood sugar slightly elevated.',
        labName: 'SRL Diagnostics',
      );

      expect(updated.status, 'completed');
      expect(updated.aiSummary, 'Fasting blood sugar slightly elevated.');
      expect(updated.labName, 'SRL Diagnostics');
      expect(updated.id, 'lr-1');
      expect(updated.patientId, 'p-1');
      expect(updated.reportType, 'Blood Sugar');
    });

    test('copyWith preserves all fields when none changed', () {
      final report = LabReport.fromJson(json);
      final copy = report.copyWith();
      expect(copy, report);
    });

    test('defaults are applied', () {
      final report = LabReport(
        id: 'lr-1',
        patientId: 'p-1',
        reportType: 'Lipid Panel',
        reportDate: DateTime(2024, 8, 20),
      );

      expect(report.status, 'pending');
      expect(report.visitId, isNull);
      expect(report.fileUrl, isNull);
      expect(report.parsedData, isNull);
      expect(report.aiSummary, isNull);
      expect(report.labName, isNull);
      expect(report.createdAt, isNull);
    });

    test('fromJson handles minimal JSON (only required fields)', () {
      final minimalJson = {
        'id': 'lr-min',
        'patient_id': 'p-min',
        'report_type': 'Urinalysis',
        'report_date': '2024-08-20T10:00:00.000',
      };

      final report = LabReport.fromJson(minimalJson);
      expect(report.id, 'lr-min');
      expect(report.patientId, 'p-min');
      expect(report.reportType, 'Urinalysis');
      expect(report.status, 'pending');
      expect(report.visitId, isNull);
      expect(report.fileUrl, isNull);
      expect(report.parsedData, isNull);
    });

    test('fromJson handles null optional fields explicitly', () {
      final jsonWithNulls = {
        'id': 'lr-null',
        'patient_id': 'p-null',
        'report_type': 'Test',
        'report_date': '2024-08-20T10:00:00.000',
        'visit_id': null,
        'file_url': null,
        'parsed_data': null,
        'ai_summary': null,
        'lab_name': null,
        'created_at': null,
      };

      final report = LabReport.fromJson(jsonWithNulls);
      expect(report.visitId, isNull);
      expect(report.fileUrl, isNull);
      expect(report.parsedData, isNull);
      expect(report.aiSummary, isNull);
      expect(report.labName, isNull);
      expect(report.createdAt, isNull);
    });

    test('parsedData preserves nested map structure', () {
      final jsonWithNestedData = {
        'id': 'lr-nested',
        'patient_id': 'p-nested',
        'report_type': 'Comprehensive',
        'report_date': '2024-08-20T10:00:00.000',
        'parsed_data': {
          'section_a': {'value': 1, 'unit': 'mg/dL'},
          'section_b': {'value': 2, 'unit': 'g/L'},
        },
      };

      final report = LabReport.fromJson(jsonWithNestedData);
      expect(report.parsedData, isA<Map<String, dynamic>>());
      expect(
          (report.parsedData?['section_a'] as Map)['value'], 1);
      expect(
          (report.parsedData?['section_b'] as Map)['unit'], 'g/L');
    });
  });
}
