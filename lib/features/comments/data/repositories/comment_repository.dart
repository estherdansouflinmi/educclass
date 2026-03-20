// lib/features/comments/data/repositories/comment_repository.dart
import 'package:educclass/features/comments/domain/models/comment_model.dart';

abstract class CommentRepository {
  Stream<List<CommentModel>> watchComments({
    required String classroomId,
    required String parentId,
    required CommentContext context,
  });

  Future<CommentModel> addComment({
    required String classroomId,
    required String parentId,
    required CommentContext context,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  });

  Future<void> deleteComment({
    required String classroomId,
    required String parentId,
    required CommentContext context,
    required String commentId,
  });
}
