import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthos/src/app/theme/app_theme.dart';
import 'package:healthos/src/app/theme/hos_colors.dart';
import 'package:healthos/src/features/auth/domain/user_profile.dart';

void main() {
  group('UserProfile.fromMap legacy aliases', () {
    test('reads conditions from every historical field name', () {
      for (final alias in [
        'medicalConditions',
        'medicalHistory',
        'conditions',
        'chronicConditions',
      ]) {
        final profile = UserProfile.fromMap('u1', {
          'name': 'Ada',
          'role': 'patient',
          alias: ['Asthma', 'Hypertension'],
        });
        expect(
          profile.medicalConditions,
          ['Asthma', 'Hypertension'],
          reason: 'alias "$alias" should populate medicalConditions',
        );
      }
    });

    test('reads medications from both field names', () {
      for (final alias in ['medications', 'currentMedications']) {
        final profile = UserProfile.fromMap('u1', {alias: ['Metformin']});
        expect(profile.medications, ['Metformin'], reason: alias);
      }
    });

    test('canonical name wins over legacy alias', () {
      final profile = UserProfile.fromMap('u1', {
        'medicalConditions': ['Canonical'],
        'medicalHistory': ['Legacy'],
      });
      expect(profile.medicalConditions, ['Canonical']);
    });

    test('accepts a comma-separated string for list fields', () {
      final profile = UserProfile.fromMap('u1', {
        'allergies': 'Peanuts, Penicillin ,  ',
      });
      expect(profile.allergies, ['Peanuts', 'Penicillin']);
    });

    test('reads hospital name from both field names', () {
      expect(
        UserProfile.fromMap('u1', {'hospital': 'St Mary'}).hospitalName,
        'St Mary',
      );
      expect(
        UserProfile.fromMap('u1', {'hospitalName': 'St Mary'}).hospitalName,
        'St Mary',
      );
    });

    test('reads experience from both field names', () {
      expect(UserProfile.fromMap('u1', {'experienceYears': 7}).yearsOfExperience, 7);
      expect(
        UserProfile.fromMap('u1', {'yearsOfExperience': 9}).yearsOfExperience,
        9,
      );
    });

    test('falls back to the document id when uid field is absent', () {
      expect(UserProfile.fromMap('doc-id', const {}).uid, 'doc-id');
    });

    test('tolerates a completely empty document', () {
      final profile = UserProfile.fromMap('u1', const {});
      expect(profile.name, '');
      expect(profile.role, '');
      expect(profile.allergies, isEmpty);
      expect(profile.bmi, isNull);
      expect(profile.age, isNull);
    });
  });

  group('UserProfile.toMap', () {
    test('writes canonical names and legacy aliases together', () {
      final map = UserProfile.fromMap('u1', {
        'name': 'Ada',
        'role': 'patient',
        'medicalHistory': ['Asthma'],
        'currentMedications': ['Inhaler'],
      }).toMap();

      expect(map['medicalConditions'], ['Asthma']);
      // Migration shim: unconverted readers still look these up.
      expect(map['medicalHistory'], ['Asthma']);
      expect(map['conditions'], ['Asthma']);
      expect(map['chronicConditions'], ['Asthma']);
      expect(map['medications'], ['Inhaler']);
      expect(map['currentMedications'], ['Inhaler']);
    });

    test('omits absent optional fields rather than writing nulls', () {
      final map = UserProfile.fromMap('u1', {'name': 'Ada'}).toMap();
      expect(map.containsKey('dob'), isFalse);
      expect(map.containsKey('specialization'), isFalse);
      expect(map.containsKey('email'), isFalse);
    });

    test('round-trips through fromMap', () {
      final original = UserProfile.fromMap('u1', {
        'name': 'Ada Lovelace',
        'role': 'doctor',
        'specialization': 'Cardiology',
        'height': 170,
        'weight': 65,
        'allergies': ['Latex'],
        'isAvailable': false,
      });
      final restored = UserProfile.fromMap('u1', original.toMap());

      expect(restored.name, 'Ada Lovelace');
      expect(restored.role, 'doctor');
      expect(restored.specialization, 'Cardiology');
      expect(restored.heightCm, 170);
      expect(restored.weightKg, 65);
      expect(restored.allergies, ['Latex']);
      expect(restored.isAvailable, isFalse);
    });
  });

  group('derived values', () {
    test('bmi is computed from height and weight', () {
      final profile = UserProfile.fromMap('u1', {
        'height': 180,
        'weight': 81,
      });
      expect(profile.bmi, closeTo(25.0, 0.01));
    });

    test('bmi is null for implausible input', () {
      expect(UserProfile.fromMap('u1', {'height': 0, 'weight': 70}).bmi, isNull);
      expect(UserProfile.fromMap('u1', {'height': 180}).bmi, isNull);
    });

    test('age accounts for whether the birthday has passed', () {
      final now = DateTime.now();
      final notYet = DateTime(now.year - 30, now.month, now.day)
          .add(const Duration(days: 2));
      expect(
        UserProfile.fromMap('u1', {'dob': notYet.toIso8601String()}).age,
        29,
      );

      final passed = DateTime(now.year - 30, now.month, now.day)
          .subtract(const Duration(days: 2));
      expect(
        UserProfile.fromMap('u1', {'dob': passed.toIso8601String()}).age,
        30,
      );
    });

    test('initials use first and last word', () {
      expect(UserProfile.initialsOf('Ada Lovelace'), 'AL');
      expect(UserProfile.initialsOf('Mary Jane Watson'), 'MW');
    });

    test('initials strip a leading title', () {
      expect(UserProfile.initialsOf('Dr. Asha Sharma'), 'AS');
      expect(UserProfile.initialsOf('dr Asha Sharma'), 'AS');
      expect(UserProfile.initialsOf('Prof. Alan Turing'), 'AT');
    });

    test('initials take two letters from a single-word name', () {
      expect(UserProfile.initialsOf('Prince'), 'PR');
      expect(UserProfile.initialsOf('X'), 'X');
    });

    test('initials survive irregular whitespace', () {
      // The previous implementation indexed [0] on split segments and threw a
      // RangeError here.
      expect(UserProfile.initialsOf('Ada  Lovelace'), 'AL');
      expect(UserProfile.initialsOf('  Ada Lovelace  '), 'AL');
    });

    test('initials fall back when there is no usable name', () {
      expect(UserProfile.initialsOf(null, fallback: 'DR'), 'DR');
      expect(UserProfile.initialsOf('   ', fallback: 'PT'), 'PT');
      expect(UserProfile.initialsOf('Dr.', fallback: 'DR'), 'DR');
    });

    test('bmiCategory uses the WHO cut-offs', () {
      BmiCategory? categoryFor(double height, double weight) =>
          UserProfile.fromMap('u1', {
            'height': height,
            'weight': weight,
          }).bmiCategory;

      expect(categoryFor(180, 55), BmiCategory.underweight); // 16.98
      expect(categoryFor(180, 70), BmiCategory.normal); // 21.6
      expect(categoryFor(180, 90), BmiCategory.overweight); // 27.8
      expect(categoryFor(180, 110), BmiCategory.obese); // 33.9
      expect(UserProfile.fromMap('u1', const {}).bmiCategory, isNull);
    });

    test('firstName falls back when the name is blank', () {
      expect(UserProfile.fromMap('u1', {'name': 'Ada Lovelace'}).firstName, 'Ada');
      expect(UserProfile.fromMap('u1', {'name': '  '}).firstName, 'there');
    });

    test('verification defaults to unverified, never verified', () {
      expect(
        UserProfile.fromMap('u1', const {}).verificationStatus,
        VerificationStatus.unverified,
      );
      expect(UserProfile.fromMap('u1', const {}).isVerified, isFalse);
    });
  });

  group('HosColors', () {
    test('light and dark resolve to different text colours', () {
      expect(HosColors.light.textPrimary, isNot(HosColors.dark.textPrimary));
      expect(HosColors.light.background, isNot(HosColors.dark.background));
      expect(HosColors.light.glassFill, isNot(HosColors.dark.glassFill));
    });

    // Registration on both themes is asserted by the `context.hos resolves per
    // active theme` widget test below, which exercises the real MaterialApp
    // path. Touching AppTheme from a plain `test()` triggers google_fonts'
    // async Inter load outside a widget binding, which throws into the zone.

    test('lerp interpolates between variants', () {
      final mid = HosColors.light.lerp(HosColors.dark, 0.5);
      expect(mid.textPrimary, isNot(HosColors.light.textPrimary));
      expect(mid.textPrimary, isNot(HosColors.dark.textPrimary));
    });

    testWidgets('context.hos resolves per active theme', (tester) async {
      late HosColors seen;

      Future<void> pumpWith(ThemeData theme) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                seen = context.hos;
                return const SizedBox();
              },
            ),
          ),
        );
      }

      await pumpWith(AppTheme.lightTheme);
      expect(seen.textPrimary, HosColors.light.textPrimary);

      // MaterialApp animates theme changes, and HosColors participates in that
      // lerp, so the swap is a cross-fade rather than a snap -- settle first.
      await pumpWith(AppTheme.darkTheme);
      await tester.pumpAndSettle();
      expect(seen.textPrimary, HosColors.dark.textPrimary);
    });

    testWidgets('cross-fades rather than snapping between themes', (
      tester,
    ) async {
      final samples = <Color>[];

      Future<void> pumpWith(ThemeData theme) => tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              samples.add(context.hos.textPrimary);
              return const SizedBox();
            },
          ),
        ),
      );

      await pumpWith(AppTheme.lightTheme);
      await pumpWith(AppTheme.darkTheme);
      await tester.pump(const Duration(milliseconds: 100));

      // A mid-flight value distinct from both endpoints proves the lerp ran.
      expect(
        samples.any(
          (c) =>
              c != HosColors.light.textPrimary &&
              c != HosColors.dark.textPrimary,
        ),
        isTrue,
        reason: 'expected an interpolated colour during the theme transition',
      );
    });

    testWidgets('falls back to light when no extension is registered', (
      tester,
    ) async {
      late HosColors seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Builder(
            builder: (context) {
              seen = context.hos;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(seen.textPrimary, HosColors.light.textPrimary);
    });
  });
}
