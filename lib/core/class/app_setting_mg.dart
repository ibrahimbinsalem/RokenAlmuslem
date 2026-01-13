import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:rokenalmuslem/core/services/localnotification.dart'; // استيراد NotificationService
import 'package:rokenalmuslem/core/services/api_service.dart';
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart'; // استيراد PrayerTimesController

/// AppSettingsController
/// يدير إعدادات التطبيق باستخدام GetX والمتغيرات الملاحظة (Observables).
/// يستخدم SharedPreferences لتخزين واستعادة الإعدادات بشكل دائم.
class AppSettingsController extends GetxController {
  late SharedPreferences _prefs;
  late NotificationService _notificationService;
  late PrayerTimesController _prayerTimesController;
  final ApiService _apiService = ApiService();
  bool _suppressRemoteSync = false;

  final notificationsEnabled = true.obs;
  final notificationIntervalMinutes = 60.obs;
  final selectedLanguage = 'العربية'.obs;
  final darkModeEnabled = false.obs;
  final fontSizeMultiplier = 1.0.obs;
  final lineHeightMultiplier = 1.9.obs;
  final vibrateOnNotification = true.obs;
  final hideNotificationContent = false.obs;
  final smartMorningAzkarReminderEnabled = true.obs;
  final randomAzkarOrder = true.obs;
  final shortcutsLoaded = false.obs;
  final enabledShortcuts = <String>[].obs;
  final travelModeEnabled = false.obs;
  final smartPrayerUpdatesEnabled = true.obs;

  static const List<String> defaultShortcuts = [
    'asma_allah',
    'tasbeeh',
    'forty_hadith',
  ];

  final generalDailyAzkarEnabled = false.obs;
  final morningAzkarReminderEnabled = false.obs;
  final eveningAzkarReminderEnabled = false.obs;
  final sleepAzkarReminderEnabled = false.obs;
  final tasbeehReminderEnabled = false.obs;
  final weeklyFridayReminderEnabled = false.obs;
  final prayerTimesNotificationsEnabled = false.obs;

  static const int generalDailyAzkarId = 1;
  static const int morningAzkarId = 101;
  static const int eveningAzkarId = 102;
  static const int sleepAzkarId = 301;
  static const int tasbeehReminderId = 104;
  static const int weeklyFridayReminderId = 201;
  static const int smartMorningAzkarId = 901;
  static const int prayerTimesNotificationsStartId = 1000;
  static const int prayerTimesNotificationsEndId = 1005;

  @override
  void onInit() {
    super.onInit();
    _notificationService = Get.find<NotificationService>();
    _prayerTimesController = Get.find<PrayerTimesController>();
    _initAndLoadSettings();
  }

  Future<void> _initAndLoadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    notificationsEnabled.value = _prefs.getBool('notificationsEnabled') ?? true;
    notificationIntervalMinutes.value =
        _prefs.getInt('notificationIntervalMinutes') ?? 60;
    selectedLanguage.value = _prefs.getString('selectedLanguage') ?? 'العربية';
    darkModeEnabled.value = _prefs.getBool('darkModeEnabled') ?? true;
    fontSizeMultiplier.value = _prefs.getDouble('fontSizeMultiplier') ?? 1.0;
    lineHeightMultiplier.value =
        _prefs.getDouble('lineHeightMultiplier') ?? 1.9;
    vibrateOnNotification.value =
        _prefs.getBool('vibrateOnNotification') ?? true;
    hideNotificationContent.value =
        _prefs.getBool('hideNotificationContent') ?? false;
    smartMorningAzkarReminderEnabled.value =
        _prefs.getBool('smartMorningAzkarReminderEnabled') ?? true;
    randomAzkarOrder.value = _prefs.getBool('randomAzkarOrder') ?? true;
    travelModeEnabled.value = _prefs.getBool('travelModeEnabled') ?? false;
    smartPrayerUpdatesEnabled.value =
        _prefs.getBool('smartPrayerUpdatesEnabled') ?? true;
    enabledShortcuts.assignAll(
      _prefs.getStringList('enabledShortcuts') ?? defaultShortcuts,
    );
    shortcutsLoaded.value = true;

    generalDailyAzkarEnabled.value =
        _prefs.getBool('generalDailyAzkarEnabled') ?? false;
    morningAzkarReminderEnabled.value =
        _prefs.getBool('morningAzkarReminderEnabled') ?? false;
    eveningAzkarReminderEnabled.value =
        _prefs.getBool('eveningAzkarReminderEnabled') ?? false;
    sleepAzkarReminderEnabled.value =
        _prefs.getBool('sleepAzkarReminderEnabled') ?? false;
    tasbeehReminderEnabled.value =
        _prefs.getBool('tasbeehReminderEnabled') ?? false;
    weeklyFridayReminderEnabled.value =
        _prefs.getBool('weeklyFridayReminderEnabled') ?? false;
    prayerTimesNotificationsEnabled.value =
        _prefs.getBool('prayerTimesNotificationsEnabled') ?? false;

    // Defer theme application to avoid "setState called during build" errors.
    // This ensures the theme change happens after the current build cycle is complete.
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyCurrentTheme());

    _notificationService.setHideNotificationContent(
      hideNotificationContent.value,
    );
    _syncNotificationsState();
    await syncFromServer();
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    }
  }

  Future<void> _cancelManagedNotifications() async {
    await _notificationService.cancelNotifications([
      generalDailyAzkarId,
      morningAzkarId,
      eveningAzkarId,
      sleepAzkarId,
      tasbeehReminderId,
      weeklyFridayReminderId,
      smartMorningAzkarId,
    ]);
    await _prayerTimesController.cancelAllPrayerTimeNotifications();
  }

  Future<void> _ensurePrayerTimesReady() async {
    try {
      await _prayerTimesController.initializationFuture;
    } catch (e) {
      debugPrint('Failed to await prayer times initialization: $e');
    }
  }

  Future<void> _saveShortcuts(List<String> shortcuts) async {
    await _prefs.setStringList('enabledShortcuts', shortcuts);
  }

  bool isShortcutEnabled(String id) {
    return enabledShortcuts.contains(id);
  }

  Future<void> setShortcutEnabled(String id, bool enabled) async {
    final updated = List<String>.from(enabledShortcuts);
    if (enabled) {
      if (!updated.contains(id)) {
        updated.add(id);
      }
    } else {
      updated.remove(id);
    }
    enabledShortcuts.assignAll(updated);
    await _saveShortcuts(updated);
  }

  void _applyCurrentTheme() {
    Get.changeThemeMode(
      darkModeEnabled.value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  String _localeToLabel(String locale) {
    return locale == 'en' ? 'English' : 'العربية';
  }

  String _labelToLocale(String label) {
    return label == 'English' ? 'en' : 'ar';
  }

  Future<void> syncFromServer() async {
    final authToken = _prefs.getString('token');
    if (authToken == null) {
      return;
    }

    try {
      final data = await _apiService.fetchAppSettings(authToken: authToken);
      if (data.isEmpty) {
        return;
      }
      _suppressRemoteSync = true;
      await _applyRemoteSettings(data);
    } catch (e) {
      debugPrint('Failed to sync app settings from server: $e');
    } finally {
      _suppressRemoteSync = false;
    }
  }

  Future<void> _applyRemoteSettings(Map<String, dynamic> data) async {
    final remoteNotifications = data['notifications_enabled'];
    if (remoteNotifications is bool &&
        remoteNotifications != notificationsEnabled.value) {
      notificationsEnabled.value = remoteNotifications;
      await _saveSetting('notificationsEnabled', remoteNotifications);
      if (remoteNotifications) {
        _syncNotificationsState();
      } else {
        await _notificationService.cancelAllNotifications();
      }
    }

    final remoteLanguage = data['language'];
    if (remoteLanguage is String &&
        (remoteLanguage == 'ar' || remoteLanguage == 'en')) {
      final label = _localeToLabel(remoteLanguage);
      if (selectedLanguage.value != label) {
        selectedLanguage.value = label;
        await _saveSetting('selectedLanguage', label);
        Get.updateLocale(Locale(remoteLanguage));
      }
    }

    final remoteTheme = data['theme'];
    if (remoteTheme is String &&
        (remoteTheme == 'dark' || remoteTheme == 'light')) {
      final shouldUseDark = remoteTheme == 'dark';
      if (darkModeEnabled.value != shouldUseDark) {
        darkModeEnabled.value = shouldUseDark;
        await _saveSetting('darkModeEnabled', shouldUseDark);
        _applyCurrentTheme();
      }
    }
  }

  Future<void> _pushRemoteUpdate(Map<String, dynamic> payload) async {
    if (_suppressRemoteSync) {
      return;
    }
    final authToken = _prefs.getString('token');
    if (authToken == null) {
      return;
    }

    try {
      await _apiService.updateAppSettings(
        authToken: authToken,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Failed to update app settings on server: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled.value = value;
    await _saveSetting('notificationsEnabled', value);

    if (value) {
      final granted = await _notificationService.requestPermissions();
      if (granted) {
        _syncNotificationsState();
        Get.snackbar(
          'تنبيهات',
          'تم تفعيل التنبيهات وجدولتها بنجاح!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        notificationsEnabled.value = false;
        await _saveSetting('notificationsEnabled', false);
        _notificationService.cancelAllNotifications();
        Get.snackbar(
          'تنبيهات',
          'الرجاء منح أذونات الإشعارات من إعدادات الجهاز لتفعيل التنبيهات.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } else {
      await _notificationService.cancelAllNotifications();
      Get.snackbar(
        'تنبيهات',
        'تم تعطيل جميع التنبيهات.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }

    await _pushRemoteUpdate({
      'notifications_enabled': notificationsEnabled.value,
    });
  }

  Future<void> setNotificationIntervalMinutes(int value) async {
    notificationIntervalMinutes.value = value;
    await _saveSetting('notificationIntervalMinutes', value);
    if (notificationsEnabled.value) {
      _syncNotificationsState();
    }
  }

  Future<void> setSelectedLanguage(String value) async {
    selectedLanguage.value = value;
    await _saveSetting('selectedLanguage', value);
    Get.updateLocale(Locale(value == 'العربية' ? 'ar' : 'en'));

    await _pushRemoteUpdate({
      'language': _labelToLocale(value),
    });
  }

  Future<void> setDarkModeEnabled(bool value) async {
    darkModeEnabled.value = value;
    await _saveSetting('darkModeEnabled', value);
    _applyCurrentTheme();

    await _pushRemoteUpdate({
      'theme': value ? 'dark' : 'light',
    });
  }

  Future<void> setFontSizeMultiplier(double value) async {
    fontSizeMultiplier.value = value;
    await _saveSetting('fontSizeMultiplier', value);
  }

  Future<void> setLineHeightMultiplier(double value) async {
    lineHeightMultiplier.value = value;
    await _saveSetting('lineHeightMultiplier', value);
  }

  Future<void> setVibrateOnNotification(bool value) async {
    vibrateOnNotification.value = value;
    await _saveSetting('vibrateOnNotification', value);
    _syncNotificationsState(); // أعد مزامنة لجعل الاهتزاز سارياً
  }

  Future<void> setHideNotificationContent(bool value) async {
    hideNotificationContent.value = value;
    await _saveSetting('hideNotificationContent', value);
    _notificationService.setHideNotificationContent(value);
    await _syncNotificationsState();
  }

  Future<void> setSmartMorningAzkarReminderEnabled(bool value) async {
    smartMorningAzkarReminderEnabled.value = value;
    await _saveSetting('smartMorningAzkarReminderEnabled', value);
    await _syncNotificationsState();
  }

  Future<void> setRandomAzkarOrder(bool value) async {
    randomAzkarOrder.value = value;
    await _prefs.setBool('randomAzkarOrder', value);
  }

  Future<void> setTravelModeEnabled(bool value) async {
    travelModeEnabled.value = value;
    await _saveSetting('travelModeEnabled', value);
  }

  Future<void> setSmartPrayerUpdatesEnabled(bool value) async {
    smartPrayerUpdatesEnabled.value = value;
    await _saveSetting('smartPrayerUpdatesEnabled', value);
  }

  Future<void> setGeneralDailyAzkarEnabled(bool value) async {
    generalDailyAzkarEnabled.value = value;
    await _saveSetting('generalDailyAzkarEnabled', value);
    _syncSpecificNotification(
      generalDailyAzkarId,
      value,
      () => _notificationService.scheduleDailyReminder(
        id: generalDailyAzkarId,
        title: 'تذكير أذكار عام',
        body: 'حان وقت أذكارك اليومية!',
        time: _resolveSmartTime(
          type: _SmartReminderType.general,
          fallback: const TimeOfDay(hour: 8, minute: 0),
        ),
        payload: 'generalDailyAzkar',
      ),
    );
  }

  Future<void> setMorningAzkarReminderEnabled(bool value) async {
    morningAzkarReminderEnabled.value = value;
    await _saveSetting('morningAzkarReminderEnabled', value);
    _syncSpecificNotification(
      morningAzkarId,
      value,
      () => _notificationService.scheduleDailyReminder(
        id: morningAzkarId,
        title: 'أذكار الصباح',
        body: 'ابدأ يومك بذكر الله',
        time: _resolveSmartTime(
          type: _SmartReminderType.morning,
          fallback: const TimeOfDay(hour: 6, minute: 0),
        ),
        payload: 'morningAzkar',
      ),
    );
    await _syncSmartMorningAzkarReminder();
  }

  Future<void> setEveningAzkarReminderEnabled(bool value) async {
    eveningAzkarReminderEnabled.value = value;
    await _saveSetting('eveningAzkarReminderEnabled', value);
    _syncSpecificNotification(
      eveningAzkarId,
      value,
      () => _notificationService.scheduleDailyReminder(
        id: eveningAzkarId,
        title: 'أذكار المساء',
        body: 'حصّن نفسك بذكر الله',
        time: _resolveSmartTime(
          type: _SmartReminderType.evening,
          fallback: const TimeOfDay(hour: 18, minute: 0),
        ),
        payload: 'eveningAzkar',
      ),
    );
  }

  Future<void> setSleepAzkarReminderEnabled(bool value) async {
    sleepAzkarReminderEnabled.value = value;
    await _saveSetting('sleepAzkarReminderEnabled', value);
    _syncSpecificNotification(
      sleepAzkarId,
      value,
      () => _notificationService.scheduleDailyReminder(
        id: sleepAzkarId,
        title: 'أذكار النوم',
        body: 'تذكير بأذكار النوم قبل الخلود إليه',
        time: _resolveSmartTime(
          type: _SmartReminderType.sleep,
          fallback: const TimeOfDay(hour: 22, minute: 0),
        ),
        payload: 'sleepAzkar',
      ),
    );
  }

  Future<void> setTasbeehReminderEnabled(bool value) async {
    tasbeehReminderEnabled.value = value;
    await _saveSetting('tasbeehReminderEnabled', value);
    _syncSpecificNotification(
      tasbeehReminderId,
      value,
      () => _notificationService.scheduleDailyReminder(
        id: tasbeehReminderId,
        title: 'تذكير تسبيح',
        body: 'حان وقت التسبيح، لا تنس ذكر الله!',
        time: _resolveSmartTime(
          type: _SmartReminderType.tasbeeh,
          fallback: const TimeOfDay(hour: 12, minute: 0),
        ),
        payload: 'tasbeeh',
      ),
    );
  }

  Future<void> setWeeklyFridayReminderEnabled(bool value) async {
    weeklyFridayReminderEnabled.value = value;
    await _saveSetting('weeklyFridayReminderEnabled', value);
    _syncSpecificNotification(
      weeklyFridayReminderId,
      value,
      () => _notificationService.scheduleWeeklyReminder(
        id: weeklyFridayReminderId,
        title: 'تذكير الجمعة',
        body: 'لا تنسَ قراءة سورة الكهف والصلاة على النبي ﷺ',
        time: const TimeOfDay(hour: 10, minute: 0),
        day: WeekDay.friday,
        payload: 'fridayReminder',
      ),
    );
  }

  Future<void> setPrayerTimesNotificationsEnabled(bool value) async {
    prayerTimesNotificationsEnabled.value = value;
    await _saveSetting('prayerTimesNotificationsEnabled', value);
    _syncNotificationsState();
  }

  Future<void> _syncSpecificNotification(
    int id,
    bool enabled,
    Function scheduleFunction,
  ) async {
    if (notificationsEnabled.value) {
      if (enabled) {
        await scheduleFunction();
      } else {
        await _notificationService.cancelNotification(id);
      }
    } else {
      await _notificationService.cancelNotification(id);
    }
  }

  // **تعديلات مهمة في _syncNotificationsState**
  Future<void> _syncNotificationsState() async {
    // 1. إلغاء الإشعارات التي يديرها التطبيق فقط لتفادي حذف إشعارات أخرى.
    await _cancelManagedNotifications();

    // 2. التحقق من المفتاح الرئيسي لتمكين الإشعارات بشكل عام.
    if (!notificationsEnabled.value) {
      await _notificationService.cancelAllNotifications();
      print(
        'Global notifications disabled. No new notifications will be scheduled.',
      );
      // Since all notifications were cancelled above, we can just exit.
      return; // إذا كانت الإشعارات معطلة عالميًا، لا نجدول أي شيء.
    }

    // 3. جدولة إشعارات الأذكار التي تم تمكينها فرديًا
    if (generalDailyAzkarEnabled.value) {
      await _notificationService.scheduleDailyReminder(
        id: generalDailyAzkarId,
        title: 'تذكير أذكار عام',
        body: 'حان وقت أذكارك اليومية!',
        time: _resolveSmartTime(
          type: _SmartReminderType.general,
          fallback: const TimeOfDay(hour: 8, minute: 0),
        ),
        payload: 'generalDailyAzkar',
      );
    }
    if (morningAzkarReminderEnabled.value) {
      await _notificationService.scheduleDailyReminder(
        id: morningAzkarId,
        title: 'أذكار الصباح',
        body: 'ابدأ يومك بذكر الله',
        time: _resolveSmartTime(
          type: _SmartReminderType.morning,
          fallback: const TimeOfDay(hour: 6, minute: 0),
        ),
        payload: 'morningAzkar',
      );
    }
    if (eveningAzkarReminderEnabled.value) {
      await _notificationService.scheduleDailyReminder(
        id: eveningAzkarId,
        title: 'أذكار المساء',
        body: 'حصّن نفسك بذكر الله',
        time: _resolveSmartTime(
          type: _SmartReminderType.evening,
          fallback: const TimeOfDay(hour: 18, minute: 0),
        ),
        payload: 'eveningAzkar',
      );
    }
    if (sleepAzkarReminderEnabled.value) {
      await _notificationService.scheduleDailyReminder(
        id: sleepAzkarId,
        title: 'أذكار النوم',
        body: 'تذكير بأذكار النوم قبل الخلود إليه',
        time: _resolveSmartTime(
          type: _SmartReminderType.sleep,
          fallback: const TimeOfDay(hour: 22, minute: 0),
        ),
        payload: 'sleepAzkar',
      );
    }
    if (tasbeehReminderEnabled.value) {
      await _notificationService.scheduleDailyReminder(
        id: tasbeehReminderId,
        title: 'تذكير تسبيح',
        body: 'حان وقت التسبيح، لا تنس ذكر الله!',
        time: _resolveSmartTime(
          type: _SmartReminderType.tasbeeh,
          fallback: const TimeOfDay(hour: 12, minute: 0),
        ),
        payload: 'tasbeeh',
      );
    }
    if (weeklyFridayReminderEnabled.value) {
      await _notificationService.scheduleWeeklyReminder(
        id: weeklyFridayReminderId,
        title: 'تذكير الجمعة',
        body: 'لا تنسَ قراءة سورة الكهف والصلاة على النبي ﷺ',
        time: const TimeOfDay(hour: 10, minute: 0),
        day: WeekDay.friday,
        payload: 'fridayReminder',
      );
    }

    // 4. جدولة إشعارات أوقات الصلاة إذا كانت مفعلة
    if (prayerTimesNotificationsEnabled.value) {
      // التأكد من أن بيانات أوقات الصلاة متاحة قبل الجدولة.
      // إذا كانت فارغة، حاول جلبها.
      await _ensurePrayerTimesReady();
      if (_prayerTimesController.prayerTimesData.isEmpty) {
        print(
          'Prayer times data is empty, attempting to fetch before scheduling.',
        );
        _prayerTimesController.fetchPrayerTimes(suppressErrors: true);
      }

      // جدولة إشعارات أوقات الصلاة فقط إذا كانت البيانات موجودة الآن
      if (_prayerTimesController.prayerTimesData.isNotEmpty) {
        await _prayerTimesController.schedulePrayerTimeNotifications(
          // استدعاء الدالة الصحيحة
          enableVibration: vibrateOnNotification.value,
          playSound: true,
        );

        print('Prayer time notifications scheduled by AppSettingsController.');
      } else {
        print(
          'Prayer times data still empty after fetch attempt, cannot schedule prayer notifications.',
        );
      }
    }

    await _syncSmartMorningAzkarReminder();
  }

  Future<void> _syncSmartMorningAzkarReminder() async {
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    final doneDate = _prefs.getString('morning_adhkar_done_date');
    if (doneDate == todayKey) {
      await _notificationService.cancelNotification(smartMorningAzkarId);
      await _prefs.remove('smart_morning_scheduled_at');
      return;
    }

    if (!notificationsEnabled.value ||
        !morningAzkarReminderEnabled.value ||
        !smartMorningAzkarReminderEnabled.value) {
      await _notificationService.cancelNotification(smartMorningAzkarId);
      await _prefs.remove('smart_morning_scheduled_at');
      return;
    }

    final now = DateTime.now();
    final scheduledAtRaw = _prefs.getString('smart_morning_scheduled_at');
    if (scheduledAtRaw != null) {
      final scheduledAt = DateTime.tryParse(scheduledAtRaw);
      if (scheduledAt != null &&
          scheduledAt.isAfter(now) &&
          scheduledAt.toIso8601String().startsWith(todayKey)) {
        return;
      }
    }

    final target = DateTime(now.year, now.month, now.day, 14, 0);
    final latest = DateTime(now.year, now.month, now.day, 18, 0);
    DateTime? scheduledAt;
    if (now.isBefore(target)) {
      scheduledAt = target;
    } else if (now.isBefore(latest)) {
      scheduledAt = now.add(const Duration(minutes: 5));
    }

    if (scheduledAt == null) {
      await _prefs.remove('smart_morning_scheduled_at');
      return;
    }

    final payload = json.encode({
      'type': 'morningAzkar',
      'scheduledTime': scheduledAt.toIso8601String(),
      'notificationId': smartMorningAzkarId,
      'smart': true,
    });

    await _notificationService.scheduleOneTimeNotification(
      id: smartMorningAzkarId,
      title: 'تنبيه لطيف: أذكار الصباح',
      body: 'لم تقرأ أذكار الصباح اليوم، خصص دقيقة الآن.',
      scheduledAt: scheduledAt,
      payload: payload,
      enableVibration: vibrateOnNotification.value,
      playSound: true,
    );

    await _prefs.setString(
      'smart_morning_scheduled_at',
      scheduledAt.toIso8601String(),
    );
  }

  Future<void> resetSettings() async {
    await _prefs.clear();
    notificationsEnabled.value = true;
    notificationIntervalMinutes.value = 60;
    selectedLanguage.value = 'العربية';
    darkModeEnabled.value = false;
    fontSizeMultiplier.value = 1.0;
    lineHeightMultiplier.value = 1.9;
    vibrateOnNotification.value = true;
    hideNotificationContent.value = false;
    smartMorningAzkarReminderEnabled.value = true;
    randomAzkarOrder.value = true;
    travelModeEnabled.value = false;
    smartPrayerUpdatesEnabled.value = true;
    generalDailyAzkarEnabled.value = false;
    morningAzkarReminderEnabled.value = false;
    eveningAzkarReminderEnabled.value = false;
    sleepAzkarReminderEnabled.value = false;
    tasbeehReminderEnabled.value = false;
    weeklyFridayReminderEnabled.value = false;
    prayerTimesNotificationsEnabled.value = false;

    _applyCurrentTheme();
    _notificationService.setHideNotificationContent(false);
    _syncNotificationsState();

    Get.snackbar(
      'إعدادات',
      'تم إعادة تعيين الإعدادات بنجاح!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
    );
  }

  Future<void> saveReminderTime({
    required String keySuffix,
    required TimeOfDay time,
  }) async {
    await _prefs.setInt('${keySuffix}Hour', time.hour);
    await _prefs.setInt('${keySuffix}Minute', time.minute);
  }

  Future<TimeOfDay?> getReminderTime(String keySuffix) async {
    final hour = _prefs.getInt('${keySuffix}Hour');
    final minute = _prefs.getInt('${keySuffix}Minute');

    return (hour != null && minute != null)
        ? TimeOfDay(hour: hour, minute: minute)
        : null;
  }

  Future<void> clearReminderTime(String keySuffix) async {
    await _prefs.remove('${keySuffix}Hour');
    await _prefs.remove('${keySuffix}Minute');
  }

  Future<void> resyncNotifications() async {
    await _syncNotificationsState();
  }

  TimeOfDay _resolveSmartTime({
    required _SmartReminderType type,
    required TimeOfDay fallback,
  }) {
    if (_prayerTimesController.prayerTimesData.isEmpty) {
      return fallback;
    }

    TimeOfDay? baseTime;
    int offsetMinutes = 0;
    switch (type) {
      case _SmartReminderType.general:
        baseTime = _getPrayerTime('الظهر');
        offsetMinutes = 20;
        break;
      case _SmartReminderType.morning:
        baseTime = _getPrayerTime('الفجر');
        offsetMinutes = 30;
        break;
      case _SmartReminderType.evening:
        baseTime = _getPrayerTime('المغرب');
        offsetMinutes = 30;
        break;
      case _SmartReminderType.sleep:
        baseTime = _getPrayerTime('العشاء');
        offsetMinutes = 45;
        break;
      case _SmartReminderType.tasbeeh:
        baseTime = _getPrayerTime('العصر');
        offsetMinutes = 20;
        break;
    }

    if (baseTime == null) {
      return fallback;
    }
    return _addMinutes(baseTime, offsetMinutes);
  }

  TimeOfDay? _getPrayerTime(String prayerName) {
    final timeString = _prayerTimesController.prayerTimesData[prayerName];
    if (timeString == null || timeString.isEmpty) {
      return null;
    }
    return _prayerTimesController.parseTimeOfDay(timeString);
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final totalMinutes =
        (time.hour * 60 + time.minute + minutes) % (24 * 60);
    final normalized =
        totalMinutes < 0 ? totalMinutes + (24 * 60) : totalMinutes;
    return TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
  }
}

enum _SmartReminderType {
  general,
  morning,
  evening,
  sleep,
  tasbeeh,
}
