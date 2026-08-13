import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles recognised by [UserProfile.role] and the router.
abstract final class UserRole {
  static const patient = 'patient';
  static const doctor = 'doctor';
  static const hospital = 'hospital';

  static const all = [patient, doctor, hospital];
}

/// WHO body-mass-index bands.
enum BmiCategory { underweight, normal, overweight, obese }

/// Whether a doctor has been vetted by a hospital.
///
/// The patient-facing UI advertises "verified doctors", but nothing backed that
/// claim: `role` is client-written, so any account could self-declare as a
/// doctor. Verification is granted by a hospital admin, never by the doctor.
abstract final class VerificationStatus {
  static const unverified = 'unverified';
  static const pending = 'pending';
  static const verified = 'verified';
  static const rejected = 'rejected';
}

/// Typed view over the `users/{uid}` document.
///
/// The document was previously passed around as a raw `Map<String, dynamic>`,
/// and callers disagreed about field names — conditions alone were written to
/// `medicalHistory`, `conditions` *and* `chronicConditions`, while different
/// readers checked different subsets. This type is the single place that knows
/// about those aliases.
///
/// Reading tolerates every legacy alias. Writing emits the canonical name and,
/// for one migration window, the legacy aliases too, so that any screen not yet
/// converted keeps working. See [toMap].
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.photoUrl,
    this.dob,
    this.gender,
    this.bloodGroup,
    this.heightCm,
    this.weightKg,
    this.allergies = const [],
    this.medicalConditions = const [],
    this.medications = const [],
    this.dietGoal,
    this.bio,
    this.specialization,
    this.licenseNumber,
    this.hospitalId,
    this.hospitalName,
    this.yearsOfExperience,
    this.isAvailable = true,
    this.verificationStatus = VerificationStatus.unverified,
    this.authProviders = const [],
    this.createdAt,
  });

  final String uid;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final String? photoUrl;

  // Patient
  final DateTime? dob;
  final String? gender;
  final String? bloodGroup;
  final double? heightCm;
  final double? weightKg;
  final List<String> allergies;
  final List<String> medicalConditions;
  final List<String> medications;
  final String? dietGoal;

  /// Free-text "about me", shown on the profile sheet.
  final String? bio;

  // Doctor
  final String? specialization;
  final String? licenseNumber;
  final String? hospitalId;
  final String? hospitalName;
  final int? yearsOfExperience;
  final bool isAvailable;
  final String verificationStatus;

  // Shared
  final List<String> authProviders;
  final DateTime? createdAt;

  bool get isPatient => role == UserRole.patient;
  bool get isDoctor => role == UserRole.doctor;
  bool get isHospital => role == UserRole.hospital;
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  /// Whole years since [dob], or null if unknown.
  int? get age {
    final birth = dob;
    if (birth == null) return null;
    final now = DateTime.now();
    var years = now.year - birth.year;
    final hadBirthday =
        now.month > birth.month ||
        (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) years--;
    return years < 0 || years > 130 ? null : years;
  }

  /// Body mass index, or null when height/weight are missing or implausible.
  double? get bmi {
    final h = heightCm;
    final w = weightKg;
    if (h == null || w == null || h <= 0 || w <= 0) return null;
    final metres = h / 100;
    final value = w / (metres * metres);
    return value.isFinite && value > 0 && value < 200 ? value : null;
  }

  /// WHO band for [bmi], or null when BMI is unknown.
  ///
  /// The thresholds were previously repeated in the health summary card and
  /// the AI prompt builder. Call sites still choose their own wording — the
  /// patient dashboard says "Healthy" where the clinical prompt says "Normal
  /// weight" — but the cut-offs live here.
  BmiCategory? get bmiCategory {
    final value = bmi;
    if (value == null) return null;
    if (value < 18.5) return BmiCategory.underweight;
    if (value < 25) return BmiCategory.normal;
    if (value < 30) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  /// Up to two letters for an avatar, e.g. "Ada Lovelace" -> "AL".
  String get initials => initialsOf(name);

  /// Avatar initials for an arbitrary display name.
  ///
  /// Consolidates three implementations that disagreed on fallback text and on
  /// how to handle titles. One of them indexed `[0]` on split segments, which
  /// threw a RangeError for any name containing a double space.
  static String initialsOf(String? name, {String fallback = '?'}) {
    if (name == null) return fallback;

    final words = name
        .replaceAll(
          RegExp(r'^\s*(dr|mr|mrs|ms|prof)\.?\s+', caseSensitive: false),
          '',
        )
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return fallback;
    if (words.length == 1) {
      final word = words.first;
      return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
    }
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  /// First name, for greetings. Falls back to the whole name.
  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'there';
    final space = trimmed.indexOf(' ');
    return space == -1 ? trimmed : trimmed.substring(0, space);
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: (data['uid'] as String?)?.trim().isNotEmpty == true
          ? data['uid'] as String
          : uid,
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? '',
      email: _string(data['email']),
      phone: _string(data['phone']) ?? _string(data['phoneNumber']),
      photoUrl: _string(data['photoUrl']),
      dob: _date(data['dob']),
      gender: _string(data['gender']),
      bloodGroup: _string(data['bloodGroup']) ?? _string(data['blood_group']),
      heightCm: _double(data['height']),
      weightKg: _double(data['weight']),
      allergies: _stringList(data['allergies']),
      medicalConditions: _stringList(
        data['medicalConditions'] ??
            data['medicalHistory'] ??
            data['conditions'] ??
            data['chronicConditions'],
      ),
      medications: _stringList(
        data['medications'] ?? data['currentMedications'],
      ),
      dietGoal: _string(data['dietGoal']),
      bio: _string(data['bio']),
      specialization: _string(data['specialization']),
      licenseNumber: _string(data['licenseNumber']),
      hospitalId: _string(data['hospitalId']),
      hospitalName: _string(data['hospitalName']) ?? _string(data['hospital']),
      yearsOfExperience:
          _int(data['yearsOfExperience']) ?? _int(data['experienceYears']),
      isAvailable: data['isAvailable'] as bool? ?? true,
      verificationStatus:
          _string(data['verificationStatus']) ?? VerificationStatus.unverified,
      authProviders: _stringList(data['authProviders']),
      createdAt: _date(data['createdAt']),
    );
  }

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      UserProfile.fromMap(doc.id, doc.data() ?? const {});

  /// Firestore payload.
  ///
  /// Emits canonical names plus the legacy aliases still read by screens that
  /// have not been converted yet (`user_profile_dialog`, `ai_service`). Drop the
  /// aliases once nothing reads them — see the alias list in [fromMap].
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'role': role,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (dob != null) 'dob': dob!.toIso8601String(),
      if (gender != null) 'gender': gender,
      if (bloodGroup != null) 'bloodGroup': bloodGroup,
      if (heightCm != null) 'height': heightCm,
      if (weightKg != null) 'weight': weightKg,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'medications': medications,
      // Legacy aliases — migration shim, safe to delete once readers are typed.
      'medicalHistory': medicalConditions,
      'conditions': medicalConditions,
      'chronicConditions': medicalConditions,
      'currentMedications': medications,
      if (dietGoal != null) 'dietGoal': dietGoal,
      if (bio != null) 'bio': bio,
      if (specialization != null) 'specialization': specialization,
      if (licenseNumber != null) 'licenseNumber': licenseNumber,
      if (hospitalId != null) 'hospitalId': hospitalId,
      if (hospitalName != null) ...{
        'hospitalName': hospitalName,
        'hospital': hospitalName,
      },
      if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
      'isAvailable': isAvailable,
      'verificationStatus': verificationStatus,
    };
  }

  UserProfile copyWith({
    String? name,
    String? role,
    String? email,
    String? phone,
    String? photoUrl,
    DateTime? dob,
    String? gender,
    String? bloodGroup,
    double? heightCm,
    double? weightKg,
    List<String>? allergies,
    List<String>? medicalConditions,
    List<String>? medications,
    String? dietGoal,
    String? bio,
    String? specialization,
    String? licenseNumber,
    String? hospitalId,
    String? hospitalName,
    int? yearsOfExperience,
    bool? isAvailable,
    String? verificationStatus,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      dietGoal: dietGoal ?? this.dietGoal,
      bio: bio ?? this.bio,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isAvailable: isAvailable ?? this.isAvailable,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      authProviders: authProviders,
      createdAt: createdAt,
    );
  }

  // ---- parsing helpers ------------------------------------------------------

  static String? _string(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double? _double(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static int? _int(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static DateTime? _date(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Accepts a list, or a comma-separated string (older docs stored free text).
  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
