// lib/core/router/app_router.dart
import 'package:educclass/core/providers/firebase_providers.dart';
import 'package:educclass/core/router/route_names.dart';
import 'package:educclass/features/assignments/presentation/screens/assignment_detail_screen.dart';
import 'package:educclass/features/assignments/presentation/screens/assignments_list_screen.dart';
import 'package:educclass/features/assignments/presentation/screens/create_assignment_screen.dart';
import 'package:educclass/features/assignments/presentation/screens/submissions_review_screen.dart';
import 'package:educclass/features/assignments/presentation/screens/submit_assignment_screen.dart';
import 'package:educclass/features/auth/presentation/screens/login_screen.dart';
import 'package:educclass/features/auth/presentation/screens/register_screen.dart';
import 'package:educclass/features/auth/presentation/screens/splash_screen.dart';
import 'package:educclass/features/classroom/presentation/screens/classroom_detail_screen.dart';
import 'package:educclass/features/classroom/presentation/screens/classroom_members_screen.dart';
import 'package:educclass/features/classroom/presentation/screens/classrooms_list_screen.dart';
import 'package:educclass/features/classroom/presentation/screens/create_classroom_screen.dart';
import 'package:educclass/features/classroom/presentation/screens/join_classroom_screen.dart';
import 'package:educclass/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:educclass/features/resources/presentation/screens/add_resource_screen.dart';
import 'package:educclass/features/resources/presentation/screens/pdf_viewer_screen.dart';
import 'package:educclass/features/resources/presentation/screens/resource_detail_screen.dart';
import 'package:educclass/features/resources/presentation/screens/resources_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.splash;

      if (!isAuthenticated && !isAuthRoute) return RouteNames.login;
      if (isAuthenticated &&
          (state.matchedLocation == RouteNames.login ||
              state.matchedLocation == RouteNames.register)) {
        return RouteNames.classrooms;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.classrooms,
        builder: (_, __) => const ClassroomsListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, __) => const CreateClassroomScreen(),
          ),
          GoRoute(
            path: 'join',
            builder: (_, __) => const JoinClassroomScreen(),
          ),
          GoRoute(
            path: ':classroomId',
            builder: (_, state) => ClassroomDetailScreen(
              classroomId: state.pathParameters['classroomId']!,
            ),
            routes: [
              GoRoute(
                path: 'members',
                builder: (_, state) => ClassroomMembersScreen(
                  classroomId: state.pathParameters['classroomId']!,
                ),
              ),
              GoRoute(
                path: 'resources',
                builder: (_, state) => ResourcesListScreen(
                  classroomId: state.pathParameters['classroomId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (_, state) => AddResourceScreen(
                      classroomId: state.pathParameters['classroomId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':resourceId',
                    builder: (_, state) => ResourceDetailScreen(
                      classroomId: state.pathParameters['classroomId']!,
                      resourceId: state.pathParameters['resourceId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'assignments',
                builder: (_, state) => AssignmentsListScreen(
                  classroomId: state.pathParameters['classroomId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (_, state) => CreateAssignmentScreen(
                      classroomId: state.pathParameters['classroomId']!,
                    ),
                  ),
                  GoRoute(
                    path: ':assignmentId',
                    builder: (_, state) => AssignmentDetailScreen(
                      classroomId: state.pathParameters['classroomId']!,
                      assignmentId: state.pathParameters['assignmentId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'submit',
                        builder: (_, state) => SubmitAssignmentScreen(
                          classroomId: state.pathParameters['classroomId']!,
                          assignmentId: state.pathParameters['assignmentId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'submissions',
                        builder: (_, state) => SubmissionsReviewScreen(
                          classroomId: state.pathParameters['classroomId']!,
                          assignmentId: state.pathParameters['assignmentId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.pdfViewer,
        builder: (_, state) {
          final extra = state.extra as Map<String, String>;
          return PdfViewerScreen(
            url: extra['url']!,
            title: extra['title'] ?? 'Document',
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page introuvable: ${state.error}')),
    ),
  );
});
