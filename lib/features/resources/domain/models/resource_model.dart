// lib/features/resources/domain/models/resource_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource_model.freezed.dart';
part 'resource_model.g.dart';

enum ResourceType { pdf, link, video }

@freezed
class ResourceModel with _$ResourceModel {
  const factory ResourceModel({
    required String id,
    required String classroomId,
    required String title,
    @Default('') String description,
    required ResourceType type,
    required String url,
    String? fileName,
    @Default(0) int fileSize,
    required String publishedById,
    required String publishedByName,
    @Default(0) int commentCount,
    required DateTime createdAt,
  }) = _ResourceModel;

  factory ResourceModel.fromJson(Map<String, dynamic> json) =>
      _$ResourceModelFromJson(json);
}

extension ResourceModelX on ResourceModel {
  bool get isPdf => type == ResourceType.pdf;
  bool get isLink => type == ResourceType.link || type == ResourceType.video;
  String get typeLabel {
    switch (type) {
      case ResourceType.pdf: return 'PDF';
      case ResourceType.link: return 'Lien';
      case ResourceType.video: return 'Vidéo';
    }
  }
}
