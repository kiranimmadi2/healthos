enum TriageLevel {
  homeCare,
  seeDoctor,
  emergency;

  String get displayName {
    switch (this) {
      case TriageLevel.homeCare:
        return 'Home Care';
      case TriageLevel.seeDoctor:
        return 'See a Doctor';
      case TriageLevel.emergency:
        return 'Emergency';
    }
  }

  String get jsonValue {
    switch (this) {
      case TriageLevel.homeCare:
        return 'home_care';
      case TriageLevel.seeDoctor:
        return 'see_doctor';
      case TriageLevel.emergency:
        return 'emergency';
    }
  }

  static TriageLevel fromJson(String value) {
    switch (value) {
      case 'home_care':
        return TriageLevel.homeCare;
      case 'see_doctor':
        return TriageLevel.seeDoctor;
      case 'emergency':
        return TriageLevel.emergency;
      default:
        return TriageLevel.seeDoctor;
    }
  }

  bool get isUrgent => this == TriageLevel.emergency;
}
