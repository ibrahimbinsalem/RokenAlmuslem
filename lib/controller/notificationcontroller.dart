import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart'; // استيراد AppSettingsController
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart'; // استيراد PrayerTimesController
import 'package:rokenalmuslem/core/services/api_service.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart'
    hide
        NotificationType; // تأكد من 'hide NotificationType' لتجنب التضارب إذا كان موجودًا

import 'package:url_launcher/url_launcher.dart';
import 'package:rokenalmuslem/core/services/services.dart';
import 'notification_item.dart'; // تأكد من أن هذا الملف موجود وبه تعريف NotificationItem
import 'dart:convert'; // لاستخدام json.decode

class NotificationsController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  List<NotificationItem> _remoteNotificationsCache = [];

  // حقن متحكمات التبعية
  final NotificationService _notificationService;
  final ApiService _apiService = ApiService();
  final MyServices _myServices = Get.find<MyServices>();
  late AppSettingsController _appSettingsController;
  late PrayerTimesController
  _prayerTimesController; // إضافة PrayerTimesController
  final Set<int> _dismissedRemoteIds = {};

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
    _loadDismissedRemoteIds();
    await _checkForPendingUpdateNotification();
    await refreshNotifications();
  }

  void _loadDismissedRemoteIds() {
    final stored = _myServices.sharedprf.getStringList(
      "dismissed_remote_notifications",
    );
    if (stored != null) {
      _dismissedRemoteIds
        ..clear()
        ..addAll(
          stored.map((item) => int.tryParse(item)).whereType<int>(),
        );
    }
  }

  void _saveDismissedRemoteIds() {
    _myServices.sharedprf.setStringList(
      "dismissed_remote_notifications",
      _dismissedRemoteIds.map((id) => id.toString()).toList(),
    );
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
      await _fetchNotifications(isRefresh: true);
    } catch (e) {
      _handleError(e);
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

    final remoteNotifications = await _fetchRemoteNotifications(
      forceRefresh: isRefresh,
    );

    final allNotifications = [
      ...remoteNotifications,
      ...filteredNotifications,
    ];

    // فرز الإشعارات حسب الوقت (الأحدث أولاً)
    allNotifications.sort((a, b) => b.time.compareTo(a.time));
    notifications.assignAll(allNotifications);
  }

  Future<List<NotificationItem>> _fetchRemoteNotifications({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _remoteNotificationsCache.isNotEmpty) {
      return _remoteNotificationsCache;
    }

    final authToken = _myServices.sharedprf.getString("token");
    if (authToken == null || authToken.isEmpty) {
      _remoteNotificationsCache = [];
      return _remoteNotificationsCache;
    }

    try {
      final items = await _apiService.fetchNotifications(
        authToken: authToken,
      );
      _remoteNotificationsCache = items.map((item) {
        final rawId = item['notification_id'];
        final id = rawId is int ? rawId : int.tryParse("$rawId") ?? 0;
        final createdAt = item['created_at'];
        final parsedTime =
            createdAt is String ? DateTime.tryParse(createdAt) : null;
        final isRead = item['is_read'] == true || item['is_read'] == 1;
        final url = item['notification_url']?.toString();
        final route = item['notification_route']?.toString();
        final type = NotificationType.general;

        return NotificationItem(
          id: id + 1000000,
          remoteId: id,
          title: item['notification_title']?.toString() ?? 'إشعار',
          message: item['notification_body']?.toString() ?? '',
          time: parsedTime ?? DateTime.now(),
          isRead: isRead,
          type: type,
          icon: _getIconForType(type),
          color: _getColorForType(type),
          payload: url,
          actionType: route != null && route.isNotEmpty ? 'route' : 'url',
          actionValue: route != null && route.isNotEmpty ? route : url,
        );
      }).where((notification) {
        return !_dismissedRemoteIds.contains(notification.remoteId);
      }).toList();
    } catch (e) {
      debugPrint('Failed to fetch remote notifications: $e');
    }

    return _remoteNotificationsCache;
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
      title: "تمييز الكل كمقروء",
      message: "هل تريد تمييز جميع الإشعارات كمقروءة؟",
      confirmText: "تأكيد",
      confirmColor: Colors.teal,
      cancelText: "تراجع",
    );

    if (!confirmed) return;

    try {
      isLoading.value = true;
      final authToken = _myServices.sharedprf.getString("token");
      if (authToken != null) {
        final remoteUnread = notifications.where(
          (item) => item.isRemote && !item.isRead && item.remoteId != null,
        );
        for (final item in remoteUnread) {
          try {
            await _apiService.markNotificationRead(
              authToken: authToken,
              notificationId: item.remoteId!,
            );
            _remoteNotificationsCache.removeWhere(
              (cached) => cached.remoteId == item.remoteId,
            );
          } catch (e) {
            debugPrint('Failed to mark notification read: $e');
          }
        }
      }

      final updated = notifications
          .map((item) => item.copyWith(isRead: true))
          .toList();
      notifications.assignAll(updated);

      Get.snackbar(
        "تم التحديث",
        "تم تمييز جميع الإشعارات كمقروءة",
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

  Future<void> markAsRead(NotificationItem notificationItem) async {
    final index = notifications.indexWhere((item) {
      if (notificationItem.remoteId != null) {
        return item.remoteId == notificationItem.remoteId;
      }
      return item.id == notificationItem.id;
    });
    if (index == -1) {
      return;
    }

    if (notificationItem.isRemote && notificationItem.remoteId != null) {
      final authToken = _myServices.sharedprf.getString("token");
      if (authToken != null) {
        try {
          await _apiService.markNotificationRead(
            authToken: authToken,
            notificationId: notificationItem.remoteId!,
          );
          _remoteNotificationsCache.removeWhere(
            (item) => item.remoteId == notificationItem.remoteId,
          );
        } catch (e) {
          debugPrint('Failed to mark remote notification read: $e');
        }
      }
    }

    notifications[index] = notifications[index].copyWith(isRead: true);
    notifications.refresh();
  }

  Future<void> dismissNotification(NotificationItem notificationItem) async {
    notifications.removeWhere((item) {
      if (notificationItem.remoteId != null) {
        return item.remoteId == notificationItem.remoteId;
      }
      return item.id == notificationItem.id;
    });
    notifications.refresh();

    if (notificationItem.isRemote && notificationItem.remoteId != null) {
      _dismissedRemoteIds.add(notificationItem.remoteId!);
      _saveDismissedRemoteIds();
      final authToken = _myServices.sharedprf.getString("token");
      if (authToken != null) {
        try {
          await _apiService.deleteNotification(
            authToken: authToken,
            notificationId: notificationItem.remoteId!,
          );
          _remoteNotificationsCache.removeWhere(
            (item) => item.remoteId == notificationItem.remoteId,
          );
        } catch (e) {
          debugPrint('Failed to delete remote notification: $e');
        }
      }
    } else {
      await _notificationService.cancelNotification(notificationItem.id);
    }
  }

  Future<void> handleNotificationTap(NotificationItem notification) async {
    // التعامل الخاص مع إشعار التحديث
    if (notification.type == NotificationType.update &&
        notification.payload != null) {
      final uri = Uri.parse(notification.payload!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return; // الخروج من الدالة بعد فتح الرابط
    }

    if (notification.actionType == 'route' &&
        notification.actionValue != null) {
      if (_isAllowedRoute(notification.actionValue!)) {
        Get.toNamed(notification.actionValue!);
        await markAsRead(notification);
        return;
      }
    }

    final urlCandidate =
        notification.actionType == 'url'
            ? notification.actionValue
            : notification.payload;
    final url = _normalizeUrl(urlCandidate);
    if (url != null) {
      await _launchUrlSafely(url);
      await markAsRead(notification);
      return;
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
    await markAsRead(notification);
  }

  Uri? _normalizeUrl(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final withScheme = trimmed.startsWith('http://') ||
            trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(withScheme);
    if (uri == null) {
      return null;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }
    return uri;
  }

  Future<void> _launchUrlSafely(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('Failed to launch URL: $uri');
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $e');
    }
  }

  bool _isAllowedRoute(String value) {
    const allowed = {
      '/homepage',
      '/stories',
      '/prophetStories',
      '/setting',
      '/quran',
      '/msbaha',
      '/about',
    };
    return allowed.contains(value);
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
