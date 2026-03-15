enum UserRole {
  patient,
  doctor,
  hospitalAdmin,
  labTechnician;

  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.hospitalAdmin:
        return 'Hospital Admin';
      case UserRole.labTechnician:
        return 'Lab Technician';
    }
  }
}
