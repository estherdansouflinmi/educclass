// lib/features/resources/presentation/screens/resources_list_screen.dart
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/widgets/app_empty_state.dart';
import 'package:educclass/core/widgets/app_error.dart';
import 'package:educclass/core/widgets/loading_skeleton.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:educclass/features/resources/presentation/providers/resource_provider.dart';
import 'package:educclass/features/resources/presentation/widgets/resource_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResourcesListScreen extends ConsumerWidget {
  const ResourcesListScreen({super.key, required this.classroomId});
  final String classroomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourcesAsync = ref.watch(resourcesProvider(classroomId));
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final isTeacher = user != null;  // refined in actual check

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resources),
        actions: [
          if (user?.isTeacher == true)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () =>
                  context.push('/classrooms/$classroomId/resources/add'),
            ),
        ],
      ),
      body: resourcesAsync.when(
        loading: () => ListView.builder(
          itemCount: 5,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (_, __) => const ListItemSkeleton(),
        ),
        error: (e, _) => AppError(
          message: e.toString(),
          onRetry: () => ref.refresh(resourcesProvider(classroomId)),
        ),
        data: (resources) {
          if (resources.isEmpty) {
            return AppEmptyState(
              icon: Icons.description_outlined,
              title: AppStrings.noResources,
              subtitle: user?.isTeacher == true
                  ? 'Ajoutez votre première ressource !'
                  : 'Votre enseignant n\'a pas encore publié de ressources',
              action: user?.isTeacher == true
                  ? () => context
                      .push('/classrooms/$classroomId/resources/add')
                  : null,
              actionLabel:
                  user?.isTeacher == true ? AppStrings.addResource : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(resourcesProvider(classroomId)),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: resources.length,
              itemBuilder: (_, i) {
                final r = resources[i];
                return ResourceCard(
                  resource: r,
                  onTap: () => context.push(
                      '/classrooms/$classroomId/resources/${r.id}'),
                  onDelete: user?.isTeacher == true
                      ? () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Supprimer la ressource'),
                              content: const Text(AppStrings.deleteConfirm),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(AppStrings.cancel)),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(AppStrings.delete,
                                        style: TextStyle(
                                            color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref
                                .read(resourceRepositoryProvider)
                                .deleteResource(
                                    classroomId: classroomId,
                                    resourceId: r.id);
                          }
                        }
                      : null,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: user?.isTeacher == true
          ? FloatingActionButton(
              onPressed: () =>
                  context.push('/classrooms/$classroomId/resources/add'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
