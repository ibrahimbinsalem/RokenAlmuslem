import 'package:flutter/material.dart';

enum NotificationType {
  morningAdhkar,
  eveningAdhkar,
  hadith,
  ayah,
  duaa,
  general,
  resetReminder,
  prayerTime,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.morningAdhkar:
        return 'أذكار الصباح';
      case NotificationType.eveningAdhkar:
        return 'أذكار المساء';
      case NotificationType.hadith:
        return 'حديث شريف';
      case NotificationType.ayah:
        return 'آية قرآنية';
      case NotificationType.duaa:
        return 'دعاء';
      case NotificationType.resetReminder:
        return 'تذكير إعادة التعيين';
      case NotificationType.prayerTime:
        return 'مواقيت الصلاة';
      default:
        return 'إشعار عام';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.morningAdhkar:
        return Icons.wb_sunny;
      case NotificationType.eveningAdhkar:
        return Icons.nights_stay;
      case NotificationType.hadith:
        return Icons.format_quote;
      case NotificationType.ayah:
        return Icons.book;
      case NotificationType.duaa:
        return Icons.emoji_people;
      case NotificationType.resetReminder:
        return Icons.refresh;
      case NotificationType.prayerTime:
        return Icons.mosque;
      default:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.morningAdhkar:
        return const Color(0xFFF9A825);
      case NotificationType.eveningAdhkar:
        return const Color(0xFF5C6BC0);
      case NotificationType.hadith:
        return const Color(0xFF43A047);
      case NotificationType.ayah:
        return const Color(0xFF00897B);
      case NotificationType.duaa:
        return const Color(0xFF7B1FA2);
      case NotificationType.resetReminder:
        return const Color(0xFFE53935);
      case NotificationType.prayerTime:
        return const Color(0xFF3949AB);
      default:
        return Colors.grey;
    }
  }
}