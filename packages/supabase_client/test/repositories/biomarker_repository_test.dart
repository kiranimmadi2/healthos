import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_client/supabase_client.dart';

void main() {
  group('Biomarker.fromJson', () {
    test('parses a fully-populated normal-range biomarker', () {
      final json = <String, dynamic>{
        'id': 'bm-001',
        'report_id': 'lr-001',
        'patient_id': 'p-001',
        'name': 'Hemoglobin',
        'value': 14.5,
        'unit': 'g/dL',
        'normal_min': 13.0,
        'normal_max': 17.0,
        'is_abnormal': false,
        'recorded_at': '2025-03-01T09:00:00.000Z',
      };

      final biomarker = Biomarker.fromJson(json);

      expect(biomarker.id, 'bm-001');
      expect(biomarker.reportId, 'lr-001');
      expect(biomarker.patientId, 'p-001');
      expect(biomarker.name, 'Hemoglobin');
      expect(biomarker.value, 14.5);
      expect(biomarker.unit, 'g/dL');
      expect(biomarker.normalMin, 13.0);
      expect(biomarker.normalMax, 17.0);
      expect(biomarker.isAbnormal, isFalse);
      expect(biomarker.recordedAt, DateTime.utc(2025, 3, 1, 9));
    });

    test('parses a high-value abnormal biomarker', () {
      final json = <String, dynamic>{
        'id': 'bm-002',
        'report_id': 'lr-001',
        'patient_id': 'p-001',
        'name': 'Blood Glucose',
        'value': 250.0,
        'unit': 'mg/dL',
        'normal_min': 70.0,
        'normal_max': 140.0,
        'is_abnormal': true,
        'recorded_at': '2025-03-01T09:00:00.000Z',
      };

      final biomarker = Biomarker.fromJson(json);

      expect(biomarker.isAbnormal, isTrue);
      expect(biomarker.value, 250.0);
    });

    test('parses with minimal optional fields (no unit, no normal range)', () {
      final json = <String, dynamic>{
        'id': 'bm-003',
        'report_id': 'lr-002',
        'patient_id': 'p-002',
        'name': 'Custom Marker',
        'value': 42.0,
        'recorded_at': '2025-03-02T10:00:00.000Z',
      };

      final biomarker = Biomarker.fromJson(json);

      expect(biomarker.unit, isNull);
      expect(biomarker.normalMin, isNull);
      expect(biomarker.normalMax, isNull);
      expect(biomarker.isAbnormal, isFalse);
    });

    test('handles explicit null optional fields', () {
      final json = <String, dynamic>{
        'id': 'bm-004',
        'report_id': 'lr-003',
        'patient_id': 'p-003',
        'name': 'Null Fields Marker',
        'value': 10.0,
        'unit': null,
        'normal_min': null,
        'normal_max': null,
        'recorded_at': '2025-03-03T12:00:00.000Z',
      };

      final biomarker = Biomarker.fromJson(json);

      expect(biomarker.unit, isNull);
      expect(biomarker.normalMin, isNull);
      expect(biomarker.normalMax, isNull);
    });

    test('handles integer value cast to double', () {
      final json = <String, dynamic>{
        'id': 'bm-005',
        'report_id': 'lr-004',
        'patient_id': 'p-004',
        'name': 'WBC Count',
        'value': 7000,
        'unit': 'cells/mcL',
        'normal_min': 4500,
        'normal_max': 11000,
        'recorded_at': '2025-03-04T08:00:00.000Z',
      };

      final biomarker = Biomarker.fromJson(json);

      expect(biomarker.value, 7000.0);
      expect(biomarker.value, isA<double>());
    });
  });

  group('Biomarker computed properties', () {
    Biomarker makeBiomarker({
      required double value,
      double? normalMin,
      double? normalMax,
    }) {
      return Biomarker(
        id: 'test-id',
        reportId: 'test-report',
        patientId: 'test-patient',
        name: 'Test',
        value: value,
        normalMin: normalMin,
        normalMax: normalMax,
        recordedAt: DateTime(2025, 1, 1),
      );
    }

    test('isNormal is true when value is within range', () {
      final biomarker = makeBiomarker(
        value: 15.0,
        normalMin: 10.0,
        normalMax: 20.0,
      );

      expect(biomarker.isNormal, isTrue);
      expect(biomarker.isLow, isFalse);
      expect(biomarker.isHigh, isFalse);
      expect(biomarker.statusLabel, 'Normal');
    });

    test('isLow is true when value is below normalMin', () {
      final biomarker = makeBiomarker(
        value: 5.0,
        normalMin: 10.0,
        normalMax: 20.0,
      );

      expect(biomarker.isLow, isTrue);
      expect(biomarker.isHigh, isFalse);
      expect(biomarker.isNormal, isFalse);
      expect(biomarker.statusLabel, 'Low');
    });

    test('isHigh is true when value is above normalMax', () {
      final biomarker = makeBiomarker(
        value: 25.0,
        normalMin: 10.0,
        normalMax: 20.0,
      );

      expect(biomarker.isHigh, isTrue);
      expect(biomarker.isLow, isFalse);
      expect(biomarker.isNormal, isFalse);
      expect(biomarker.statusLabel, 'High');
    });

    test('isNormal when value equals normalMin (boundary)', () {
      final biomarker = makeBiomarker(
        value: 10.0,
        normalMin: 10.0,
        normalMax: 20.0,
      );

      expect(biomarker.isLow, isFalse);
      expect(biomarker.isNormal, isTrue);
    });

    test('isNormal when value equals normalMax (boundary)', () {
      final biomarker = makeBiomarker(
        value: 20.0,
        normalMin: 10.0,
        normalMax: 20.0,
      );

      expect(biomarker.isHigh, isFalse);
      expect(biomarker.isNormal, isTrue);
    });

    test('isNormal is true when no reference range is set', () {
      final biomarker = makeBiomarker(value: 999.0);

      expect(biomarker.isLow, isFalse);
      expect(biomarker.isHigh, isFalse);
      expect(biomarker.isNormal, isTrue);
      expect(biomarker.statusLabel, 'Normal');
    });

    test('isLow with only normalMin set (no normalMax)', () {
      final biomarker = makeBiomarker(
        value: 3.0,
        normalMin: 5.0,
      );

      expect(biomarker.isLow, isTrue);
      expect(biomarker.isHigh, isFalse);
      expect(biomarker.isNormal, isFalse);
    });

    test('isHigh with only normalMax set (no normalMin)', () {
      final biomarker = makeBiomarker(
        value: 25.0,
        normalMax: 20.0,
      );

      expect(biomarker.isHigh, isTrue);
      expect(biomarker.isLow, isFalse);
      expect(biomarker.isNormal, isFalse);
    });

    test('displayValue formats correctly with unit', () {
      final biomarker = Biomarker(
        id: 'dv-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Hemoglobin',
        value: 14.567,
        unit: 'g/dL',
        recordedAt: DateTime(2025, 1, 1),
      );

      expect(biomarker.displayValue, '14.6 g/dL');
    });

    test('displayValue formats correctly without unit', () {
      final biomarker = Biomarker(
        id: 'dv-2',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Ratio',
        value: 1.2,
        recordedAt: DateTime(2025, 1, 1),
      );

      expect(biomarker.displayValue, '1.2 ');
    });

    test('referenceRange formats correctly', () {
      final biomarker = Biomarker(
        id: 'rr-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Hemoglobin',
        value: 14.0,
        unit: 'g/dL',
        normalMin: 13.0,
        normalMax: 17.0,
        recordedAt: DateTime(2025, 1, 1),
      );

      expect(biomarker.referenceRange, '13.0 - 17.0 g/dL');
    });

    test('referenceRange shows ? for missing bounds', () {
      final biomarker = Biomarker(
        id: 'rr-2',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Unknown',
        value: 5.0,
        recordedAt: DateTime(2025, 1, 1),
      );

      expect(biomarker.referenceRange, '? - ? ');
    });
  });

  group('BiomarkerRepository instantiation', () {
    test('BiomarkerRepository can be constructed', () {
      final repo = BiomarkerRepository();
      expect(repo, isNotNull);
    });
  });
}
