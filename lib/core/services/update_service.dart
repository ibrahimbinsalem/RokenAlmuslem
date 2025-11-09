import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // تم تحديث الرابط إلى الـ API الجديد
  final String _checkUrl =
      'https://tasks.arabwaredos.com/rouknalmuslam//setting/check_update.php';

  /// Checks for a new version and shows a mandatory update dialog if available.
  Future<void> checkVersionOnStartup() async {
    try {
      // 1. Get current app version
      // تم استبدال جلب الإصدار الديناميكي بقيمة ثابتة
      const String currentVersion = '1.0.0';

      // 2. Get latest version from API
      final dio = Dio();
      // تم إضافة رقم الإصدار الحالي كـ query parameter للرابط
      final response = await dio.get('$_checkUrl?version=$currentVersion');

      if (response.statusCode == 200) {
        // **الإصلاح**: تحويل الاستجابة النصية إلى خريطة
        final Map<String, dynamic> data;
        if (response.data is String) {
          data = json.decode(response.data);
        } else {
          data = response.data;
        }

        final bool updateAvailable = data['update_available'] ?? false;
        // نفترض أن الـ API يرجع update_url عند وجود تحديث
        final String? updateUrl = data['update_url'] as String?;

        // 3. Check if update is available based on API response
        if (updateAvailable && updateUrl != null) {
          // 4. Show mandatory update dialog
          _showUpdateDialog(updateUrl);
        }
      }
    } catch (e) {
      // If the check fails, we let the user continue.
      // You might want to log this error to your server.
      debugPrint("Update check failed: $e");
    }
  }

  void _showUpdateDialog(String updateUrl) {
    Get.dialog(
      PopScope(
        canPop: false, // يمنع إغلاق النافذة بزر الرجوع
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'تحديث جديد متوفر',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'إصدارك من التطبيق قديم. يرجى التحديث إلى أحدث إصدار للاستمرار.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('تحديث الآن'),
              onPressed: () async {
                final uri = Uri.parse(updateUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
      barrierDismissible: false, // يمنع إغلاق النافذة بالضغط خارجها
    );
  }
}
