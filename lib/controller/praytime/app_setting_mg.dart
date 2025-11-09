import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:rokenalmuslem/core/services/localnotification.dart'; // استيراد NotificationService
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart'; // استيراد PrayerTimesController

/// AppSettingsController
/// يدير إعدادات التطبيق باستخدام GetX والمتغيرات الملاحظة (Observables).
/// يستخدم SharedPreferences لتخزين واستعادة الإعدادات بشكل دائم.
class AppSettingsController extends GetxController {
  late SharedPreferences _prefs;
  late NotificationService _notificationService;
  late PrayerTimesController _prayerTimesController;

  final notificationsEnabled = true.obs;
  final notificationIntervalMinutes = 60.obs;
  final selectedLanguage = 'العربية'.obs;
  final darkModeEnabled = false.obs;
  final fontSizeMultiplier = 1.0.obs;
  final vibrateOnNotification = true.obs;
  final randomAzkarOrder = true.obs;

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
  static const int prayerTimesNotificationsStartId = 1000;
  static const int prayerTimesNotificationsEndId = 1005;

  @override
  void onInit() {
    super.onInit();
    _notificationService = Get.find<NotificationService>();
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
    vibrateOnNotification.value =
        _prefs.getBool('vibrateOnNotification') ?? true;
    randomAzkarOrder.value = _prefs.getBool('randomAzkarOrder') ?? true;

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

    _syncNotificationsState();
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

  void _applyCurrentTheme() {
    Get.changeThemeMode(
      darkModeEnabled.value ? ThemeMode.dark : ThemeMode.light,
    );
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
  }

  Future<void> setDarkModeEnabled(bool value) async {
    darkModeEnabled.value = value;
    await _saveSetting('darkModeEnabled', value);
    _applyCurrentTheme();
  }

  Future<void> setFontSizeMultiplier(double value) async {
    fontSizeMultiplier.value = value;
    await _saveSetting('fontSizeMultiplier', value);
  }

  Future<void> setVibrateOnNotification(bool value) async {
    vibrateOnNotification.value = value;
    await _saveSetting('vibrateOnNotification', value);
    _syncNotificationsState(); // أعد مزامنة لجعل الاهتزاز سارياً
  }

  Future<void> setRandomAzkarOrder(bool value) async {
    randomAzkarOrder.value = value;
    await _prefs.setBool('randomAzkarOrder', value);
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
        time: const TimeOfDay(hour: 8, minute: 0),
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
        time: const TimeOfDay(hour: 6, minute: 0),
        payload: 'morningAzkar',
      ),
    );
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
        time: const TimeOfDay(hour: 18, minute: 0),
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
        time: const TimeOfDay(hour: 22, minute: 0),
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
        time: const TimeOfDay(hour: 12, minute: 0),
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
    // **الحل النهائي**: يتم العثور على المتحكم هنا عند الحاجة فقط
    // هذا يضمن أن PrayerTimesController قد تم تهيئته بالكامل.
    _prayerTimesController = Get.find<PrayerTimesController>();
    // 1. إلغاء جميع الإشعارات أولاً. هذا يضمن عدم وجود إشعارات قديمة أو مكررة.
    // This is a simple and robust strategy.
    await _notificationService.cancelAllNotifications();

    // 2. التحقق من المفتاح الرئيسي لتمكين الإشعارات بشكل عام.
    if (!notificationsEnabled.value) {
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
        time: const TimeOfDay(hour: 8, minute: 0),
        payload: 'generalDailyAzkar',
      );
    }
    if (morningAzkarReminderEnabled.value) {
      await _notificationService.scheduleDailyReminder(
        id: morningAzkarId,
        title: 'أذكار الصباح',
        body: 'ابدأ يومك بذكر الله',
        time: const TimeOfDay(hour: 6, minute: 0),
        payload: 'morningAzkar',
      );
    }
    if (eveningAzkarReminderEnabled.value) {
      await _notificationService.scheduleDailyReminder(
        id: eveningAzkarId,
        title: 'أذكار المساء',
        body: 'حصّن نفسك بذكر الله',
        time: const TimeOfDay(hour: 18, minute: 0),
        payload: 'eveningAzkar',
      );
    }
    if (sleepAzkarReminderEnabled.value) {
      await _notificationService.scheduleDailyReminder(
        id: sleepAzkarId,
        title: 'أذكار النوم',
        body: 'تذكير بأذكار النوم قبل الخلود إليه',
        time: const TimeOfDay(hour: 22, minute: 0),
        payload: 'sleepAzkar',
      );
    }
    if (tasbeehReminderEnabled.value) {
      await _notificationService.scheduleDailyReminder(
        id: tasbeehReminderId,
        title: 'تذكير تسبيح',
        body: 'حان وقت التسبيح، لا تنس ذكر الله!',
        time: const TimeOfDay(hour: 12, minute: 0),
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
      // لا نحاول جلب البيانات هنا. نعتمد فقط على البيانات المتاحة حاليًا.
      // هذا يمنع التوقف في وضع عدم الاتصال.

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
  }

  Future<void> resetSettings() async {
    await _prefs.clear();
    notificationsEnabled.value = true;
    notificationIntervalMinutes.value = 60;
    selectedLanguage.value = 'العربية';
    darkModeEnabled.value = false;
    fontSizeMultiplier.value = 1.0;
    vibrateOnNotification.value = true;
    randomAzkarOrder.value = true;
    generalDailyAzkarEnabled.value = false;
    morningAzkarReminderEnabled.value = false;
    eveningAzkarReminderEnabled.value = false;
    sleepAzkarReminderEnabled.value = false;
    tasbeehReminderEnabled.value = false;
    weeklyFridayReminderEnabled.value = false;
    prayerTimesNotificationsEnabled.value = false;

    _applyCurrentTheme();
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
}
