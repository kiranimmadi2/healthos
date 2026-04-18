import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    @JsonKey(name: 'patient_id') String? patientId,
    @JsonKey(name: 'doctor_id') String? doctorId,
    required String title,
    required String body,
    @Default('info') String type,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'action_route') String? actionRoute,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
