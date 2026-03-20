// lib/features/notifications/presentation/screens/notifications_screen.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/utils/date_utils.dart';
import 'package:educclass/core/widgets/app_empty_state.dart';
import 'package:educclass/core/widgets/app_error.dart';
import 'package:educclass/core/widgets/app_loading.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:educclass/features/notifications/domain/models/notification_model.dart';
import 'package:educclass/features/notifications/presentation/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Non authentifié')),
      );
    }

    final notificationsAsync = ref.watch(notificationsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        actions: [
          TextButton(
            onPressed: () => ref
                .read(notificationRepositoryProvider)
                .markAllAsRead(user.uid),
            child: const Text('Tout lire'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppError(message: e.toString()),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const AppEmptyState(
              icon: Icons.notifications_none_outlined,
              title: AppStrings.noNotifications,
              subtitle: 'Vous n\'avez aucune notification pour l\'instant',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (_, i) {
              final n = notifications[i];
              return _NotificationTile(
                notification: n,
                onTap: () {
                  ref
                      .read(notificationRepositoryProvider)
                      .markAsRead(n.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.kind) {
      case NotificationKind.newAssignment:
        return Icons.assignment_outlined;
      case NotificationKind.newResource:
        return Icons.description_outlined;
      case NotificationKind.submissionReceived:
        return Icons.assignment_turned_in_outlined;
      case NotificationKind.comment:
        return Icons.chat_bubble_outline;
      case NotificationKind.deadlineReminder:
        return Icons.alarm_outlined;
    }
  }

  Color get _color {
    switch (notification.kind) {
      case NotificationKind.newAssignment:
        return AppColors.primary;
      case NotificationKind.newResource:
        return AppColors.secondary;
      case NotificationKind.submissionReceived:
        return AppColors.success;
      case NotificationKind.comment:
        return AppColors.accent;
      case NotificationKind.deadlineReminder:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : AppColors.primary.withOpacity(0.04),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.w400
                          : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grey500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateUtils.relativeTime(notification.createdAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.grey400),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
