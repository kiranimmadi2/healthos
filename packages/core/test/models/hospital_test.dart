import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Hospital', () {
    test('fromJson and toJson round-trip', () {
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

      final hospital = Hospital.fromJson(json);

      expect(hospital.id, 'h1-12345678-abcd-ef01-2345-678901234567');
      expect(hospital.name, 'Apollo Hospitals');
      expect(hospital.address?['city'], 'Chennai');
      expect(hospital.address?['pincode'], '600006');
      expect(hospital.license, 'HOSP-TN-2024-001');
      expect(hospital.phone, '+914428293333');
      expect(hospital.email, 'info@apollohospitals.com');
      expect(hospital.logoUrl, 'https://cdn.example.com/logos/apollo.png');

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
  });
}
