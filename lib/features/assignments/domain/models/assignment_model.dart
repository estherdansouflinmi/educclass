// lib/features/assignments/domain/models/assignment_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment_model.freezed.dart';
part 'assignment_model.g.dart';

@freezed
class AssignmentModel with _$AssignmentModel {
  const factory AssignmentModel({
    required String id,
    required String classroomId,
    required String title,
    @Default('') String description,
    required DateTime deadline,
    @Default(true) bool allowLateSubmission,
    @Default([]) List<String> attachmentUrls,
    @Default([]) List<String> attachmentNames,
    @Default(0) int submissionCount,
    @Default(0) int totalStudents,
    @Default(0) int commentCount,
    required String createdById,
    required String createdByName,
    required DateTime createdAt,
  }) = _AssignmentModel;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssignmentModelFromJson(json);
}
