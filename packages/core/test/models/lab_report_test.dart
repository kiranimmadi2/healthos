import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LabReport', () {
    test('fromJson and toJson round-trip', () {
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

      final report = LabReport.fromJson(json);

      expect(report.id, 'lr-12345678-abcd-ef01-2345-678901234567');
      expect(report.patientId, 'p1-12345678-abcd-ef01-2345-678901234567');
      expect(report.visitId, 'v1-12345678-abcd-ef01-2345-678901234567');
      expect(report.reportType, 'Complete Blood Count');
      expect(report.reportDate, DateTime.parse('2024-08-20T10:00:00.000'));
      expect(report.fileUrl,
          'https://storage.example.com/reports/cbc-001.pdf');
      expect(report.parsedData?['hemoglobin'], 14.5);
      expect(report.parsedData?['wbc'], 7200);
      expect(report.aiSummary,
          'All values within normal range. No abnormalities detected.');
      expect(report.status, 'completed');
      expect(report.labName, 'Apollo Diagnostics');

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
  });
}
