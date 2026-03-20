// lib/features/assignments/domain/models/submission_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'submission_model.freezed.dart';
part 'submission_model.g.dart';

@freezed
class SubmissionModel with _$SubmissionModel {
  const factory SubmissionModel({
    required String studentId,
    required String studentName,
    required String assignmentId,
    required String classroomId,
    @Default('') String content,
    String? attachmentUrl,
    String? attachmentName,
    required DateTime submittedAt,
    @Default(false) bool isLate,
    String? teacherComment,
    String? grade,
  }) = _SubmissionModel;

  factory SubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$SubmissionModelFromJson(json);
}
