class DoctorProfile {
  DoctorProfile({
    required this.uid,
    required this.name,
    required this.specialization,
    required this.hospital,
    this.yearsOfExperience,
  });

  final String uid;
  final String name;
  final String specialization;
  final String hospital;
  final int? yearsOfExperience;

  factory DoctorProfile.fromMap(String uid, Map<String, dynamic> data) {
    return DoctorProfile(
      uid: uid,
      name: data['name'] as String? ?? 'Doctor',
      specialization:
          data['specialization'] as String? ?? 'General Practitioner',
      hospital: data['hospital'] as String? ?? '',
      yearsOfExperience: (data['yearsOfExperience'] as num?)?.toInt(),
    );
  }
}
