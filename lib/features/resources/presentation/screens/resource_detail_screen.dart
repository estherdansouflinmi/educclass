// lib/features/resources/presentation/screens/resource_detail_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/utils/date_utils.dart';
import 'package:educclass/core/widgets/app_error.dart';
import 'package:educclass/core/widgets/app_loading.dart';
import 'package:educclass/features/resources/domain/models/resource_model.dart';
import 'package:educclass/features/resources/presentation/providers/resource_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceDetailScreen extends ConsumerWidget {
  const ResourceDetailScreen({
    super.key,
    required this.classroomId,
    required this.resourceId,
  });

  final String classroomId;
  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceAsync = ref.watch(
        resourceProvider((classroomId: classroomId, resourceId: resourceId)));

    return Scaffold(
      body: resourceAsync.when(
        loading: () => const Scaffold(body: AppLoading()),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: AppError(message: e.toString()),
        ),
        data: (resource) {
          if (resource == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const AppError(message: 'Ressource introuvable'),
            );
          }
          final color = resource.isPdf
              ? AppColors.error
              : resource.type == ResourceType.video
                  ? AppColors.warning
                  : AppColors.primary;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 120,
                backgroundColor: color,
                foregroundColor: AppColors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    resource.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  background: Container(color: color),
                ),
                actions: [
                  if (resource.isPdf)
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => context.push(
                        '/pdf-viewer',
                        extra: {'url': resource.url, 'title': resource.title},
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.launch),
                      onPressed: () => launchUrl(Uri.parse(resource.url)),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              resource.typeLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Publié par ${resource.publishedByName}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.grey500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppDateUtils.formatDateTime(resource.createdAt),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grey400),
                      ),
                      if (resource.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          resource.description,
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.grey700),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (resource.isPdf)
                        ElevatedButton.icon(
                          onPressed: () => context.push(
                            '/pdf-viewer',
                            extra: {
                              'url': resource.url,
                              'title': resource.title
                            },
                          ),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Ouvrir le PDF'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () =>
                              launchUrl(Uri.parse(resource.url)),
                          icon: const Icon(Icons.launch),
                          label: const Text('Ouvrir le lien'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.comments,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Comments section placeholder - implemented in comments feature
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.grey50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: const Center(
                          child: Text(
                            'Les commentaires sont disponibles après le déploiement complet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.grey400, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
