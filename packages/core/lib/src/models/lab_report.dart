import 'package:freezed_annotation/freezed_annotation.dart';

part 'lab_report.freezed.dart';
part 'lab_report.g.dart';

@freezed
class LabReport with _$LabReport {
  const factory LabReport({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'visit_id') String? visitId,
    @JsonKey(name: 'report_type') required String reportType,
    @JsonKey(name: 'report_date') required DateTime reportDate,
    @JsonKey(name: 'file_url') String? fileUrl,
    @JsonKey(name: 'parsed_data') Map<String, dynamic>? parsedData,
    @JsonKey(name: 'ai_summary') String? aiSummary,
    @Default('pending') String status,
    @JsonKey(name: 'lab_name') String? labName,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _LabReport;

  factory LabReport.fromJson(Map<String, dynamic> json) =>
      _$LabReportFromJson(json);
}
