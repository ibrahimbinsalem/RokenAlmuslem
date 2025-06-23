import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationType {
  morningAdhkar,
  eveningAdhkar,
  hadith,
  ayah,
  duaa,
  general,
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final Color color;
  bool isRead;
  final NotificationType type;
  final int notificationId;
  final String? payload;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    required this.type,
    required this.notificationId,
    this.isRead = false,
    this.payload,
  });

  NotificationItem copyWith({
    bool? isRead,
    String? title,
    String? message,
    DateTime? time,
  }) {
    return NotificationItem(
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      icon: icon,
      color: color,
      type: type,
      notificationId: notificationId,
      isRead: isRead ?? this.isRead,
      payload: payload,
    );
  }

  factory NotificationItem.fromPendingRequest(
    PendingNotificationRequest request, {
    required NotificationType type,
    required IconData icon,
    required Color color,
  }) {
    return NotificationItem(
      title: request.title ?? "إشعار",
      message: request.body ?? "لا يوجد محتوى",
      time: DateTime.now(),
      icon: icon,
      color: color,
      type: type,
      notificationId: request.id,
      payload: request.payload,
    );
  }
}