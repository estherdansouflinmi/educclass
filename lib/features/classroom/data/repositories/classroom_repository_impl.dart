// lib/features/classroom/data/repositories/classroom_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educclass/features/auth/domain/models/user_model.dart';
import 'package:educclass/features/classroom/data/repositories/classroom_repository.dart';
import 'package:educclass/features/classroom/domain/models/classroom_model.dart';
import 'package:educclass/features/classroom/domain/models/member_model.dart';
import 'package:uuid/uuid.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  ClassroomRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _classrooms =>
      _firestore.collection('classrooms');

  @override
  Stream<List<ClassroomModel>> watchUserClassrooms(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists) return [];
      final ids = List<String>.from(userDoc.data()?['classroomIds'] ?? []);
      if (ids.isEmpty) return [];
      final chunks = <List<String>>[];
      for (var i = 0; i < ids.length; i += 10) {
        chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
      }
      final classrooms = <ClassroomModel>[];
      for (final chunk in chunks) {
        final query = await _classrooms
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        classrooms.addAll(
          query.docs
              .map((d) => ClassroomModel.fromJson({...d.data(), 'id': d.id})),
        );
      }
      return classrooms;
    });
  }

  @override
  Future<ClassroomModel> createClassroom({
    required String name,
    required String description,
    required String teacherId,
    required String teacherName,
    required String coverColor,
  }) async {
    final id = _uuid.v4();
    final code = _generateCode();
    final classroom = ClassroomModel(
      id: id,
      name: name,
      description: description,
      teacherId: teacherId,
      teacherName: teacherName,
      code: code,
      coverColor: coverColor,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(_classrooms.doc(id), classroom.toJson());
    batch.set(
      _classrooms.doc(id).collection('members').doc(teacherId),
      {
        'uid': teacherId,
        'displayName': teacherName,
        'role': 'teacher',
        'joinedAt': DateTime.now().toIso8601String(),
      },
    );
    batch.update(_firestore.collection('users').doc(teacherId), {
      'classroomIds': FieldValue.arrayUnion([id]),
    });
    await batch.commit();
    return classroom;
  }

  @override
  Future<ClassroomModel> joinClassroom({
    required String code,
    required String studentId,
    required String studentName,
    required String studentEmail,
  }) async {
    final query = await _classrooms
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Code de classe invalide');
    }

    final doc = query.docs.first;
    final classroom =
        ClassroomModel.fromJson({...doc.data(), 'id': doc.id});

    if (classroom.teacherId == studentId) {
      throw Exception('Vous êtes l\'enseignant de cette classe');
    }

    final memberDoc = await _classrooms
        .doc(classroom.id)
        .collection('members')
        .doc(studentId)
        .get();

    if (memberDoc.exists) {
      throw Exception('Vous êtes déjà membre de cette classe');
    }

    final batch = _firestore.batch();
    batch.set(
      _classrooms.doc(classroom.id).collection('members').doc(studentId),
      {
        'uid': studentId,
        'displayName': studentName,
        'email': studentEmail,
        'role': 'student',
        'joinedAt': DateTime.now().toIso8601String(),
      },
    );
    batch.update(_classrooms.doc(classroom.id), {
      'studentCount': FieldValue.increment(1),
    });
    batch.update(_firestore.collection('users').doc(studentId), {
      'classroomIds': FieldValue.arrayUnion([classroom.id]),
    });
    await batch.commit();
    return classroom;
  }

  @override
  Future<ClassroomModel?> getClassroom(String classroomId) async {
    final doc = await _classrooms.doc(classroomId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ClassroomModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  @override
  Future<List<MemberModel>> getMembers(String classroomId) async {
    final query = await _classrooms
        .doc(classroomId)
        .collection('members')
        .get();
    return query.docs
        .map((d) => MemberModel.fromJson({...d.data(), 'uid': d.id}))
        .toList();
  }

  @override
  Future<void> deleteClassroom(String classroomId) async {
    final members = await _classrooms
        .doc(classroomId)
        .collection('members')
        .get();
    final batch = _firestore.batch();
    for (final m in members.docs) {
      batch.update(_firestore.collection('users').doc(m.id), {
        'classroomIds': FieldValue.arrayRemove([classroomId]),
      });
      batch.delete(m.reference);
    }
    batch.delete(_classrooms.doc(classroomId));
    await batch.commit();
  }

  @override
  Future<void> leaveClassroom({
    required String classroomId,
    required String userId,
  }) async {
    final batch = _firestore.batch();
    batch.delete(
      _classrooms.doc(classroomId).collection('members').doc(userId),
    );
    batch.update(_classrooms.doc(classroomId), {
      'studentCount': FieldValue.increment(-1),
    });
    batch.update(_firestore.collection('users').doc(userId), {
      'classroomIds': FieldValue.arrayRemove([classroomId]),
    });
    await batch.commit();
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final uuid = _uuid.v4().replaceAll('-', '').toUpperCase();
    return uuid.substring(0, 6);
  }
}
