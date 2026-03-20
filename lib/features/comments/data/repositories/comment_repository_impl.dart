// lib/features/comments/data/repositories/comment_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educclass/features/comments/data/repositories/comment_repository.dart';
import 'package:educclass/features/comments/domain/models/comment_model.dart';
import 'package:uuid/uuid.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _comments({
    required String classroomId,
    required String parentId,
    required CommentContext context,
  }) {
    final parentCollection =
        context == CommentContext.resource ? 'resources' : 'assignments';
    return _firestore
        .collection('classrooms')
        .doc(classroomId)
        .collection(parentCollection)
        .doc(parentId)
        .collection('comments');
  }

  @override
  Stream<List<CommentModel>> watchComments({
    required String classroomId,
    required String parentId,
    required CommentContext context,
  }) {
    return _comments(
            classroomId: classroomId, parentId: parentId, context: context)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CommentModel.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  @override
  Future<CommentModel> addComment({
    required String classroomId,
    required String parentId,
    required CommentContext context,
    required String authorId,
    required String authorName,
    String? authorPhotoUrl,
    required String content,
  }) async {
    final id = _uuid.v4();
    final comment = CommentModel(
      id: id,
      classroomId: classroomId,
      parentId: parentId,
      context: context,
      authorId: authorId,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      content: content,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    final ref = _comments(
        classroomId: classroomId, parentId: parentId, context: context);
    batch.set(ref.doc(id), comment.toJson());

    final parentColl =
        context == CommentContext.resource ? 'resources' : 'assignments';
    batch.update(
      _firestore
          .collection('classrooms')
          .doc(classroomId)
          .collection(parentColl)
          .doc(parentId),
      {'commentCount': FieldValue.increment(1)},
    );
    await batch.commit();
    return comment;
  }

  @override
  Future<void> deleteComment({
    required String classroomId,
    required String parentId,
    required CommentContext context,
    required String commentId,
  }) async {
    final batch = _firestore.batch();
    final ref = _comments(
        classroomId: classroomId, parentId: parentId, context: context);
    batch.delete(ref.doc(commentId));

    final parentColl =
        context == CommentContext.resource ? 'resources' : 'assignments';
    batch.update(
      _firestore
          .collection('classrooms')
          .doc(classroomId)
          .collection(parentColl)
          .doc(parentId),
      {'commentCount': FieldValue.increment(-1)},
    );
    await batch.commit();
  }
}
