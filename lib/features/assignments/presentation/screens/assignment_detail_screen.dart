// lib/features/assignments/presentation/screens/assignment_detail_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/utils/date_utils.dart';
import 'package:educclass/core/widgets/app_button.dart';
import 'package:educclass/core/widgets/app_error.dart';
import 'package:educclass/core/widgets/app_loading.dart';
import 'package:educclass/features/assignments/presentation/providers/assignment_provider.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AssignmentDetailScreen extends ConsumerWidget {
  const AssignmentDetailScreen({
    super.key,
    required this.classroomId,
    required this.assignmentId,
  });

  final String classroomId;
  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentAsync = ref.watch(assignmentProvider(
        (classroomId: classroomId, assignmentId: assignmentId)));
    final user = ref.watch(authNotifierProvider).valueOrNull;

    return assignmentAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppError(message: e.toString()),
      ),
      data: (assignment) {
        if (assignment == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppError(message: 'Devoir introuvable'),
          );
        }

        final isTeacher = user?.uid == assignment.createdById;
        final isPast = AppDateUtils.isPast(assignment.deadline);
        final isSoon = AppDateUtils.isDeadlineSoon(assignment.deadline);

        Color deadlineColor = AppColors.success;
        if (isPast) deadlineColor = AppColors.error;
        else if (isSoon) deadlineColor = AppColors.warning;

        return Scaffold(
          appBar: AppBar(
            title: Text(assignment.title),
            actions: [
              if (isTeacher)
                IconButton(
                  icon: const Icon(Icons.group_outlined),
                  onPressed: () => context.push(
                    '/classrooms/$classroomId/assignments/$assignmentId/submissions',
                  ),
                  tooltip: AppStrings.submissions,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deadline badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: deadlineColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: deadlineColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule,
                          color: deadlineColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        AppDateUtils.deadlineLabel(assignment.deadline),
                        style: TextStyle(
                          color: deadlineColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Date limite : ${AppDateUtils.formatDateTime(assignment.deadline)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grey500),
                ),
                if (assignment.description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignment.description,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.grey700, height: 1.5),
                  ),
                ],
                const SizedBox(height: 24),
                if (isTeacher) ...[
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.assignment_turned_in_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${assignment.submissionCount} rendu${assignment.submissionCount > 1 ? 's' : ''} / ${assignment.totalStudents} étudiant${assignment.totalStudents > 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Voir les rendus (${assignment.submissionCount})',
                    onPressed: () => context.push(
                      '/classrooms/$classroomId/assignments/$assignmentId/submissions',
                    ),
                    variant: AppButtonVariant.outlined,
                  ),
                ] else ...[
                  // Student: check submission
                  if (user != null)
                    _StudentSubmissionSection(
                      classroomId: classroomId,
                      assignmentId: assignmentId,
                      studentId: user.uid,
                      isPast: isPast,
                      allowLate: assignment.allowLateSubmission,
                    ),
                ],
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: const Center(
                    child: Text(
                      'Section commentaires disponible après déploiement complet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.grey400, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudentSubmissionSection extends ConsumerWidget {
  const _StudentSubmissionSection({
    required this.classroomId,
    required this.assignmentId,
    required this.studentId,
    required this.isPast,
    required this.allowLate,
  });

  final String classroomId;
  final String assignmentId;
  final String studentId;
  final bool isPast;
  final bool allowLate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionAsync = ref.watch(mySubmissionProvider((
      classroomId: classroomId,
      assignmentId: assignmentId,
      studentId: studentId,
    )));

    return submissionAsync.when(
      loading: () => const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, __) => const SizedBox(),
      data: (submission) {
        if (submission != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: submission.isLate
                  ? AppColors.warning.withOpacity(0.08)
                  : AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: submission.isLate
                    ? AppColors.warning.withOpacity(0.3)
                    : AppColors.success.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      submission.isLate
                          ? Icons.warning_outlined
                          : Icons.check_circle_outline,
                      color: submission.isLate
                          ? AppColors.warning
                          : AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      submission.isLate
                          ? 'Rendu en retard'
                          : 'Devoir rendu',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: submission.isLate
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Remis le ${AppDateUtils.formatDateTime(submission.submittedAt)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grey500),
                ),
                if (submission.teacherComment != null) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const Text(
                    'Commentaire de l\'enseignant :',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600),
                  ),
                  const SizedBox(height: 4),
                  Text(submission.teacherComment!,
                      style: const TextStyle(fontSize: 13)),
                ],
              ],
            ),
          );
        }

        final canSubmit = !isPast || allowLate;
        if (!canSubmit) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.error, size: 18),
                SizedBox(width: 8),
                Text(
                  'La deadline est passée — soumission fermée',
                  style: TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return AppButton(
          label: AppStrings.submitAssignment,
          onPressed: () => context.push(
            '/classrooms/$classroomId/assignments/$assignmentId/submit',
          ),
          icon: const Icon(Icons.upload_outlined,
              color: AppColors.white),
        );
      },
    );
  }
}
