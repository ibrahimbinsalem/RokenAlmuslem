import 'dart:convert'; // لإضافة json.decode
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart'; // لإضافة debugPrint

// تحديد أنواع الإشعارات
enum NotificationType {
  general,
  morningAdhkar,
  eveningAdhkar,
  hadith,
  ayah,
  duaa,
  // أنواع إشعارات أوقات الصلاة
  prayerFajr,
  prayerSunrise,
  prayerDhuhr,
  prayerAsr,
  prayerMaghrib,
  prayerIsha,
  // أنواع إشعارات التذكير الأخرى
  tasbeeh,
  sleepAdhkar,
  fridayReminder, generalDailyAzkar,
}

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final DateTime time; // هذا هو الوقت الذي سيتم عرضه (وقت الجدولة)
  bool isRead;
  final NotificationType type;
  final IconData icon;
  final Color color;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    this.type = NotificationType.general,
    this.icon = Icons.notifications,
    this.color = Colors.blue,
  });

  // Constructor لإنشاء NotificationItem من PendingNotificationRequest
  factory NotificationItem.fromPendingRequest(
      PendingNotificationRequest request, {
      NotificationType type = NotificationType.general,
      IconData icon = Icons.notifications,
      Color color = Colors.blue,
  }) {
    // حاول استخراج وقت الجدولة من الـ payload
    DateTime? scheduledTime;
    try {
      if (request.payload != null && request.payload!.startsWith('{')) {
        // إذا كان payload هو JSON
        final Map<String, dynamic> payloadData = json.decode(request.payload!);
        if (payloadData.containsKey('scheduledTime') && payloadData['scheduledTime'] is String) {
          scheduledTime = DateTime.tryParse(payloadData['scheduledTime']);
        }
      } else if (request.payload != null && request.payload!.contains('scheduled_at=')) {
        // إذا كان payload يحتوي على سلسلة "scheduled_at=" (نمط آخر)
        final uri = Uri.parse('http://temp.com/?' + request.payload!); // فقط لتحليل الكويري بارامترز
        final timeString = uri.queryParameters['scheduled_at'];
        if (timeString != null) {
          scheduledTime = DateTime.tryParse(timeString);
        }
      }
    } catch (e) {
      debugPrint('Error parsing notification payload for time: $e');
    }

    // إذا لم يتم العثور على وقت مجدول، استخدم الوقت الحالي (ليس مثاليًا لكنه يمنع الخطأ)
    // الأفضل هو أن يتم إرسال الوقت المجدول في الـ payload من دالة الجدولة نفسها
    // (مثال: 'payload': json.encode({'scheduledTime': scheduledDate.toIso8601String(), 'type': 'morningAzkar'}))
    scheduledTime ??= DateTime.now();


    return NotificationItem(
      id: request.id,
      title: request.title ?? 'تذكير',
      message: request.body ?? 'بدون محتوى',
      time: scheduledTime,
      isRead: false, // افتراضياً غير مقروء عند الجلب
      type: type,
      icon: icon,
      color: color,
    );
  }

  NotificationItem copyWith({
    int? id,
    String? title,
    String? message,
    DateTime? time,
    bool? isRead,
    NotificationType? type,
    IconData? icon,
    Color? color,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}
