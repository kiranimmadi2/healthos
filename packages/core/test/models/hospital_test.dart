import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hospital', () {
    final json = {
      'id': 'h1-12345678-abcd-ef01-2345-678901234567',
      'name': 'Apollo Hospitals',
      'address': {
        'street': '21 Greams Lane',
        'city': 'Chennai',
        'state': 'Tamil Nadu',
        'pincode': '600006',
      },
      'license': 'HOSP-TN-2024-001',
      'phone': '+914428293333',
      'email': 'info@apollohospitals.com',
      'logo_url': 'https://cdn.example.com/logos/apollo.png',
      'created_at': '2024-01-01T00:00:00.000',
      'updated_at': '2024-06-01T00:00:00.000',
    };

    test('fromJson parses all fields correctly', () {
      final hospital = Hospital.fromJson(json);

      expect(hospital.id, 'h1-12345678-abcd-ef01-2345-678901234567');
      expect(hospital.name, 'Apollo Hospitals');
      expect(hospital.address?['street'], '21 Greams Lane');
      expect(hospital.address?['city'], 'Chennai');
      expect(hospital.address?['state'], 'Tamil Nadu');
      expect(hospital.address?['pincode'], '600006');
      expect(hospital.license, 'HOSP-TN-2024-001');
      expect(hospital.phone, '+914428293333');
      expect(hospital.email, 'info@apollohospitals.com');
      expect(hospital.logoUrl, 'https://cdn.example.com/logos/apollo.png');
      expect(hospital.createdAt, DateTime.parse('2024-01-01T00:00:00.000'));
      expect(hospital.updatedAt, DateTime.parse('2024-06-01T00:00:00.000'));
    });

    test('fromJson and toJson round-trip', () {
      final hospital = Hospital.fromJson(json);
      final serialized = hospital.toJson();
      final roundTripped = Hospital.fromJson(serialized);
      expect(roundTripped, hospital);
    });

    test('copyWith creates modified copy', () {
      final hospital = Hospital(
        id: 'h-1',
        name: 'City Hospital',
      );

      final updated = hospital.copyWith(
        phone: '+911234567890',
        license: 'HOSP-KA-2024-099',
      );

      expect(updated.phone, '+911234567890');
      expect(updated.license, 'HOSP-KA-2024-099');
      expect(updated.id, 'h-1');
      expect(updated.name, 'City Hospital');
    });

    test('copyWith preserves all fields when none changed', () {
      final hospital = Hospital.fromJson(json);
      final copy = hospital.copyWith();
      expect(copy, hospital);
    });

    test('defaults are applied', () {
      final hospital = Hospital(
        id: 'h-1',
        name: 'Test Hospital',
      );

      expect(hospital.address, isNull);
      expect(hospital.license, isNull);
      expect(hospital.phone, isNull);
      expect(hospital.email, isNull);
      expect(hospital.logoUrl, isNull);
      expect(hospital.createdAt, isNull);
      expect(hospital.updatedAt, isNull);
    });

    test('fromJson handles minimal JSON (only required fields)', () {
      final minimalJson = {
        'id': 'h-min',
        'name': 'Minimal Hospital',
      };

      final hospital = Hospital.fromJson(minimalJson);
      expect(hospital.id, 'h-min');
      expect(hospital.name, 'Minimal Hospital');
      expect(hospital.address, isNull);
      expect(hospital.license, isNull);
      expect(hospital.phone, isNull);
      expect(hospital.email, isNull);
      expect(hospital.logoUrl, isNull);
    });

    test('fromJson handles null optional fields explicitly', () {
      final jsonWithNulls = {
        'id': 'h-null',
        'name': 'Null Hospital',
        'address': null,
        'license': null,
        'phone': null,
        'email': null,
        'logo_url': null,
        'created_at': null,
        'updated_at': null,
      };

      final hospital = Hospital.fromJson(jsonWithNulls);
      expect(hospital.address, isNull);
      expect(hospital.license, isNull);
      expect(hospital.phone, isNull);
      expect(hospital.email, isNull);
      expect(hospital.logoUrl, isNull);
      expect(hospital.createdAt, isNull);
      expect(hospital.updatedAt, isNull);
    });

    test('address map preserves nested structure', () {
      final hospital = Hospital.fromJson(json);
      expect(hospital.address, isA<Map<String, dynamic>>());
      expect(hospital.address!.keys,
          containsAll(['street', 'city', 'state', 'pincode']));
    });

    test('address with empty map', () {
      final jsonEmptyAddress = {
        'id': 'h-empty-addr',
        'name': 'Empty Address Hospital',
        'address': <String, dynamic>{},
      };

      final hospital = Hospital.fromJson(jsonEmptyAddress);
      expect(hospital.address, isNotNull);
      expect(hospital.address, isEmpty);
    });
  });
}
