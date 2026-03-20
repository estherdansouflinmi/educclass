// lib/features/comments/presentation/providers/comment_provider.dart
import 'package:educclass/core/providers/firebase_providers.dart';
import 'package:educclass/features/comments/data/repositories/comment_repository.dart';
import 'package:educclass/features/comments/data/repositories/comment_repository_impl.dart';
import 'package:educclass/features/comments/domain/models/comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepositoryImpl(firestore: ref.watch(firestoreProvider));
});

typedef CommentParams = ({
  String classroomId,
  String parentId,
  CommentContext context
});

final commentsProvider =
    StreamProvider.family<List<CommentModel>, CommentParams>((ref, p) {
  return ref.watch(commentRepositoryProvider).watchComments(
        classroomId: p.classroomId,
        parentId: p.parentId,
        context: p.context,
      );
});

class AddCommentNotifier extends AsyncNotifier<CommentModel?> {
  @override
  Future<CommentModel?> build() async => null;

  Future<void> addComment({
    required String classroomId,
    required String parentId,
    required CommentContext context,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(commentRepositoryProvider).addComment(
            classroomId: classroomId,
            parentId: parentId,
            context: context,
            authorId: authorId,
            authorName: authorName,
            authorPhotoUrl: authorPhotoUrl,
            content: content,
          ),
    );
  }
}

final addCommentProvider =
    AsyncNotifierProvider<AddCommentNotifier, CommentModel?>(
        AddCommentNotifier.new);
