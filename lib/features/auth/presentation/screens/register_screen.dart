// lib/features/auth/presentation/screens/register_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/router/route_names.dart';
import 'package:educclass/core/utils/validators.dart';
import 'package:educclass/core/widgets/app_button.dart';
import 'package:educclass/core/widgets/app_text_field.dart';
import 'package:educclass/features/auth/domain/models/user_model.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:educclass/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  UserRole _role = UserRole.student;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
          role: _role,
        );
    final error = ref.read(authNotifierProvider).error;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapError(error.toString()))),
      );
    } else if (mounted) {
      context.go(RouteNames.classrooms);
    }
  }

  String _mapError(String error) {
    if (error.contains('email-already-in-use')) return 'Cet email est déjà utilisé';
    if (error.contains('weak-password')) return 'Mot de passe trop faible';
    if (error.contains('network')) return AppStrings.networkError;
    return AppStrings.unknownError;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Rejoignez EduClass aujourd\'hui',
                  style: TextStyle(fontSize: 15, color: AppColors.grey500),
                ),
                const SizedBox(height: 32),

                // Role selector
                const Text(
                  AppStrings.chooseRole,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        role: UserRole.student,
                        selectedRole: _role,
                        onTap: () => setState(() => _role = UserRole.student),
                        icon: Icons.person_outline,
                        label: AppStrings.student,
                        description: AppStrings.studentDesc,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        role: UserRole.teacher,
                        selectedRole: _role,
                        onTap: () => setState(() => _role = UserRole.teacher),
                        icon: Icons.school_outlined,
                        label: AppStrings.teacher,
                        description: AppStrings.teacherDesc,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                AppTextField(
                  label: AppStrings.displayName,
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) => Validators.required(v, 'Nom complet'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.confirmPassword,
                  controller: _confirmController,
                  obscureText: true,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordController.text),
                  prefixIcon: const Icon(Icons.lock_outline),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: AppStrings.register,
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(AppStrings.or,
                          style: TextStyle(color: AppColors.grey400)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                GoogleSignInButton(
                  onPressed: () async {
                    await ref
                        .read(authNotifierProvider.notifier)
                        .signInWithGoogle(role: _role);
                    if (ref.read(authNotifierProvider).hasError && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(AppStrings.unknownError)),
                      );
                    } else if (mounted) {
                      context.go(RouteNames.classrooms);
                    }
                  },
                  isLoading: isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.alreadyAccount),
                    TextButton(
                      onPressed: () => context.go(RouteNames.login),
                      child: const Text(AppStrings.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selectedRole,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.description,
  });

  final UserRole role;
  final UserRole selectedRole;
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    final isSelected = role == selectedRole;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.grey50,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.grey500,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.grey700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
