// lib/features/assignments/presentation/screens/submissions_review_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/utils/date_utils.dart';
import 'package:educclass/core/widgets/app_empty_state.dart';
import 'package:educclass/core/widgets/app_error.dart';
import 'package:educclass/core/widgets/app_loading.dart';
import 'package:educclass/features/assignments/data/repositories/assignment_repository.dart';
import 'package:educclass/features/assignments/presentation/providers/assignment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmissionsReviewScreen extends ConsumerWidget {
  const SubmissionsReviewScreen({
    super.key,
    required this.classroomId,
    required this.assignmentId,
  });

  final String classroomId;
  final String assignmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(submissionsProvider(
        (classroomId: classroomId, assignmentId: assignmentId)));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.submissions)),
      body: submissionsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppError(message: e.toString()),
        data: (submissions) {
          if (submissions.isEmpty) {
            return const AppEmptyState(
              icon: Icons.assignment_outlined,
              title: AppStrings.noSubmissions,
              subtitle: 'Aucun étudiant n\'a encore rendu ce devoir',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: submissions.length,
            itemBuilder: (_, i) {
              final s = submissions[i];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: s.isLate
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    child: Text(
                      s.studentName.isNotEmpty
                          ? s.studentName[0].toUpperCase()
                          : 'E',
                      style: TextStyle(
                        color: s.isLate
                            ? AppColors.warning
                            : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    s.studentName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        AppDateUtils.formatDateTime(s.submittedAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.grey500),
                      ),
                      if (s.isLate) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            AppStrings.late,
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (s.content.isNotEmpty) ...[
                            const Text(
                              'Réponse :',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(s.content,
                                style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 12),
                          ],
                          if (s.attachmentUrl != null)
                            OutlinedButton.icon(
                              onPressed: () => launchUrl(
                                  Uri.parse(s.attachmentUrl!)),
                              icon: const Icon(Icons.download_outlined,
                                  size: 16),
                              label: Text(
                                  s.attachmentName ?? 'Télécharger le fichier'),
                            ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          _FeedbackForm(
                            classroomId: classroomId,
                            assignmentId: assignmentId,
                            studentId: s.studentId,
                            existingComment: s.teacherComment,
                            existingGrade: s.grade,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FeedbackForm extends ConsumerStatefulWidget {
  const _FeedbackForm({
    required this.classroomId,
    required this.assignmentId,
    required this.studentId,
    this.existingComment,
    this.existingGrade,
  });

  final String classroomId;
  final String assignmentId;
  final String studentId;
  final String? existingComment;
  final String? existingGrade;

  @override
  ConsumerState<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends ConsumerState<_FeedbackForm> {
  late final TextEditingController _commentCtrl;
  late final TextEditingController _gradeCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _commentCtrl =
        TextEditingController(text: widget.existingComment ?? '');
    _gradeCtrl =
        TextEditingController(text: widget.existingGrade ?? '');
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _gradeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(assignmentRepositoryProvider).addTeacherFeedback(
            classroomId: widget.classroomId,
            assignmentId: widget.assignmentId,
            studentId: widget.studentId,
            comment: _commentCtrl.text.trim(),
            grade: _gradeCtrl.text.trim().isEmpty
                ? null
                : _gradeCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback enregistré !')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback :',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _commentCtrl,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Ajouter un commentaire...',
            filled: true,
            fillColor: AppColors.grey50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: TextField(
                controller: _gradeCtrl,
                decoration: InputDecoration(
                  hintText: 'Note (opt.)',
                  filled: true,
                  fillColor: AppColors.grey50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColors.grey300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44)),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white))
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
