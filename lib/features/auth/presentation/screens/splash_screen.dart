// lib/features/auth/presentation/screens/splash_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/providers/firebase_providers.dart';
import 'package:educclass/core/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          context.go(RouteNames.classrooms);
        } else {
          context.go(RouteNames.login);
        }
      },
      loading: () {},
      error: (_, __) => context.go(RouteNames.login),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      next.when(
        data: (user) {
          if (user != null) {
            context.go(RouteNames.classrooms);
          } else {
            context.go(RouteNames.login);
          }
        },
        loading: () {},
        error: (_, __) => context.go(RouteNames.login),
      );
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 72,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.appTagline,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
