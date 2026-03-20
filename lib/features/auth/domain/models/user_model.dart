// lib/features/auth/domain/models/user_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum UserRole { teacher, student }

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    @Default(UserRole.student) UserRole role,
    @Default([]) List<String> classroomIds,
    @Default([]) List<String> fcmTokens,
    required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  bool get isTeacher => role == UserRole.teacher;
  bool get isStudent => role == UserRole.student;

  String get roleLabel => isTeacher ? 'Enseignant' : 'Étudiant';
}
