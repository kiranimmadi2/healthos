import 'package:freezed_annotation/freezed_annotation.dart';

part 'biomarker.freezed.dart';
part 'biomarker.g.dart';

@freezed
class Biomarker with _$Biomarker {
  const Biomarker._();

  const factory Biomarker({
    required String id,
    @JsonKey(name: 'report_id') required String reportId,
    @JsonKey(name: 'patient_id') required String patientId,
    required String name,
    required double value,
    String? unit,
    @JsonKey(name: 'normal_min') double? normalMin,
    @JsonKey(name: 'normal_max') double? normalMax,
    @JsonKey(name: 'is_abnormal') @Default(false) bool isAbnormal,
    @JsonKey(name: 'recorded_at') required DateTime recordedAt,
  }) = _Biomarker;

  factory Biomarker.fromJson(Map<String, dynamic> json) =>
      _$BiomarkerFromJson(json);

  bool get isLow => normalMin != null && value < normalMin!;
  bool get isHigh => normalMax != null && value > normalMax!;
  bool get isNormal => !isLow && !isHigh;

  String get statusLabel {
    if (isLow) return 'Low';
    if (isHigh) return 'High';
    return 'Normal';
  }

  String get displayValue => '${value.toStringAsFixed(1)} ${unit ?? ''}';
  String get referenceRange =>
      '${normalMin?.toStringAsFixed(1) ?? '?'} - ${normalMax?.toStringAsFixed(1) ?? '?'} ${unit ?? ''}';
}
