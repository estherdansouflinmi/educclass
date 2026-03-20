// lib/features/classroom/data/repositories/classroom_repository.dart
import 'package:educclass/features/classroom/domain/models/classroom_model.dart';
import 'package:educclass/features/classroom/domain/models/member_model.dart';

abstract class ClassroomRepository {
  Stream<List<ClassroomModel>> watchUserClassrooms(String userId);
  Future<ClassroomModel> createClassroom({
    required String name,
    required String description,
    required String teacherId,
    required String teacherName,
    required String coverColor,
  });
  Future<ClassroomModel> joinClassroom({
    required String code,
    required String studentId,
    required String studentName,
    required String studentEmail,
  });
  Future<ClassroomModel?> getClassroom(String classroomId);
  Future<List<MemberModel>> getMembers(String classroomId);
  Future<void> deleteClassroom(String classroomId);
  Future<void> leaveClassroom({
    required String classroomId,
    required String userId,
  });
}
