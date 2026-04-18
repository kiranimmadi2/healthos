import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_client/supabase_client.dart';

void main() {
  group('LabReport.fromJson', () {
    test('parses a fully-populated JSON payload', () {
      final json = <String, dynamic>{
        'id': 'lr-001',
        'patient_id': 'p-001',
        'visit_id': 'v-001',
        'report_type': 'CBC',
        'report_date': '2025-03-10T00:00:00.000Z',
        'file_url': 'https://storage.example.com/reports/lr-001.pdf',
        'parsed_data': {
          'hemoglobin': 14.5,
          'wbc': 7000,
        },
        'ai_summary': 'All values within normal range.',
        'status': 'completed',
        'lab_name': 'Apollo Diagnostics',
        'created_at': '2025-03-10T08:30:00.000Z',
      };

      final report = LabReport.fromJson(json);

      expect(report.id, 'lr-001');
      expect(report.patientId, 'p-001');
      expect(report.visitId, 'v-001');
      expect(report.reportType, 'CBC');
      expect(report.reportDate, DateTime.utc(2025, 3, 10));
      expect(report.fileUrl, isNotNull);
      expect(report.parsedData, isA<Map<String, dynamic>>());
      expect(report.parsedData!['hemoglobin'], 14.5);
      expect(report.aiSummary, 'All values within normal range.');
      expect(report.status, 'completed');
      expect(report.labName, 'Apollo Diagnostics');
      expect(report.createdAt, isNotNull);
    });

    test('parses JSON with only required fields', () {
      final json = <String, dynamic>{
        'id': 'lr-002',
        'patient_id': 'p-002',
        'report_type': 'Lipid Panel',
        'report_date': '2025-03-12T00:00:00.000Z',
      };

      final report = LabReport.fromJson(json);

      expect(report.id, 'lr-002');
      expect(report.patientId, 'p-002');
      expect(report.reportType, 'Lipid Panel');
      expect(report.visitId, isNull);
      expect(report.fileUrl, isNull);
      expect(report.parsedData, isNull);
      expect(report.aiSummary, isNull);
      expect(report.status, 'pending');
      expect(report.labName, isNull);
      expect(report.createdAt, isNull);
    });

    test('defaults status to pending when absent', () {
      final json = <String, dynamic>{
        'id': 'lr-003',
        'patient_id': 'p-003',
        'report_type': 'Thyroid Panel',
        'report_date': '2025-03-13T00:00:00.000Z',
      };

      final report = LabReport.fromJson(json);
      expect(report.status, 'pending');
    });

    test('parses different status values correctly', () {
      for (final status in ['pending', 'processing', 'completed', 'failed']) {
        final json = <String, dynamic>{
          'id': 'lr-status-$status',
          'patient_id': 'p-001',
          'report_type': 'CBC',
          'report_date': '2025-03-14T00:00:00.000Z',
          'status': status,
        };

        final report = LabReport.fromJson(json);
        expect(report.status, status);
      }
    });

    test('handles explicit null optional fields', () {
      final json = <String, dynamic>{
        'id': 'lr-004',
        'patient_id': 'p-004',
        'report_type': 'Urinalysis',
        'report_date': '2025-03-15T00:00:00.000Z',
        'visit_id': null,
        'file_url': null,
        'parsed_data': null,
        'ai_summary': null,
        'lab_name': null,
        'created_at': null,
      };

      final report = LabReport.fromJson(json);

      expect(report.visitId, isNull);
      expect(report.fileUrl, isNull);
      expect(report.parsedData, isNull);
      expect(report.aiSummary, isNull);
      expect(report.labName, isNull);
      expect(report.createdAt, isNull);
    });

    test('roundtrip: toJson then fromJson preserves data', () {
      final original = LabReport(
        id: 'lr-005',
        patientId: 'p-005',
        reportType: 'HbA1c',
        reportDate: DateTime.utc(2025, 3, 20),
        status: 'completed',
        labName: 'SRL Diagnostics',
        aiSummary: 'Slightly elevated HbA1c.',
      );

      final rebuilt = LabReport.fromJson(original.toJson());

      expect(rebuilt.id, original.id);
      expect(rebuilt.patientId, original.patientId);
      expect(rebuilt.reportType, original.reportType);
      expect(rebuilt.reportDate, original.reportDate);
      expect(rebuilt.status, original.status);
      expect(rebuilt.labName, original.labName);
      expect(rebuilt.aiSummary, original.aiSummary);
    });
  });

  group('LabReportRepository instantiation', () {
    test('LabReportRepository can be constructed', () {
      final repo = LabReportRepository();
      expect(repo, isNotNull);
    });
  });
}
