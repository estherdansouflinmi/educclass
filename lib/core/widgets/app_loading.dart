// lib/core/widgets/app_loading.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size = 40, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color ?? AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key, required this.child, this.isLoading = false});

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66FFFFFF),
              child: AppLoading(),
            ),
          ),
      ],
    );
  }
}
