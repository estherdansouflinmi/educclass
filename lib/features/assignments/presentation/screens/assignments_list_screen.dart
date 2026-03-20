// lib/features/assignments/presentation/screens/assignments_list_screen.dart
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/widgets/app_empty_state.dart';
import 'package:educclass/core/widgets/app_error.dart';
import 'package:educclass/core/widgets/loading_skeleton.dart';
import 'package:educclass/features/assignments/presentation/providers/assignment_provider.dart';
import 'package:educclass/features/assignments/presentation/widgets/assignment_card.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AssignmentsListScreen extends ConsumerWidget {
  const AssignmentsListScreen({super.key, required this.classroomId});
  final String classroomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider(classroomId));
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final isTeacher = user?.isTeacher == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.assignments),
        actions: [
          if (isTeacher)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context
                  .push('/classrooms/$classroomId/assignments/create'),
            ),
        ],
      ),
      body: assignmentsAsync.when(
        loading: () => ListView.builder(
          itemCount: 5,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (_, __) => const ListItemSkeleton(),
        ),
        error: (e, _) => AppError(
          message: e.toString(),
          onRetry: () => ref.refresh(assignmentsProvider(classroomId)),
        ),
        data: (assignments) {
          if (assignments.isEmpty) {
            return AppEmptyState(
              icon: Icons.assignment_outlined,
              title: AppStrings.noAssignments,
              subtitle: isTeacher
                  ? 'Créez votre premier devoir !'
                  : 'Aucun devoir publié pour l\'instant',
              action: isTeacher
                  ? () => context.push(
                      '/classrooms/$classroomId/assignments/create')
                  : null,
              actionLabel:
                  isTeacher ? AppStrings.createAssignment : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.refresh(assignmentsProvider(classroomId)),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: assignments.length,
              itemBuilder: (_, i) {
                final a = assignments[i];
                return AssignmentCard(
                  assignment: a,
                  onTap: () => context.push(
                      '/classrooms/$classroomId/assignments/${a.id}'),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isTeacher
          ? FloatingActionButton(
              onPressed: () => context
                  .push('/classrooms/$classroomId/assignments/create'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
