import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core package exports all models', () {
    final patient = Patient(
      id: '1',
      healthId: 'HOS-2024-AB12',
      phone: '+91123',
    );
    expect(patient.healthId, 'HOS-2024-AB12');
  });

  test('core package exports enums', () {
    expect(UserRole.patient.displayName, 'Patient');
    expect(TriageLevel.emergency.isUrgent, true);
  });
}
