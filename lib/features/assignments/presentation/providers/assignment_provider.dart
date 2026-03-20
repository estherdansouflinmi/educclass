// lib/features/assignments/presentation/providers/assignment_provider.dart
import 'package:educclass/core/providers/firebase_providers.dart';
import 'package:educclass/features/assignments/data/repositories/assignment_repository.dart';
import 'package:educclass/features/assignments/data/repositories/assignment_repository_impl.dart';
import 'package:educclass/features/assignments/domain/models/assignment_model.dart';
import 'package:educclass/features/assignments/domain/models/submission_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageProvider),
  );
});

final assignmentsProvider =
    StreamProvider.family<List<AssignmentModel>, String>((ref, classroomId) {
  return ref.watch(assignmentRepositoryProvider).watchAssignments(classroomId);
});

final assignmentProvider = FutureProvider.family<AssignmentModel?,
    ({String classroomId, String assignmentId})>((ref, p) {
  return ref.watch(assignmentRepositoryProvider).getAssignment(
        classroomId: p.classroomId,
        assignmentId: p.assignmentId,
      );
});

final submissionsProvider = StreamProvider.family<List<SubmissionModel>,
    ({String classroomId, String assignmentId})>((ref, p) {
  return ref.watch(assignmentRepositoryProvider).watchSubmissions(
        classroomId: p.classroomId,
        assignmentId: p.assignmentId,
      );
});

final mySubmissionProvider = FutureProvider.family<SubmissionModel?,
    ({String classroomId, String assignmentId, String studentId})>((ref, p) {
  return ref.watch(assignmentRepositoryProvider).getSubmission(
        classroomId: p.classroomId,
        assignmentId: p.assignmentId,
        studentId: p.studentId,
      );
});

class CreateAssignmentNotifier extends AsyncNotifier<AssignmentModel?> {
  @override
  Future<AssignmentModel?> build() async => null;

  Future<AssignmentModel?> create({
    required String classroomId,
    required String title,
    required String description,
    required DateTime deadline,
    required bool allowLateSubmission,
    required String createdById,
    required String createdByName,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(assignmentRepositoryProvider).createAssignment(
            classroomId: classroomId,
            title: title,
            description: description,
            deadline: deadline,
            allowLateSubmission: allowLateSubmission,
            createdById: createdById,
            createdByName: createdByName,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

final createAssignmentProvider =
    AsyncNotifierProvider<CreateAssignmentNotifier, AssignmentModel?>(
        CreateAssignmentNotifier.new);
