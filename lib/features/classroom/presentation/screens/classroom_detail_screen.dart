// lib/features/classroom/presentation/screens/classroom_detail_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/widgets/app_error.dart';
import 'package:educclass/core/widgets/app_loading.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:educclass/features/classroom/presentation/providers/classroom_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClassroomDetailScreen extends ConsumerWidget {
  const ClassroomDetailScreen({super.key, required this.classroomId});
  final String classroomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classroomAsync = ref.watch(classroomProvider(classroomId));
    final user = ref.watch(authNotifierProvider).valueOrNull;

    return classroomAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppError(message: e.toString()),
      ),
      data: (classroom) {
        if (classroom == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppError(message: 'Classe introuvable'),
          );
        }

        final isTeacher = user?.uid == classroom.teacherId;
        final color = AppColors.classroomColorFromHex(classroom.coverColor);

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  expandedHeight: 160,
                  pinned: true,
                  backgroundColor: color,
                  foregroundColor: AppColors.white,
                  actions: [
                    if (isTeacher)
                      IconButton(
                        icon: const Icon(Icons.key_outlined),
                        tooltip: 'Code de la classe',
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: classroom.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Code "${classroom.code}" copié !'),
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.group_outlined),
                      tooltip: AppStrings.members,
                      onPressed: () => context
                          .push('/classrooms/$classroomId/members'),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      classroom.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    background: Container(
                      color: color,
                      padding: const EdgeInsets.fromLTRB(16, 80, 16, 48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classroom.teacherName,
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    indicatorColor: AppColors.white,
                    labelColor: AppColors.white,
                    unselectedLabelColor: AppColors.white.withOpacity(0.7),
                    tabs: const [
                      Tab(text: AppStrings.resources),
                      Tab(text: AppStrings.assignments),
                    ],
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  // Resources tab
                  _QuickListTab(
                    icon: Icons.description_outlined,
                    label: AppStrings.resources,
                    onTap: () => context
                        .push('/classrooms/$classroomId/resources'),
                    actionLabel: isTeacher ? AppStrings.addResource : null,
                    onAction: isTeacher
                        ? () => context.push(
                            '/classrooms/$classroomId/resources/add')
                        : null,
                  ),
                  // Assignments tab
                  _QuickListTab(
                    icon: Icons.assignment_outlined,
                    label: AppStrings.assignments,
                    onTap: () => context
                        .push('/classrooms/$classroomId/assignments'),
                    actionLabel:
                        isTeacher ? AppStrings.createAssignment : null,
                    onAction: isTeacher
                        ? () => context.push(
                            '/classrooms/$classroomId/assignments/create')
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickListTab extends StatelessWidget {
  const _QuickListTab({
    required this.icon,
    required this.label,
    required this.onTap,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            'Voir les $label',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onTap,
            child: Text('Ouvrir les $label'),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
