// lib/features/classroom/domain/models/classroom_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'classroom_model.freezed.dart';
part 'classroom_model.g.dart';

@freezed
class ClassroomModel with _$ClassroomModel {
  const factory ClassroomModel({
    required String id,
    required String name,
    @Default('') String description,
    required String teacherId,
    required String teacherName,
    required String code,
    @Default('#1A73E8') String coverColor,
    @Default(0) int studentCount,
    @Default(false) bool isArchived,
    required DateTime createdAt,
  }) = _ClassroomModel;

  factory ClassroomModel.fromJson(Map<String, dynamic> json) =>
      _$ClassroomModelFromJson(json);
}
