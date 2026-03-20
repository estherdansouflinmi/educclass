// lib/features/resources/data/repositories/resource_repository.dart
import 'dart:io';
import 'package:educclass/features/resources/domain/models/resource_model.dart';

abstract class ResourceRepository {
  Stream<List<ResourceModel>> watchResources(String classroomId);
  Future<ResourceModel> addLinkResource({
    required String classroomId,
    required String title,
    required String description,
    required String url,
    required ResourceType type,
    required String publishedById,
    required String publishedByName,
  });
  Future<ResourceModel> uploadPdfResource({
    required String classroomId,
    required String title,
    required String description,
    required File file,
    required String publishedById,
    required String publishedByName,
    required void Function(double) onProgress,
  });
  Future<void> deleteResource({
    required String classroomId,
    required String resourceId,
    String? storagePath,
  });
  Future<ResourceModel?> getResource({
    required String classroomId,
    required String resourceId,
  });
}
