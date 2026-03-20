// lib/features/assignments/presentation/screens/create_assignment_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/utils/date_utils.dart';
import 'package:educclass/core/utils/validators.dart';
import 'package:educclass/core/widgets/app_button.dart';
import 'package:educclass/core/widgets/app_text_field.dart';
import 'package:educclass/features/assignments/presentation/providers/assignment_provider.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateAssignmentScreen extends ConsumerStatefulWidget {
  const CreateAssignmentScreen({super.key, required this.classroomId});
  final String classroomId;

  @override
  ConsumerState<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState
    extends ConsumerState<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  bool _allowLate = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deadline),
      );
      if (time != null) {
        setState(() {
          _deadline = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    final assignment = await ref
        .read(createAssignmentProvider.notifier)
        .create(
          classroomId: widget.classroomId,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          deadline: _deadline,
          allowLateSubmission: _allowLate,
          createdById: user.uid,
          createdByName: user.displayName,
        );

    if (assignment != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devoir créé avec succès !')),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(createAssignmentProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error?.toString() ?? AppStrings.unknownError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(createAssignmentProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createAssignment)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: AppStrings.assignmentTitle,
                  controller: _titleController,
                  validator: (v) =>
                      Validators.required(v, 'Titre du devoir'),
                  prefixIcon: const Icon(Icons.assignment_outlined),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.assignmentDescription,
                  controller: _descController,
                  maxLines: 5,
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                const SizedBox(height: 20),
                const Text(
                  AppStrings.deadline,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDeadline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.grey50,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: AppColors.grey500),
                        const SizedBox(width: 12),
                        Text(
                          AppDateUtils.formatDateTime(_deadline),
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.grey800,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right,
                            color: AppColors.grey400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _allowLate,
                  onChanged: (v) => setState(() => _allowLate = v),
                  title: const Text(AppStrings.allowLateSubmission),
                  subtitle: const Text(
                    'Les étudiants pourront rendre après la deadline',
                    style: TextStyle(fontSize: 12),
                  ),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: AppStrings.createAssignment,
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
