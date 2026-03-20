// lib/core/widgets/app_error.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class AppError extends StatelessWidget {
  const AppError({
    super.key,
    this.message,
    this.onRetry,
  });

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              message ?? AppStrings.unknownError,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey700, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
