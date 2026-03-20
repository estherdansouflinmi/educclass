// lib/core/utils/date_utils.dart
import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy à HH:mm');
  static final _timeFormat = DateFormat('HH:mm');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return formatDate(date);
  }

  static String deadlineLabel(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.isNegative) return 'Dépassée';
    if (diff.inHours < 24) return 'Expire dans ${diff.inHours}h';
    if (diff.inDays < 2) return 'Expire demain';
    return 'Avant le ${formatDate(deadline)}';
  }

  static bool isDeadlineSoon(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    return !diff.isNegative && diff.inHours < 24;
  }

  static bool isPast(DateTime date) => date.isBefore(DateTime.now());
}
