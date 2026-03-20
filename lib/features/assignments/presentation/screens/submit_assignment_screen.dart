// lib/features/assignments/presentation/screens/submit_assignment_screen.dart
import 'dart:io';
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/utils/file_utils.dart';
import 'package:educclass/core/widgets/app_button.dart';
import 'package:educclass/core/widgets/app_text_field.dart';
import 'package:educclass/features/assignments/data/repositories/assignment_repository.dart';
import 'package:educclass/features/assignments/presentation/providers/assignment_provider.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SubmitAssignmentScreen extends ConsumerStatefulWidget {
  const SubmitAssignmentScreen({
    super.key,
    required this.classroomId,
    required this.assignmentId,
  });

  final String classroomId;
  final String assignmentId;

  @override
  ConsumerState<SubmitAssignmentScreen> createState() =>
      _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState
    extends ConsumerState<SubmitAssignmentScreen> {
  final _contentController = TextEditingController();
  File? _file;
  String? _fileName;
  bool _isSubmitting = false;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final f = File(result.files.single.path!);
      final size = await f.length();
      if (!FileUtils.isValidFileSize(size)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.fileTooLarge)),
          );
        }
        return;
      }
      setState(() {
        _file = f;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty && _file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Ajoutez du texte ou un fichier avant de rendre le devoir')),
      );
      return;
    }

    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    final assignmentAsync = ref.read(assignmentProvider(
        (classroomId: widget.classroomId,
            assignmentId: widget.assignmentId)));
    final assignment = assignmentAsync.valueOrNull;
    if (assignment == null) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(assignmentRepositoryProvider).submitAssignment(
            classroomId: widget.classroomId,
            assignmentId: widget.assignmentId,
            studentId: user.uid,
            studentName: user.displayName,
            content: _contentController.text.trim(),
            attachmentFile: _file,
            deadline: assignment.deadline,
            onProgress: (p) => setState(() => _uploadProgress = p),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Devoir rendu avec succès !')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.submitAssignment)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.yourWork,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: AppStrings.addText,
                controller: _contentController,
                maxLines: 6,
                minLines: 4,
                prefixIcon: const Icon(Icons.edit_note),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _file != null
                          ? AppColors.success
                          : AppColors.grey300,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _file != null
                        ? AppColors.success.withOpacity(0.05)
                        : AppColors.grey50,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _file != null
                            ? Icons.attach_file
                            : Icons.upload_outlined,
                        color: _file != null
                            ? AppColors.success
                            : AppColors.grey400,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _file != null
                              ? _fileName ?? 'Fichier sélectionné'
                              : AppStrings.attachFile,
                          style: TextStyle(
                            color: _file != null
                                ? AppColors.grey800
                                : AppColors.grey500,
                          ),
                        ),
                      ),
                      if (_file != null)
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.grey400, size: 18),
                          onPressed: () =>
                              setState(() {
                                _file = null;
                                _fileName = null;
                              }),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
              if (_isSubmitting && _uploadProgress > 0) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Envoi : ${(_uploadProgress * 100).toInt()}%',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.grey600),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: AppColors.grey200,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              AppButton(
                label: AppStrings.submitAssignment,
                onPressed: _submit,
                isLoading: _isSubmitting,
                icon: const Icon(Icons.send, color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
