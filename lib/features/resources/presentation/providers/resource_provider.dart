// lib/features/resources/presentation/providers/resource_provider.dart
import 'dart:io';
import 'package:educclass/core/providers/firebase_providers.dart';
import 'package:educclass/features/resources/data/repositories/resource_repository.dart';
import 'package:educclass/features/resources/data/repositories/resource_repository_impl.dart';
import 'package:educclass/features/resources/domain/models/resource_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  return ResourceRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageProvider),
  );
});

final resourcesProvider =
    StreamProvider.family<List<ResourceModel>, String>((ref, classroomId) {
  return ref.watch(resourceRepositoryProvider).watchResources(classroomId);
});

final resourceProvider =
    FutureProvider.family<ResourceModel?, ({String classroomId, String resourceId})>(
        (ref, params) {
  return ref.watch(resourceRepositoryProvider).getResource(
        classroomId: params.classroomId,
        resourceId: params.resourceId,
      );
});

class AddResourceNotifier extends AsyncNotifier<ResourceModel?> {
  double _uploadProgress = 0;
  double get uploadProgress => _uploadProgress;

  @override
  Future<ResourceModel?> build() async => null;

  Future<ResourceModel?> addLink({
    required String classroomId,
    required String title,
    required String description,
    required String url,
    required ResourceType type,
    required String publishedById,
    required String publishedByName,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(resourceRepositoryProvider).addLinkResource(
            classroomId: classroomId,
            title: title,
            description: description,
            url: url,
            type: type,
            publishedById: publishedById,
            publishedByName: publishedByName,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<ResourceModel?> uploadPdf({
    required String classroomId,
    required String title,
    required String description,
    required File file,
    required String publishedById,
    required String publishedByName,
  }) async {
    state = const AsyncLoading();
    _uploadProgress = 0;
    final result = await AsyncValue.guard(
      () => ref.read(resourceRepositoryProvider).uploadPdfResource(
            classroomId: classroomId,
            title: title,
            description: description,
            file: file,
            publishedById: publishedById,
            publishedByName: publishedByName,
            onProgress: (p) => _uploadProgress = p,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

final addResourceProvider =
    AsyncNotifierProvider<AddResourceNotifier, ResourceModel?>(
        AddResourceNotifier.new);

final uploadProgressProvider = StateProvider<double>((ref) => 0);
