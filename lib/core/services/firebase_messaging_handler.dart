import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/notificationcontroller.dart';
import 'package:rokenalmuslem/core/services/api_service.dart';
import 'package:rokenalmuslem/core/services/services.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// A background message handler for Firebase Cloud Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This function must be a top-level function.
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(); // Required for Firebase services

  print("Handling a background message: ${message.messageId}");
  // **الإصلاح**: لا نستخدم GetX هنا، نقوم بالحفظ مباشرة في SharedPreferences
  if (message.data['type'] == 'app_update') {
    final updateUrl = message.data['update_url'];
    if (updateUrl != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_update_url', updateUrl);
      print('Saved pending update URL to SharedPreferences.');
    }
  }
}

class FirebaseMessagingHandler {
  final NotificationService _localNotificationService =
      Get.find<NotificationService>();

  Future<void> initialize() async {
    // Handle messages when the app is in the foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      final notification = message.notification;
      final title = notification?.title ?? message.data['title']?.toString();
      final body = notification?.body ?? message.data['body']?.toString();

      if (_handleUpdateNotification(message)) {
        return;
      }

      if ((title ?? '').isNotEmpty || (body ?? '').isNotEmpty) {
        _localNotificationService.showNotification(
          title: title ?? 'إشعار جديد',
          body: body ?? '',
          payload: json.encode(message.data),
        );
      }

      if (Get.isRegistered<NotificationsController>()) {
        Get.find<NotificationsController>().refreshNotifications();
      }
    });

    // Handle when the user taps a notification and the app opens from a terminated state.
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        print("App opened from terminated state by notification.");
        _handleTappedNotification(message); // **الإصلاح**: التعامل مع النقرة
      }
    });

    // Handle when the user taps a notification and the app opens from a background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App opened from background state by notification.");
      _handleTappedNotification(message); // **الإصلاح**: التعامل مع النقرة
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
      final myServices = Get.find<MyServices>();
      final authToken = myServices.sharedprf.getString("token");
      if (authToken == null) {
        return;
      }
      try {
        final platform = Platform.isIOS ? 'ios' : 'android';
        await ApiService().sendDeviceToken(
          authToken: authToken,
          deviceToken: token,
          platform: platform,
        );
      } catch (e) {
        print("Device token refresh registration failed: $e");
      }
    });
  }
}

/// Private helper function to process update notifications.
/// Returns true if the message was an update notification, false otherwise.
bool _handleUpdateNotification(RemoteMessage message) {
  // Assuming the server sends a 'type' field in the data payload.
  if (message.data['type'] == 'app_update') {
    final updateUrl = message.data['update_url'];
    if (updateUrl != null) {
      // When the app is in the foreground, we can directly access the controller.
      final controller = Get.find<NotificationsController>();
      controller.addUpdateNotification(updateUrl);
    }
    return true;
  }
  return false;
}

/// Private helper function to handle a TAPPED notification.
/// This will open the URL directly if it's an update notification.
void _handleTappedNotification(RemoteMessage message) {
  // Check if it's an update notification
  if (message.data['type'] == 'app_update') {
    final updateUrl = message.data['update_url'];
    if (updateUrl != null) {
      print('Update notification tapped. Launching URL: $updateUrl');
      final uri = Uri.parse(updateUrl);
      // We don't need to check canLaunchUrl, as launchUrl does it.
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return;
  }
  final route = message.data['route'];
  if (route is String && route.trim().isNotEmpty) {
    Get.toNamed(route);
    return;
  }
  final url = message.data['url'];
  if (url is String && url.trim().isNotEmpty) {
    final trimmed = url.trim();
    final withScheme = trimmed.startsWith('http://') ||
            trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(withScheme);
    if (uri != null) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  // For other notification types, you can add navigation logic here.
  // e.g., if (message.data['type'] == 'offer') { Get.toNamed('/offers'); }
}
