// lib/features/assignments/data/repositories/assignment_repository_impl.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educclass/features/assignments/data/repositories/assignment_repository.dart';
import 'package:educclass/features/assignments/domain/models/assignment_model.dart';
import 'package:educclass/features/assignments/domain/models/submission_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class AssignmentRepositoryImpl implements AssignmentRepository {
  AssignmentRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _assignments(String cid) =>
      _firestore.collection('classrooms').doc(cid).collection('assignments');

  CollectionReference<Map<String, dynamic>> _submissions(
          String cid, String aid) =>
      _assignments(cid).doc(aid).collection('submissions');

  @override
  Stream<List<AssignmentModel>> watchAssignments(String classroomId) {
    return _assignments(classroomId)
        .orderBy('deadline', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                AssignmentModel.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  @override
  Future<AssignmentModel> createAssignment({
    required String classroomId,
    required String title,
    required String description,
    required DateTime deadline,
    required bool allowLateSubmission,
    required String createdById,
    required String createdByName,
  }) async {
    final id = _uuid.v4();
    final assignment = AssignmentModel(
      id: id,
      classroomId: classroomId,
      title: title,
      description: description,
      deadline: deadline,
      allowLateSubmission: allowLateSubmission,
      createdById: createdById,
      createdByName: createdByName,
      createdAt: DateTime.now(),
    );
    await _assignments(classroomId).doc(id).set(assignment.toJson());
    return assignment;
  }

  @override
  Future<AssignmentModel?> getAssignment({
    required String classroomId,
    required String assignmentId,
  }) async {
    final doc = await _assignments(classroomId).doc(assignmentId).get();
    if (!doc.exists || doc.data() == null) return null;
    return AssignmentModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<void> deleteAssignment({
    required String classroomId,
    required String assignmentId,
  }) async {
    await _assignments(classroomId).doc(assignmentId).delete();
  }

  @override
  Future<SubmissionModel> submitAssignment({
    required String classroomId,
    required String assignmentId,
    required String studentId,
    required String studentName,
    required String content,
    File? attachmentFile,
    required DateTime deadline,
    required void Function(double) onProgress,
  }) async {
    String? attachmentUrl;
    String? attachmentName;

    if (attachmentFile != null) {
      final fileName = attachmentFile.path.split('/').last;
      final path =
          'classrooms/$classroomId/submissions/$assignmentId/$studentId/$fileName';
      final ref = _storage.ref(path);
      final task = ref.putFile(attachmentFile);
      task.snapshotEvents.listen((s) {
        onProgress(s.bytesTransferred / s.totalBytes);
      });
      await task;
      attachmentUrl = await ref.getDownloadURL();
      attachmentName = fileName;
    }

    final isLate = DateTime.now().isAfter(deadline);
    final submission = SubmissionModel(
      studentId: studentId,
      studentName: studentName,
      assignmentId: assignmentId,
      classroomId: classroomId,
      content: content,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
      submittedAt: DateTime.now(),
      isLate: isLate,
    );

    final batch = _firestore.batch();
    batch.set(
      _submissions(classroomId, assignmentId).doc(studentId),
      submission.toJson(),
    );
    batch.update(_assignments(classroomId).doc(assignmentId), {
      'submissionCount': FieldValue.increment(1),
    });
    await batch.commit();
    return submission;
  }

  @override
  Future<SubmissionModel?> getSubmission({
    required String classroomId,
    required String assignmentId,
    required String studentId,
  }) async {
    final doc = await _submissions(classroomId, assignmentId)
        .doc(studentId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return SubmissionModel.fromJson(doc.data()!);
  }

  @override
  Stream<List<SubmissionModel>> watchSubmissions({
    required String classroomId,
    required String assignmentId,
  }) {
    return _submissions(classroomId, assignmentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SubmissionModel.fromJson(d.data()))
            .toList());
  }

  @override
  Future<void> addTeacherFeedback({
    required String classroomId,
    required String assignmentId,
    required String studentId,
    required String comment,
    String? grade,
  }) async {
    await _submissions(classroomId, assignmentId).doc(studentId).update({
      'teacherComment': comment,
      if (grade != null) 'grade': grade,
    });
  }
}
