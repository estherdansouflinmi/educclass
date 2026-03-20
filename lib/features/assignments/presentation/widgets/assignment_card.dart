// lib/features/assignments/presentation/widgets/assignment_card.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/utils/date_utils.dart';
import 'package:educclass/features/assignments/domain/models/assignment_model.dart';
import 'package:flutter/material.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
    this.submissionStatus,
  });

  final AssignmentModel assignment;
  final VoidCallback onTap;
  final String? submissionStatus; // 'submitted' | 'late' | null

  Color get _deadlineColor {
    if (AppDateUtils.isPast(assignment.deadline)) return AppColors.error;
    if (AppDateUtils.isDeadlineSoon(assignment.deadline)) return AppColors.warning;
    return AppColors.grey500;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: _deadlineColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          AppDateUtils.deadlineLabel(assignment.deadline),
                          style: TextStyle(
                            fontSize: 11,
                            color: _deadlineColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (assignment.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        assignment.description,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.grey500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (submissionStatus == 'submitted')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        AppStrings.submitted,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (submissionStatus == 'late')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        AppStrings.late,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${assignment.submissionCount} rendu${assignment.submissionCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.grey400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
