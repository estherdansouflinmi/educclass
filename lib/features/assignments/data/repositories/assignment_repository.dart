// lib/features/assignments/data/repositories/assignment_repository.dart
import 'dart:io';
import 'package:educclass/features/assignments/domain/models/assignment_model.dart';
import 'package:educclass/features/assignments/domain/models/submission_model.dart';

abstract class AssignmentRepository {
  Stream<List<AssignmentModel>> watchAssignments(String classroomId);
  Future<AssignmentModel> createAssignment({
    required String classroomId,
    required String title,
    required String description,
    required DateTime deadline,
    required bool allowLateSubmission,
    required String createdById,
    required String createdByName,
  });
  Future<AssignmentModel?> getAssignment({
    required String classroomId,
    required String assignmentId,
  });
  Future<void> deleteAssignment({
    required String classroomId,
    required String assignmentId,
  });
  Future<SubmissionModel> submitAssignment({
    required String classroomId,
    required String assignmentId,
    required String studentId,
    required String studentName,
    required String content,
    File? attachmentFile,
    required DateTime deadline,
    required void Function(double) onProgress,
  });
  Future<SubmissionModel?> getSubmission({
    required String classroomId,
    required String assignmentId,
    required String studentId,
  });
  Stream<List<SubmissionModel>> watchSubmissions({
    required String classroomId,
    required String assignmentId,
  });
  Future<void> addTeacherFeedback({
    required String classroomId,
    required String assignmentId,
    required String studentId,
    required String comment,
    String? grade,
  });
}
