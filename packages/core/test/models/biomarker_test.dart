import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Biomarker', () {
    final recordedAt = DateTime(2024, 8, 20, 10, 0);

    final json = {
      'id': 'bm-12345678-abcd-ef01-2345-678901234567',
      'report_id': 'lr-12345678-abcd-ef01-2345-678901234567',
      'patient_id': 'p1-12345678-abcd-ef01-2345-678901234567',
      'name': 'Haemoglobin',
      'value': 14.5,
      'unit': 'g/dL',
      'normal_min': 12.0,
      'normal_max': 17.0,
      'is_abnormal': false,
      'recorded_at': '2024-08-20T10:00:00.000',
    };

    test('fromJson parses all fields correctly', () {
      final biomarker = Biomarker.fromJson(json);

      expect(biomarker.id, 'bm-12345678-abcd-ef01-2345-678901234567');
      expect(biomarker.reportId, 'lr-12345678-abcd-ef01-2345-678901234567');
      expect(biomarker.patientId, 'p1-12345678-abcd-ef01-2345-678901234567');
      expect(biomarker.name, 'Haemoglobin');
      expect(biomarker.value, 14.5);
      expect(biomarker.unit, 'g/dL');
      expect(biomarker.normalMin, 12.0);
      expect(biomarker.normalMax, 17.0);
      expect(biomarker.isAbnormal, false);
      expect(
          biomarker.recordedAt, DateTime.parse('2024-08-20T10:00:00.000'));
    });

    test('fromJson and toJson round-trip', () {
      final biomarker = Biomarker.fromJson(json);
      final serialized = biomarker.toJson();
      final roundTripped = Biomarker.fromJson(serialized);
      expect(roundTripped, biomarker);
    });

    test('isLow computed correctly', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Haemoglobin',
        value: 10.0,
        unit: 'g/dL',
        normalMin: 12.0,
        normalMax: 17.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.isLow, true);
      expect(biomarker.isHigh, false);
      expect(biomarker.isNormal, false);
      expect(biomarker.statusLabel, 'Low');
    });

    test('isHigh computed correctly', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Haemoglobin',
        value: 20.0,
        unit: 'g/dL',
        normalMin: 12.0,
        normalMax: 17.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.isLow, false);
      expect(biomarker.isHigh, true);
      expect(biomarker.isNormal, false);
      expect(biomarker.statusLabel, 'High');
    });

    test('isNormal computed correctly', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Haemoglobin',
        value: 14.0,
        unit: 'g/dL',
        normalMin: 12.0,
        normalMax: 17.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.isLow, false);
      expect(biomarker.isHigh, false);
      expect(biomarker.isNormal, true);
      expect(biomarker.statusLabel, 'Normal');
    });

    test('boundary values: value at normalMin is normal', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Haemoglobin',
        value: 12.0,
        unit: 'g/dL',
        normalMin: 12.0,
        normalMax: 17.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.isLow, false);
      expect(biomarker.isNormal, true);
    });

    test('boundary values: value at normalMax is normal', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Haemoglobin',
        value: 17.0,
        unit: 'g/dL',
        normalMin: 12.0,
        normalMax: 17.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.isHigh, false);
      expect(biomarker.isNormal, true);
    });

    test('boundary values: value just below normalMin is low', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Haemoglobin',
        value: 11.9,
        unit: 'g/dL',
        normalMin: 12.0,
        normalMax: 17.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.isLow, true);
      expect(biomarker.statusLabel, 'Low');
    });

    test('boundary values: value just above normalMax is high', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Haemoglobin',
        value: 17.1,
        unit: 'g/dL',
        normalMin: 12.0,
        normalMax: 17.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.isHigh, true);
      expect(biomarker.statusLabel, 'High');
    });

    test('displayValue formats correctly with unit', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Haemoglobin',
        value: 14.5,
        unit: 'g/dL',
        recordedAt: recordedAt,
      );

      expect(biomarker.displayValue, '14.5 g/dL');
    });

    test('displayValue formats correctly without unit', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'RBC Index',
        value: 4.2,
        recordedAt: recordedAt,
      );

      expect(biomarker.displayValue, '4.2 ');
    });

    test('referenceRange formats correctly with both bounds', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Haemoglobin',
        value: 14.5,
        unit: 'g/dL',
        normalMin: 12.0,
        normalMax: 17.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.referenceRange, '12.0 - 17.0 g/dL');
    });

    test('referenceRange with missing bounds shows question marks', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Custom Marker',
        value: 5.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.referenceRange, '? - ? ');
    });

    test('referenceRange with only min bound', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Custom Marker',
        value: 5.0,
        unit: 'mg/dL',
        normalMin: 3.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.referenceRange, '3.0 - ? mg/dL');
    });

    test('referenceRange with only max bound', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Custom Marker',
        value: 5.0,
        unit: 'mg/dL',
        normalMax: 10.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.referenceRange, '? - 10.0 mg/dL');
    });

    test('isNormal when no min/max provided', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Custom Marker',
        value: 5.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.isLow, false);
      expect(biomarker.isHigh, false);
      expect(biomarker.isNormal, true);
      expect(biomarker.statusLabel, 'Normal');
    });

    test('copyWith creates modified copy', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Haemoglobin',
        value: 10.0,
        unit: 'g/dL',
        normalMin: 12.0,
        normalMax: 17.0,
        recordedAt: recordedAt,
      );

      final updated = biomarker.copyWith(value: 14.0);

      expect(updated.value, 14.0);
      expect(updated.isNormal, true);
      expect(updated.name, 'Haemoglobin');
      expect(updated.id, 'bm-1');
    });

    test('defaults are applied', () {
      final biomarker = Biomarker(
        id: 'bm-1',
        reportId: 'r-1',
        patientId: 'p-1',
        name: 'Test',
        value: 1.0,
        recordedAt: recordedAt,
      );

      expect(biomarker.isAbnormal, false);
      expect(biomarker.unit, isNull);
      expect(biomarker.normalMin, isNull);
      expect(biomarker.normalMax, isNull);
    });

    test('fromJson handles minimal JSON (only required fields)', () {
      final minimalJson = {
        'id': 'bm-min',
        'report_id': 'r-min',
        'patient_id': 'p-min',
        'name': 'Glucose',
        'value': 90.0,
        'recorded_at': '2024-08-20T10:00:00.000',
      };

      final biomarker = Biomarker.fromJson(minimalJson);
      expect(biomarker.id, 'bm-min');
      expect(biomarker.unit, isNull);
      expect(biomarker.normalMin, isNull);
      expect(biomarker.normalMax, isNull);
      expect(biomarker.isAbnormal, false);
    });
  });
}
