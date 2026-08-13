class DoctorProfile {
  DoctorProfile({
    required this.uid,
    required this.name,
    required this.specialization,
    required this.hospital,
    this.yearsOfExperience,
    this.isAvailable = true,
  });

  final String uid;
  final String name;
  final String specialization;
  final String hospital;
  final int? yearsOfExperience;
  final bool isAvailable;

  int get experienceYears => yearsOfExperience ?? 0;

  factory DoctorProfile.fromMap(String uid, Map<String, dynamic> data) {
    return DoctorProfile(
      uid: uid,
      name: data['name'] as String? ?? 'Doctor',
      specialization:
          data['specialization'] as String? ?? 'General Practitioner',
      hospital: data['hospital'] as String? ?? '',
      yearsOfExperience: (data['yearsOfExperience'] as num?)?.toInt() ?? (data['experienceYears'] as num?)?.toInt(),
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }
}
