// lib/features/notifications/presentation/providers/notification_provider.dart
import 'package:educclass/core/providers/firebase_providers.dart';
import 'package:educclass/features/notifications/data/repositories/notification_repository.dart';
import 'package:educclass/features/notifications/domain/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepository(firestore: ref.watch(firestoreProvider));
});

final notificationsProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  return ref
      .watch(notificationRepositoryProvider)
      .watchNotifications(userId);
});

final unreadCountProvider =
    StreamProvider.family<int, String>((ref, userId) {
  return ref
      .watch(notificationsProvider(userId))
      .when(
        data: (notifs) => Stream.value(
            notifs.where((n) => !n.isRead).length),
        loading: () => Stream.value(0),
        error: (_, __) => Stream.value(0),
      );
});
