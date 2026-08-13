import '../../records/domain/medical_record.dart';

/// Whether a diagnostic report still needs a clinician's attention.
enum ReportStatus {
  needsReview('Needs review'),
  reviewed('Reviewed');

  const ReportStatus(this.label);

  final String label;
}

/// How urgently a report should be looked at.
enum ReportPriority {
  normal('Normal'),
  high('High');

  const ReportPriority(this.label);

  final String label;

  bool get isHigh => this == ReportPriority.high;
}

/// A patient as the doctor workspace lists them.
///
/// Composed in the application layer from the patient's profile and the
/// doctor's appointments. Deliberately free of Flutter types so the layer that
/// builds it does not have to reach for presentation values — the avatar tint
/// is derived from [name] at render time.
class DoctorPatient {
  const DoctorPatient({
    required this.id,
    required this.name,
    required this.initials,
    required this.age,
    required this.gender,
    required this.condition,
    required this.carePlan,
    required this.lastVisit,
    this.needsFollowUp = false,
  });

  final String id;
  final String name;
  final String initials;
  final int age;
  final String gender;
  final String condition;
  final String carePlan;

  /// Pre-formatted date of the most recent appointment, or a placeholder.
  final String lastVisit;

  final bool needsFollowUp;
}

/// A lab report or scan surfaced to the reviewing doctor.
///
/// Carries [category] rather than an icon and colour; the widget that renders
/// it chooses those. Previously the provider built IconData and Color values,
/// which put presentation decisions in the application layer and made the
/// provider impossible to test without a widget binding.
class DiagnosticReport {
  const DiagnosticReport({
    required this.id,
    required this.type,
    required this.patient,
    required this.ordered,
    required this.summary,
    required this.category,
    this.status = ReportStatus.needsReview,
    this.priority = ReportPriority.normal,
  });

  final String id;

  /// Title of the underlying record, e.g. "Full blood count".
  final String type;

  final String patient;

  /// Pre-formatted order date.
  final String ordered;

  final String summary;

  /// One of [RecordCategory]; drives the icon and tint at render time.
  final String category;

  final ReportStatus status;
  final ReportPriority priority;
}
