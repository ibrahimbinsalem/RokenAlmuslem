import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'dart:convert'; // لإضافة json.encode
import 'package:flutter_timezone/flutter_timezone.dart'; // للحصول على المنطقة الزمنية المحلية

// Days of the week for weekly reminders
enum WeekDay { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

class NotificationService extends GetxService {
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  Future<void> initialize() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true, // تمكين الصوت لـ iOS
        );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);

    tz.initializeTimeZones();
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      print("Local timezone set to: $currentTimeZone");
    } catch (e) {
      print("Could not get local timezone, falling back to Asia/Aden: $e");
      tz.setLocalLocation(tz.getLocation('Asia/Aden'));
    }
  }

  Future<bool> requestPermissions() async {
    final bool? resultAndroid =
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestExactAlarmsPermission();

    final bool? resultIOS = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return (resultAndroid ?? false) || (resultIOS ?? false);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          channelDescription: 'Default notification channel',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload, // يمكن أن يحتوي على نوع الإشعار أو بيانات إضافية
    bool enableVibration = true, // جديد
    bool playSound = true, // جديد
  }) async {
    final scheduledDate = _calculateNextInstanceOfTime(time);

    // تأكد من أن الـ payload هو string يمثل JSON
    String finalPayload = payload ?? '';
    try {
      // إذا كان الـ payload الأصلي هو نص json، أضف إليه
      if (payload != null && payload.startsWith('{')) {
        final Map<String, dynamic> existingPayload = json.decode(payload);
        existingPayload['scheduledTime'] = scheduledDate.toIso8601String();
        existingPayload['notificationId'] = id;
        finalPayload = json.encode(existingPayload);
      } else {
        // إذا لم يكن json، أنشئ payload جديد
        finalPayload = json.encode({
          'scheduledTime':
              scheduledDate
                  .toIso8601String(), // This is key for NotificationsController
          'type':
              payload ?? 'general', // Using payload as type if not specified
          'originalPayload': payload, // Preserve original payload if needed
          'notificationId': id, // Include ID in payload for easier lookup
        });
      }
    } catch (e) {
      print('Error processing payload for daily reminder: $e');
      finalPayload = json.encode({
        'scheduledTime': scheduledDate.toIso8601String(),
        'type': 'general',
        'originalPayload': payload,
        'notificationId': id,
      });
    }

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Daily reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Daily Reminder',
      enableVibration: enableVibration,
      playSound: playSound,
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: finalPayload, // **استخدام الـ payload الجديد مع وقت الجدولة**
    );
    print(
      'Scheduled daily reminder for $title at $scheduledDate with ID: $id and Payload: $finalPayload',
    );
  }

  Future<void> scheduleWeeklyReminder({
    required int id,
    required String title,
    required String body,
    required WeekDay day,
    required TimeOfDay time,
    String? payload,
    bool enableVibration = true,
    bool playSound = true,
  }) async {
    final scheduledDate = _calculateNextInstanceOfDayAndTime(day, time);

    // تأكد من أن الـ payload هو string يمثل JSON
    String finalPayload = payload ?? '';
    try {
      if (payload != null && payload.startsWith('{')) {
        final Map<String, dynamic> existingPayload = json.decode(payload);
        existingPayload['scheduledTime'] = scheduledDate.toIso8601String();
        existingPayload['notificationId'] = id;
        finalPayload = json.encode(existingPayload);
      } else {
        finalPayload = json.encode({
          'scheduledTime': scheduledDate.toIso8601String(),
          'type': payload ?? 'general',
          'originalPayload': payload,
          'notificationId': id,
        });
      }
    } catch (e) {
      print('Error processing payload for weekly reminder: $e');
      finalPayload = json.encode({
        'scheduledTime': scheduledDate.toIso8601String(),
        'type': 'general',
        'originalPayload': payload,
        'notificationId': id,
      });
    }

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'weekly_reminder_channel',
      'Weekly Reminders',
      channelDescription: 'Weekly reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Weekly Reminder',
      enableVibration: enableVibration,
      playSound: playSound,
    );

    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: finalPayload,
    );
    print(
      'Scheduled weekly reminder for $title on ${day.toString()} at $scheduledDate with ID: $id and Payload: $finalPayload',
    );
  }

  tz.TZDateTime _calculateNextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      0, // ثواني
      0, // أجزاء من الثانية
    );

    // **ضمان أن الوقت المجدول في المستقبل (هامش 5 ثواني)**
    // إذا كان الوقت المجدول في نفس اللحظة الحالية (أو الماضي)، اجعله ليوم غد
    if (scheduledDate.isBefore(now.add(const Duration(seconds: 5)))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _calculateNextInstanceOfDayAndTime(
    WeekDay day,
    TimeOfDay time,
  ) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      0, // ثواني
      0, // أجزاء من الثانية
    );

    int targetWeekday = (day.index + 1);
    if (targetWeekday == 7)
      targetWeekday =
          0; // DateTime.weekday uses 1-7, where Sunday is 7. (day.index + 1) % 7 will make Sunday (index 0) = 1, and Saturday (index 6) = 0. Adjusting Sunday to 7 for consistency with DateTime.
    // Simpler check: (day.index + 1) maps WeekDay(0=Sun...6=Sat) to DateTime.weekday (1=Mon...7=Sun)
    // WeekDay.sunday.index=0 => 1 (Mon). Wrong.
    // Let's use `now.weekday` (1=Mon, 7=Sun)
    // WeekDay.sunday.index = 0
    // WeekDay.monday.index = 1
    // ...
    // WeekDay.saturday.index = 6
    // So if today is Monday (1), and target is WeekDay.sunday (0), difference is -1.
    // (targetWeekday - scheduledDate.weekday + 7) % 7
    int daysToAdd = (targetWeekday - scheduledDate.weekday + 7) % 7;
    if (daysToAdd == 0 &&
        scheduledDate.isBefore(now.add(const Duration(seconds: 5)))) {
      daysToAdd =
          7; // If it's today but in the past/very near future, move to next week
    } else if (daysToAdd != 0 &&
        scheduledDate
            .add(Duration(days: daysToAdd))
            .isBefore(now.add(const Duration(seconds: 5)))) {
      // If the calculated future date is still in the past or too close, add 7 more days.
      daysToAdd += 7;
    }

    scheduledDate = scheduledDate.add(Duration(days: daysToAdd));

    // // **ضمان أن الوقت المجدول في المستقبل (هامش 5 ثواني)**
    // if (scheduledDate.isBefore(now.add(const Duration(seconds: 5)))) {
    //   scheduledDate = scheduledDate.add(const Duration(days: 7));
    // }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    print('Cancelled notification with ID: $id');
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print('Cancelled all notifications.');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
