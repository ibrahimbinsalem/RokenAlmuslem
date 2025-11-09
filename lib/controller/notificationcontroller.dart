import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart'; // استيراد AppSettingsController
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart'; // استيراد PrayerTimesController
import 'package:rokenalmuslem/core/services/localnotification.dart'
    hide
        NotificationType; // تأكد من 'hide NotificationType' لتجنب التضارب إذا كان موجودًا

import 'package:url_launcher/url_launcher.dart';
import 'notification_item.dart'; // تأكد من أن هذا الملف موجود وبه تعريف NotificationItem
import 'dart:convert'; // لاستخدام json.decode

class NotificationsController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;

  final int _notificationsPerPage = 20; // عدد الإشعارات لكل صفحة
  int _currentPage = 0; // الصفحة الحالية للتحميل اللانهائي

  // حقن متحكمات التبعية
  final NotificationService _notificationService;
  late AppSettingsController _appSettingsController;
  late PrayerTimesController
  _prayerTimesController; // إضافة PrayerTimesController

  // Constructor مع حقن التبعيات
  NotificationsController({NotificationService? notificationService})
    : _notificationService =
          notificationService ?? Get.find<NotificationService>();

  @override
  void onInit() {
    super.onInit();
    // يجب العثور على المتحكمات بعد تهيئتها في main.dart
    _appSettingsController = Get.find<AppSettingsController>();
    _prayerTimesController =
        Get.find<PrayerTimesController>(); // حقن PrayerTimesController
    // **الإصلاح**: ضمان تنفيذ العمليات بالترتيب الصحيح لتجنب السباق الزمني
    // أولاً، تحقق من وجود إشعار تحديث معلق، ثم قم بتحديث بقية الإشعارات.
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _checkForPendingUpdateNotification();
    await refreshNotifications();
  }

  /// Checks SharedPreferences for a pending update URL and adds it as a notification.
  Future<void> _checkForPendingUpdateNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final updateUrl = prefs.getString('pending_update_url');
    if (updateUrl != null) {
      addUpdateNotification(updateUrl);
      // Remove the key so it's not shown again on next app start.
      await prefs.remove('pending_update_url');
    }
  }

  /// Adds a special update notification to the top of the list.
  void addUpdateNotification(String updateUrl) {
    // إنشاء إشعار تحديث مخصص
    final updateNotification = NotificationItem(
      id: -1, // استخدام ID فريد وسالب لتمييزه
      title: 'تحديث جديد متوفر!',
      message: 'يتوفر إصدار جديد من التطبيق. اضغط هنا للتحديث.',
      time: DateTime.now(),
      isRead: false,
      type: NotificationType.update, // نوع جديد للإشعار
      icon: Icons.system_update_alt,
      color: Colors.teal,
      payload: updateUrl, // تخزين رابط التحديث في الـ payload
    );

    // إزالة أي إشعار تحديث قديم لتجنب التكرار
    notifications.removeWhere((item) => item.type == NotificationType.update);

    // إضافة الإشعار الجديد في بداية القائمة
    notifications.insert(0, updateNotification);
    Get.snackbar('تحديث متوفر', 'إصدار جديد من التطبيق متاح الآن!');
  }

  // هذه الدالة الآن ستقوم بطلب إعادة جدولة الإشعارات من المتحكمات المسؤولة
  // ثم تجلب القائمة المحدثة
  Future<void> refreshNotifications() async {
    if (notifications.isEmpty)
      isLoading.value = true; // أظهر التحميل فقط إذا كانت القائمة فارغة
    errorMessage.value = '';
    // **الإصلاح**: لا تقم بمسح القائمة هنا، لأن إشعار التحديث قد يكون موجودًا بالفعل
    _currentPage = 0; // إعادة تعيين الصفحة عند التحديث
    hasMore.value = true; // إعادة تعيين حالة التحميل اللانهائي

    try {
      // 1. اطلب من AppSettingsController إعادة مزامنة إشعارات الأذكار
      // هذا سيلغي القديم ويجدول الجديد بناءً على إعدادات المستخدم.
      // بما أن _syncNotificationsState في AppSettingsController أصبحت مسؤولة عن كل الجدولة/الإلغاء
      // بناءً على حالة المفاتيح، فإن استدعاء loadSettings() سيتولى المزامنة.
      await _appSettingsController.loadSettings();

      // لا حاجة لاستدعاء _prayerTimesController.fetchPrayerTimes() هنا بشكل منفصل لجدولة الإشعارات،
      // لأن _appSettingsController.syncNotificationsState() ستفعل ذلك إذا كان مفتاح الصلاة مفعلاً.
      // وظيفة fetchPrayerTimes() في PrayerTimesController هي فقط جلب البيانات.

      // 2. بعد إعادة الجدولة (التي حدثت بفضل loadSettings/syncNotificationsState)،
      // قم بجلب قائمة الإشعارات المعلقة لعرضها
      await _fetchNotifications(isRefresh: true);
    } catch (e, stack) {
      errorMessage.value = 'خطأ في تحديث الإشعارات: $e';
      debugPrint('Error refreshing notifications: $e\n$stack');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadInitialNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      notifications.clear(); // تأكيد المسح حتى عند التحميل الأولي
      _currentPage = 0;
      hasMore.value = true;
      await _fetchNotifications(isRefresh: true);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    if (!hasMore.value || isLoading.value) return;

    try {
      isLoading.value = true;
      _currentPage++; // زيادة رقم الصفحة
      await _fetchNotifications(isRefresh: false); // أضف كمعامل
    } catch (e) {
      _handleError(e);
      _currentPage--; // التراجع عن رقم الصفحة في حالة الخطأ
    } finally {
      isLoading.value = false;
    }
  }

  // دالة لجلب الإشعارات المعلقة من FlutterLocalNotificationsPlugin
  Future<void> _fetchNotifications({bool isRefresh = false}) async {
    final pendingRequests =
        await _notificationService.getPendingNotifications();

    // تصفية الإشعارات بناءً على حالة التفعيل في AppSettingsController
    final List<NotificationItem> filteredNotifications = [];

    // جلب جميع إعدادات التفعيل من AppSettingsController
    final bool globalNotificationsEnabled =
        _appSettingsController.notificationsEnabled.value;
    final bool prayerTimesNotificationsEnabled =
        _appSettingsController.prayerTimesNotificationsEnabled.value;
    final bool generalDailyAzkarEnabled =
        _appSettingsController.generalDailyAzkarEnabled.value;
    final bool morningAzkarReminderEnabled =
        _appSettingsController.morningAzkarReminderEnabled.value;
    final bool eveningAzkarReminderEnabled =
        _appSettingsController.eveningAzkarReminderEnabled.value;
    final bool sleepAzkarReminderEnabled =
        _appSettingsController.sleepAzkarReminderEnabled.value;
    final bool tasbeehReminderEnabled =
        _appSettingsController.tasbeehReminderEnabled.value;
    final bool weeklyFridayReminderEnabled =
        _appSettingsController.weeklyFridayReminderEnabled.value;

    for (var request in pendingRequests) {
      DateTime timeToDisplay = DateTime.now(); // قيمة افتراضية
      String notificationTypeString = 'general';
      String? prayerNameFromPayload;

      try {
        if (request.payload != null && request.payload!.startsWith('{')) {
          final Map<String, dynamic> payloadData = json.decode(
            request.payload!,
          );
          if (payloadData.containsKey('scheduledTime') &&
              payloadData['scheduledTime'] is String) {
            timeToDisplay =
                DateTime.tryParse(payloadData['scheduledTime']) ??
                DateTime.now();
          }
          if (payloadData.containsKey('type') &&
              payloadData['type'] is String) {
            notificationTypeString = payloadData['type'];
          }
          if (payloadData.containsKey('prayerName') &&
              payloadData['prayerName'] is String) {
            prayerNameFromPayload = payloadData['prayerName'];
          }
        }
      } catch (e) {
        debugPrint('Error parsing scheduledTime or type from payload: $e');
      }

      NotificationType type = _determineNotificationType(
        notificationTypeString,
        request.title ?? '',
        prayerNameFromPayload,
      );

      // **فلترة الإشعارات هنا بناءً على الإعدادات**
      bool shouldAdd = false;
      if (globalNotificationsEnabled) {
        switch (type) {
          case NotificationType.prayerFajr:
          case NotificationType.prayerSunrise:
          case NotificationType.prayerDhuhr:
          case NotificationType.prayerAsr:
          case NotificationType.prayerMaghrib:
          case NotificationType.prayerIsha:
            shouldAdd = prayerTimesNotificationsEnabled;
            break;
          case NotificationType.generalDailyAzkar:
            shouldAdd = generalDailyAzkarEnabled;
            break;
          case NotificationType.morningAdhkar:
            shouldAdd = morningAzkarReminderEnabled;
            break;
          case NotificationType.eveningAdhkar:
            shouldAdd = eveningAzkarReminderEnabled;
            break;
          case NotificationType.sleepAdhkar:
            shouldAdd = sleepAzkarReminderEnabled;
            break;
          case NotificationType.tasbeeh:
            shouldAdd = tasbeehReminderEnabled;
            break;
          case NotificationType.fridayReminder:
            shouldAdd = weeklyFridayReminderEnabled;
            break;
          default:
            // إذا كان نوعًا عامًا أو غير معروف، نعتمد على المفتاح العام أو نضيفه إذا لم يتم تصفيته بشكل خاص
            shouldAdd = true;
            break;
        }
      }

      if (shouldAdd) {
        filteredNotifications.add(
          NotificationItem(
            id: request.id,
            title: request.title ?? 'تذكير',
            message: request.body ?? 'لا يوجد وصف',
            time: timeToDisplay, // **الوقت المجدول الفعلي**
            isRead: false,
            type: type,
            icon: _getIconForType(type),
            color: _getColorForType(type),
          ),
        );
      }
    }

    // فرز الإشعارات حسب الوقت (الأحدث أولاً)
    filteredNotifications.sort((a, b) => b.time.compareTo(a.time));

    final startIndex = _currentPage * _notificationsPerPage;

    // إذا لم يكن هناك شيء لإضافته بعد التصفية، قم بتحديث الحالة
    if (startIndex >= filteredNotifications.length) {
      hasMore.value = false;
      if (isRefresh) {
        // عند التحديث، احتفظ بإشعار التحديث إذا كان موجودًا
        notifications.removeWhere(
          (item) => item.type != NotificationType.update,
        );
      }
      return;
    }

    final endIndex = startIndex + _notificationsPerPage;
    final newPage = filteredNotifications.sublist(
      startIndex,
      endIndex.clamp(0, filteredNotifications.length),
    );

    if (isRefresh) {
      // عند التحديث، احتفظ بإشعار التحديث وأضف الإشعارات الجديدة
      final updateItem = notifications.firstWhereOrNull(
        (item) => item.type == NotificationType.update,
      );
      notifications.clear();
      if (updateItem != null) notifications.add(updateItem);
      notifications.addAll(newPage);
    } else {
      notifications.addAll(newPage); // إضافة المزيد عند التمرير
    }

    hasMore.value = endIndex < filteredNotifications.length;
  }

  // تحديد نوع الإشعار بناءً على الـ payload (والعنوان كخيار احتياطي)
  NotificationType _determineNotificationType(
    String payloadType,
    String title,
    String? prayerNameFromPayload,
  ) {
    // الاعتماد على payloadType أولاً
    if (payloadType == 'generalDailyAzkar')
      return NotificationType.generalDailyAzkar;
    if (payloadType == 'morningAzkar') return NotificationType.morningAdhkar;
    if (payloadType == 'eveningAzkar') return NotificationType.eveningAdhkar;
    if (payloadType == 'sleepAzkar') return NotificationType.sleepAdhkar;
    if (payloadType == 'tasbeeh') return NotificationType.tasbeeh;
    if (payloadType == 'fridayReminder') return NotificationType.fridayReminder;

    // لأوقات الصلاة، بناءً على prayerNameFromPayload أو العنوان
    if (payloadType == 'prayerTime' && prayerNameFromPayload != null) {
      switch (prayerNameFromPayload) {
        case 'الفجر':
          return NotificationType.prayerFajr;
        case 'الشروق':
          return NotificationType.prayerSunrise;
        case 'الظهر':
          return NotificationType.prayerDhuhr;
        case 'العصر':
          return NotificationType.prayerAsr;
        case 'المغرب':
          return NotificationType.prayerMaghrib;
        case 'العشاء':
          return NotificationType.prayerIsha;
      }
    }

    // كخيار احتياطي إذا لم يتطابق الـ payloadType بشكل داطع
    if (title.contains('تذكير أذكار عام'))
      return NotificationType.generalDailyAzkar;
    if (title.contains('أذكار الصباح')) return NotificationType.morningAdhkar;
    if (title.contains('أذكار المساء')) return NotificationType.eveningAdhkar;
    if (title.contains('أذكار النوم')) return NotificationType.sleepAdhkar;
    if (title.contains('تذكير تسبيح')) return NotificationType.tasbeeh;
    if (title.contains('تذكير الجمعة')) return NotificationType.fridayReminder;

    if (title.contains('صلاة الفجر')) return NotificationType.prayerFajr;
    if (title.contains('صلاة الشروق'))
      return NotificationType.prayerSunrise; // غالباً ما يكون الشروق وليس صلاة
    if (title.contains('صلاة الظهر')) return NotificationType.prayerDhuhr;
    if (title.contains('صلاة العصر')) return NotificationType.prayerAsr;
    if (title.contains('صلاة المغرب')) return NotificationType.prayerMaghrib;
    if (title.contains('صلاة العشاء')) return NotificationType.prayerIsha;

    return NotificationType.general;
  }

  // الحصول على الأيقونة بناءً على نوع الإشعار
  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.morningAdhkar:
        return Icons.wb_sunny_outlined;
      case NotificationType.eveningAdhkar:
        return Icons.nights_stay_outlined;
      case NotificationType.prayerFajr:
        return Icons.brightness_2_outlined; // أيقونة الفجر
      case NotificationType.prayerSunrise:
        return Icons.wb_sunny_outlined; // أيقونة الشروق
      case NotificationType.prayerDhuhr:
        return Icons.wb_sunny_sharp; // أيقونة الظهيرة
      case NotificationType.prayerAsr:
        return Icons.wb_cloudy_outlined; // أيقونة العصر
      case NotificationType.prayerMaghrib:
        return Icons.brightness_3_outlined; // أيقونة المغرب
      case NotificationType.prayerIsha:
        return Icons.nights_stay; // أيقونة العشاء
      case NotificationType.tasbeeh:
        return Icons.bubble_chart;
      case NotificationType.sleepAdhkar:
        return Icons.bedtime;
      case NotificationType.fridayReminder:
        return Icons.mosque_outlined;
      case NotificationType.hadith:
        return Icons.format_quote_outlined;
      case NotificationType.ayah:
        return Icons.book_outlined;
      case NotificationType.duaa:
        return Icons.emoji_people_outlined;
      case NotificationType.generalDailyAzkar:
        return Icons.notifications_active_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  // الحصول على اللون بناءً على نوع الإشعار
  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.morningAdhkar:
        return const Color(0xFFF9A825); // أصفر ذهبي
      case NotificationType.eveningAdhkar:
        return const Color(0xFF5C6BC0); // بنفسجي فاتح
      case NotificationType.prayerFajr:
        return Colors.orange.shade800;
      case NotificationType.prayerSunrise:
        return Colors.amber.shade700;
      case NotificationType.prayerDhuhr:
        return Colors.blue.shade600;
      case NotificationType.prayerAsr:
        return Colors.deepOrange.shade400;
      case NotificationType.prayerMaghrib:
        return Colors.purple.shade700;
      case NotificationType.prayerIsha:
        return Colors.indigo.shade800;
      case NotificationType.tasbeeh:
        return Colors.green.shade600;
      case NotificationType.sleepAdhkar:
        return Colors.blueGrey.shade600;
      case NotificationType.fridayReminder:
        return Colors.teal.shade700;
      case NotificationType.hadith:
        return const Color(0xFF43A047); // أخضر داكن
      case NotificationType.ayah:
        return const Color(0xFF00897B); // تركواز
      case NotificationType.duaa:
        return const Color(0xFF7B1FA2); // بنفسجي عميق
      case NotificationType.generalDailyAzkar:
        return Colors.lime.shade700;
      default:
        return Colors.grey;
    }
  }

  Future<void> clearAllNotifications() async {
    final confirmed = await _showConfirmationDialog(
      title: "حذف الإشعارات",
      message: "هل أنت متأكد من رغبتك في حذف جميع الإشعارات المجدولة؟",
      confirmText: "حذف",
      confirmColor: Colors.red,
      cancelText: "تراجع",
    );

    if (!confirmed) return;

    try {
      isLoading.value = true;
      // إلغاء جميع الإشعارات المجدولة في نظام التشغيل
      await _notificationService.cancelAllNotifications();
      notifications.clear(); // مسح القائمة في المتحكم
      hasMore.value = false; // لا يوجد المزيد من الإشعارات
      // تحديث الواجهة لإظهار رسالة "لا توجد إشعارات"
      // هذا السطر مهم لـ GetX ليعرف أن القائمة قد تغيرت بشكل جذري
      notifications.refresh();

      Get.snackbar(
        "تم الحذف",
        "تم حذف جميع الإشعارات المجدولة بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int index) async {
    if (index >= 0 && index < notifications.length) {
      final notificationItem = notifications[index];
      // 1. إلغاء الإشعار من النظام لأنه تم التعامل معه
      await _notificationService.cancelNotification(notificationItem.id);

      // 2. إزالة الإشعار من القائمة المعروضة في الواجهة
      notifications.removeAt(index);

      // 3. تحديث الواجهة
      notifications.refresh();

      Get.snackbar(
        "تمت المعالجة",
        "تمت معالجة الإشعار: ${notificationItem.title}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> handleNotificationTap(int index) async {
    final notification = notifications[index];

    // التعامل الخاص مع إشعار التحديث
    if (notification.type == NotificationType.update &&
        notification.payload != null) {
      final uri = Uri.parse(notification.payload!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return; // الخروج من الدالة بعد فتح الرابط
    }

    switch (notification.type) {
      case NotificationType.morningAdhkar:
        Get.toNamed('/morning-adhkar-page');
        break;
      case NotificationType.eveningAdhkar:
        Get.toNamed('/evening-adhkar-page');
        break;
      case NotificationType.prayerFajr:
      case NotificationType.prayerSunrise:
      case NotificationType.prayerDhuhr:
      case NotificationType.prayerAsr:
      case NotificationType.prayerMaghrib:
      case NotificationType.prayerIsha:
        Get.toNamed('/prayer-times-page');
        break;
      case NotificationType.tasbeeh:
        Get.toNamed('/tasbeeh-page');
        break;
      case NotificationType.sleepAdhkar:
        Get.toNamed('/sleep-adhkar-page');
        break;
      case NotificationType.fridayReminder:
        Get.toNamed('/friday-page');
        break;
      case NotificationType.hadith:
      case NotificationType.ayah:
      case NotificationType.duaa:
      case NotificationType.general:
      case NotificationType.generalDailyAzkar: // أضف هذا
      default:
        debugPrint(
          'Notification tapped: ${notification.title} with payload: ${notification.id}',
        );
        Get.snackbar(
          notification.title,
          notification.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blueAccent.withOpacity(0.9),
          colorText: Colors.white,
          icon: Icon(notification.icon, color: Colors.white),
          duration: const Duration(seconds: 5),
        );
    }
    // بعد التعامل مع الإشعار، قم بإزالته من القائمة والنظام
    await markAsRead(index);
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final notificationDate = DateTime(time.year, time.month, time.day);

    final timeFormat = DateFormat(
      'hh:mm a',
      'ar',
    ); // تنسيق الوقت (e.g., 08:00 صباحًا)

    if (notificationDate == today) {
      return 'اليوم, ${timeFormat.format(time)}';
    } else if (notificationDate == tomorrow) {
      return 'غداً, ${timeFormat.format(time)}';
    } else {
      // إذا كان التاريخ في الماضي أو المستقبل البعيد، اعرض التاريخ الكامل
      final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
      return '${dateFormat.format(time)}, ${timeFormat.format(time)}';
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = "حذف",
    Color confirmColor = Colors.red,
    String cancelText = "تراجع",
  }) async {
    return (await Get.dialog<bool>(
          AlertDialog(
            title: Text(title, style: Get.textTheme.titleLarge),
            content: Text(message, style: Get.textTheme.bodyLarge),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  cancelText,
                  style: TextStyle(color: Get.theme.primaryColor),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(confirmText, style: TextStyle(color: confirmColor)),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _handleError(dynamic error) {
    errorMessage.value = error.toString();
    Get.snackbar(
      "خطأ",
      "حدث خطأ: ${error.toString()}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
