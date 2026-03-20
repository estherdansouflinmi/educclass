// lib/features/comments/domain/models/comment_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

enum CommentContext { resource, assignment }

@freezed
class CommentModel with _$CommentModel {
  const factory CommentModel({
    required String id,
    required String classroomId,
    required String parentId,
    required CommentContext context,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
    required DateTime createdAt,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);
}
