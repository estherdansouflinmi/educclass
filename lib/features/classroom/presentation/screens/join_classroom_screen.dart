// lib/features/classroom/presentation/screens/join_classroom_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/utils/validators.dart';
import 'package:educclass/core/widgets/app_button.dart';
import 'package:educclass/core/widgets/app_text_field.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:educclass/features/classroom/presentation/providers/classroom_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class JoinClassroomScreen extends ConsumerStatefulWidget {
  const JoinClassroomScreen({super.key});

  @override
  ConsumerState<JoinClassroomScreen> createState() =>
      _JoinClassroomScreenState();
}

class _JoinClassroomScreenState extends ConsumerState<JoinClassroomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    final classroom = await ref.read(joinClassroomProvider.notifier).join(
          code: _codeController.text.trim(),
          studentId: user.uid,
          studentName: user.displayName,
          studentEmail: user.email,
        );

    if (classroom != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous avez rejoint "${classroom.name}" !')),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(joinClassroomProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error?.toString() ?? AppStrings.unknownError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(joinClassroomProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.joinClass)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.vpn_key_outlined,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Code de classe',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Demandez le code à votre enseignant',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: AppStrings.classCode,
                  hint: AppStrings.enterCode,
                  controller: _codeController,
                  validator: (v) =>
                      Validators.required(v, 'Code de classe'),
                  prefixIcon: const Icon(Icons.tag),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: AppStrings.joinClass,
                  onPressed: _submit,
                  isLoading: isLoading,
                  icon: const Icon(Icons.login, color: AppColors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
