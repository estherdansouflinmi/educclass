// lib/features/classroom/presentation/widgets/classroom_card.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/features/classroom/domain/models/classroom_model.dart';
import 'package:flutter/material.dart';

class ClassroomCard extends StatelessWidget {
  const ClassroomCard({
    super.key,
    required this.classroom,
    required this.onTap,
    this.isTeacher = false,
  });

  final ClassroomModel classroom;
  final VoidCallback onTap;
  final bool isTeacher;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.classroomColorFromHex(classroom.coverColor);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 100,
              width: double.infinity,
              color: color,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          classroom.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isTeacher)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Enseignant',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
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
            // Footer
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.group_outlined,
                      size: 16, color: AppColors.grey500),
                  const SizedBox(width: 4),
                  Text(
                    '${classroom.studentCount} étudiant${classroom.studentCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grey500),
                  ),
                  const Spacer(),
                  if (isTeacher) ...[
                    const Icon(Icons.key_outlined,
                        size: 14, color: AppColors.grey400),
                    const SizedBox(width: 4),
                    Text(
                      classroom.code,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey500,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
