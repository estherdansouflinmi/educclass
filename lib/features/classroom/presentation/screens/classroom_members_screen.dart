// lib/features/classroom/presentation/screens/classroom_members_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/widgets/app_error.dart';
import 'package:educclass/core/widgets/app_loading.dart';
import 'package:educclass/features/classroom/presentation/providers/classroom_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassroomMembersScreen extends ConsumerWidget {
  const ClassroomMembersScreen({super.key, required this.classroomId});
  final String classroomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(classMembersProvider(classroomId));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.members)),
      body: membersAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppError(
          message: e.toString(),
          onRetry: () => ref.refresh(classMembersProvider(classroomId)),
        ),
        data: (members) {
          final teachers = members.where((m) => m.role.name == 'teacher').toList();
          final students = members.where((m) => m.role.name == 'student').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (teachers.isNotEmpty) ...[
                const _SectionHeader(title: 'Enseignant'),
                ...teachers.map((m) => _MemberTile(member: m)),
              ],
              if (students.isNotEmpty) ...[
                _SectionHeader(
                    title: 'Étudiants (${students.length})'),
                ...students.map((m) => _MemberTile(member: m)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.grey500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});
  final dynamic member;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          member.displayName.isNotEmpty
              ? member.displayName[0].toUpperCase()
              : 'U',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        member.displayName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        member.email ?? '',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
