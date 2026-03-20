// lib/features/classroom/presentation/screens/classrooms_list_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/router/route_names.dart';
import 'package:educclass/core/widgets/app_empty_state.dart';
import 'package:educclass/core/widgets/app_error.dart';
import 'package:educclass/core/widgets/loading_skeleton.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:educclass/features/classroom/presentation/providers/classroom_provider.dart';
import 'package:educclass/features/classroom/presentation/widgets/classroom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClassroomsListScreen extends ConsumerWidget {
  const ClassroomsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);

    return authAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          body: AppError(message: e.toString())),
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback(
              (_) => context.go(RouteNames.login));
          return const Scaffold(body: SizedBox());
        }

        final isTeacher = user.isTeacher;
        final classroomsAsync =
            ref.watch(userClassroomsProvider(user.uid));

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.myClasses),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push(RouteNames.notifications),
              ),
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    ref.read(authNotifierProvider.notifier).signOut();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        Text(user.email,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.grey500)),
                        Text(user.roleLabel,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text(AppStrings.logout),
                    ]),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: classroomsAsync.when(
            loading: () => ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 4,
              itemBuilder: (_, __) => const ClassroomCardSkeleton(),
            ),
            error: (e, _) =>
                AppError(message: e.toString(), onRetry: () => ref.refresh(
                    userClassroomsProvider(user.uid))),
            data: (classrooms) {
              if (classrooms.isEmpty) {
                return AppEmptyState(
                  icon: Icons.school_outlined,
                  title: AppStrings.noClasses,
                  subtitle: isTeacher
                      ? AppStrings.noClassesTeacher
                      : AppStrings.noClassesStudent,
                  action: isTeacher
                      ? () => context.push(RouteNames.createClassroom)
                      : () => context.push(RouteNames.joinClassroom),
                  actionLabel: isTeacher
                      ? AppStrings.createClass
                      : AppStrings.joinClass,
                );
              }

              return RefreshIndicator(
                onRefresh: () async =>
                    ref.refresh(userClassroomsProvider(user.uid)),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: classrooms.length,
                  itemBuilder: (_, i) => ClassroomCard(
                    classroom: classrooms[i],
                    isTeacher: classrooms[i].teacherId == user.uid,
                    onTap: () => context.push(
                      '/classrooms/${classrooms[i].id}',
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => isTeacher
                ? context.push(RouteNames.createClassroom)
                : context.push(RouteNames.joinClassroom),
            icon: Icon(isTeacher ? Icons.add : Icons.login),
            label: Text(
                isTeacher ? AppStrings.createClass : AppStrings.joinClass),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
        );
      },
    );
  }
}
