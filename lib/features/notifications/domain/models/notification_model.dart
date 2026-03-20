// lib/features/notifications/domain/models/notification_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationKind { newAssignment, newResource, submissionReceived, comment, deadlineReminder }

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String userId,
    required NotificationKind kind,
    required String title,
    required String body,
    String? classroomId,
    String? targetId,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
