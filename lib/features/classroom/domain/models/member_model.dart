// lib/features/classroom/domain/models/member_model.dart
import 'package:educclass/features/auth/domain/models/user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_model.freezed.dart';
part 'member_model.g.dart';

@freezed
class MemberModel with _$MemberModel {
  const factory MemberModel({
    required String uid,
    required String displayName,
    String? photoUrl,
    required String email,
    required UserRole role,
    required DateTime joinedAt,
  }) = _MemberModel;

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);
}
