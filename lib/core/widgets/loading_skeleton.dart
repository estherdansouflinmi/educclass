// lib/core/widgets/loading_skeleton.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ClassroomCardSkeleton extends StatelessWidget {
  const ClassroomCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingSkeleton(width: double.infinity, height: 100, borderRadius: 12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                LoadingSkeleton(width: 180, height: 18),
                SizedBox(height: 8),
                LoadingSkeleton(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const LoadingSkeleton(width: 48, height: 48, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                LoadingSkeleton(width: double.infinity, height: 14),
                SizedBox(height: 6),
                LoadingSkeleton(width: 140, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
