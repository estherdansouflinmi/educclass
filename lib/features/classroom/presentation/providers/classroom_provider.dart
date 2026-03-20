// lib/features/classroom/presentation/providers/classroom_provider.dart
import 'package:educclass/core/providers/firebase_providers.dart';
import 'package:educclass/features/classroom/data/repositories/classroom_repository.dart';
import 'package:educclass/features/classroom/data/repositories/classroom_repository_impl.dart';
import 'package:educclass/features/classroom/domain/models/classroom_model.dart';
import 'package:educclass/features/classroom/domain/models/member_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final classroomRepositoryProvider = Provider<ClassroomRepository>((ref) {
  return ClassroomRepositoryImpl(firestore: ref.watch(firestoreProvider));
});

final userClassroomsProvider =
    StreamProvider.family<List<ClassroomModel>, String>((ref, userId) {
  return ref.watch(classroomRepositoryProvider).watchUserClassrooms(userId);
});

final classroomProvider =
    FutureProvider.family<ClassroomModel?, String>((ref, classroomId) {
  return ref.watch(classroomRepositoryProvider).getClassroom(classroomId);
});

final classMembersProvider =
    FutureProvider.family<List<MemberModel>, String>((ref, classroomId) {
  return ref.watch(classroomRepositoryProvider).getMembers(classroomId);
});

class CreateClassroomNotifier extends AsyncNotifier<ClassroomModel?> {
  @override
  Future<ClassroomModel?> build() async => null;

  Future<ClassroomModel?> create({
    required String name,
    required String description,
    required String teacherId,
    required String teacherName,
    required String coverColor,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(classroomRepositoryProvider).createClassroom(
            name: name,
            description: description,
            teacherId: teacherId,
            teacherName: teacherName,
            coverColor: coverColor,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

final createClassroomProvider =
    AsyncNotifierProvider<CreateClassroomNotifier, ClassroomModel?>(
        CreateClassroomNotifier.new);

class JoinClassroomNotifier extends AsyncNotifier<ClassroomModel?> {
  @override
  Future<ClassroomModel?> build() async => null;

  Future<ClassroomModel?> join({
    required String code,
    required String studentId,
    required String studentName,
    required String studentEmail,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(classroomRepositoryProvider).joinClassroom(
            code: code,
            studentId: studentId,
            studentName: studentName,
            studentEmail: studentEmail,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

final joinClassroomProvider =
    AsyncNotifierProvider<JoinClassroomNotifier, ClassroomModel?>(
        JoinClassroomNotifier.new);
