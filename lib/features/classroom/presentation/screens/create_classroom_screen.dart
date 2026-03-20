// lib/features/classroom/presentation/screens/create_classroom_screen.dart
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

class CreateClassroomScreen extends ConsumerStatefulWidget {
  const CreateClassroomScreen({super.key});

  @override
  ConsumerState<CreateClassroomScreen> createState() =>
      _CreateClassroomScreenState();
}

class _CreateClassroomScreenState
    extends ConsumerState<CreateClassroomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedColor = '#1A73E8';

  static const _colors = [
    '#1A73E8', '#34A853', '#EA4335', '#FBBC04',
    '#9C27B0', '#00BCD4', '#FF5722', '#607D8B',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    final classroom = await ref
        .read(createClassroomProvider.notifier)
        .create(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          teacherId: user.uid,
          teacherName: user.displayName,
          coverColor: _selectedColor,
        );

    if (classroom != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Classe créée ! Code : ${classroom.code}')),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(createClassroomProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.toString() ?? AppStrings.unknownError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(createClassroomProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createClass)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: AppStrings.className,
                  controller: _nameController,
                  validator: (v) => Validators.required(v, 'Nom de la classe'),
                  prefixIcon: const Icon(Icons.class_outlined),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.classDescription,
                  controller: _descController,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.description_outlined),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Couleur de la classe',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _colors.map((hex) {
                    final color = AppColors.classroomColorFromHex(hex);
                    final isSelected = _selectedColor == hex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = hex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.grey900
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: AppColors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                AppButton(
                  label: AppStrings.createClass,
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
