// lib/features/resources/data/repositories/resource_repository_impl.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:educclass/features/resources/data/repositories/resource_repository.dart';
import 'package:educclass/features/resources/domain/models/resource_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ResourceRepositoryImpl implements ResourceRepository {
  ResourceRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _resources(String classroomId) =>
      _firestore
          .collection('classrooms')
          .doc(classroomId)
          .collection('resources');

  @override
  Stream<List<ResourceModel>> watchResources(String classroomId) {
    return _resources(classroomId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ResourceModel.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  @override
  Future<ResourceModel> addLinkResource({
    required String classroomId,
    required String title,
    required String description,
    required String url,
    required ResourceType type,
    required String publishedById,
    required String publishedByName,
  }) async {
    final id = _uuid.v4();
    final resource = ResourceModel(
      id: id,
      classroomId: classroomId,
      title: title,
      description: description,
      type: type,
      url: url,
      publishedById: publishedById,
      publishedByName: publishedByName,
      createdAt: DateTime.now(),
    );
    await _resources(classroomId).doc(id).set(resource.toJson());
    return resource;
  }

  @override
  Future<ResourceModel> uploadPdfResource({
    required String classroomId,
    required String title,
    required String description,
    required File file,
    required String publishedById,
    required String publishedByName,
    required void Function(double) onProgress,
  }) async {
    final id = _uuid.v4();
    final fileName = file.path.split('/').last;
    final storagePath = 'classrooms/$classroomId/resources/$id/$fileName';

    final ref = _storage.ref(storagePath);
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'application/pdf'),
    );

    uploadTask.snapshotEvents.listen((snap) {
      final progress = snap.bytesTransferred / snap.totalBytes;
      onProgress(progress);
    });

    await uploadTask;
    final url = await ref.getDownloadURL();
    final fileSize = await file.length();

    final resource = ResourceModel(
      id: id,
      classroomId: classroomId,
      title: title,
      description: description,
      type: ResourceType.pdf,
      url: url,
      fileName: fileName,
      fileSize: fileSize,
      publishedById: publishedById,
      publishedByName: publishedByName,
      createdAt: DateTime.now(),
    );

    await _resources(classroomId).doc(id).set(resource.toJson());
    return resource;
  }

  @override
  Future<void> deleteResource({
    required String classroomId,
    required String resourceId,
    String? storagePath,
  }) async {
    if (storagePath != null) {
      try {
        await _storage.ref(storagePath).delete();
      } catch (_) {}
    }
    await _resources(classroomId).doc(resourceId).delete();
  }

  @override
  Future<ResourceModel?> getResource({
    required String classroomId,
    required String resourceId,
  }) async {
    final doc = await _resources(classroomId).doc(resourceId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ResourceModel.fromJson({...doc.data()!, 'id': doc.id});
  }
}
