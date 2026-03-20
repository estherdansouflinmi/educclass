// lib/features/resources/presentation/widgets/resource_card.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/utils/date_utils.dart';
import 'package:educclass/core/utils/file_utils.dart';
import 'package:educclass/features/resources/domain/models/resource_model.dart';
import 'package:flutter/material.dart';

class ResourceCard extends StatelessWidget {
  const ResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
    this.onDelete,
  });

  final ResourceModel resource;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  IconData get _icon {
    switch (resource.type) {
      case ResourceType.pdf:
        return Icons.picture_as_pdf_outlined;
      case ResourceType.video:
        return Icons.play_circle_outline;
      case ResourceType.link:
        return Icons.link;
    }
  }

  Color get _iconColor {
    switch (resource.type) {
      case ResourceType.pdf:
        return AppColors.error;
      case ResourceType.video:
        return AppColors.warning;
      case ResourceType.link:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          resource.typeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: _iconColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (resource.fileSize > 0) ...[
                          const Text(' · ',
                              style:
                                  TextStyle(color: AppColors.grey400)),
                          Text(
                            FileUtils.formatFileSize(resource.fileSize),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.grey400),
                          ),
                        ],
                        const Text(' · ',
                            style: TextStyle(color: AppColors.grey400)),
                        Text(
                          AppDateUtils.relativeTime(resource.createdAt),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.grey400),
                        ),
                      ],
                    ),
                    if (resource.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        resource.description,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grey500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (resource.commentCount > 0) ...[
                    const Icon(Icons.chat_bubble_outline,
                        size: 13, color: AppColors.grey400),
                    const SizedBox(width: 2),
                    Text(
                      '${resource.commentCount}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.grey400),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 18),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
