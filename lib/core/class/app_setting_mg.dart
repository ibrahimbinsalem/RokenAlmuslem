import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppSettingsController
/// يدير إعدادات التطبيق باستخدام GetX والمتغيرات الملاحظة (Observables).
/// يستخدم SharedPreferences لتخزين واستعادة الإعدادات بشكل دائم.
class AppSettingsController extends GetxController {
  // مثيل SharedPreferences لتحميل وحفظ الإعدادات
  late SharedPreferences _prefs;

  // المتغيرات الملاحظة (Rx - Reactive Extensions)
  // هذه المتغيرات عندما تتغير، ستقوم GetX بإعادة بناء الأجزاء من الواجهة
  // التي تستمع إليها (باستخدام Obx أو GetX).
  // ملاحظة: notificationsEnabled سيكون المفتاح العام لتفعيل/تعطيل كل التنبيهات.
  final notificationsEnabled = true.obs; // تفعيل/تعطيل كل التنبيهات
  final notificationIntervalMinutes = 60.obs; // فاصل تكرار التنبيه بالدقائق
  final selectedLanguage = 'العربية'.obs; // اللغة المختارة للتطبيق
  final darkModeEnabled = false.obs; // تفعيل/تعطيل الوضع الليلي
  final fontSizeMultiplier = 1.0.obs; // معامل ضرب حجم الخط
  final vibrateOnNotification = true.obs; // اهتزاز عند التنبيه
  final randomAzkarOrder = true.obs; // ترتيب الأذكار عشوائياً

  // جديد: متغيرات حالة لكل نوع تذكير لتمكين/تعطيل كل واحد على حدة
  final generalDailyAzkarEnabled = false.obs;
  final morningAzkarReminderEnabled = false.obs;
  final eveningAzkarReminderEnabled = false.obs;
  final sleepAzkarReminderEnabled = false.obs;
  final tasbeehReminderEnabled = false.obs;
  final weeklyFridayReminderEnabled = false.obs;

  // معرفات الإشعارات الثابتة لتسهيل إدارة الإشعارات المجدولة.
  // كل نوع إشعار له معرف فريد خاص به.
  static const int generalDailyAzkarId = 1;
  static const int morningAzkarId = 101;
  static const int eveningAzkarId = 102;
  static const int sleepAzkarId = 301;
  static const int tasbeehReminderId = 104; // معرف التسبيح
  static const int weeklyFridayReminderId = 201;

  get themeMode => null;
  

  /// تُستدعى هذه الدالة تلقائياً عند تهيئة الـ Controller لأول مرة.
  @override
  void onInit() {
    super.onInit();
    loadSettings(); // تحميل الإعدادات عند بدء تشغيل الـ Controller
  }

  /// دالة خاصة (private) لتحميل الإعدادات من SharedPreferences.
  /// يتم استدعاؤها مرة واحدة عند تهيئة الـ Controller.
  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    // تحميل كل إعداد، إذا لم يكن موجوداً، استخدم القيمة الافتراضية.
    notificationsEnabled.value = _prefs.getBool('notificationsEnabled') ?? true;
    notificationIntervalMinutes.value =
        _prefs.getInt('notificationIntervalMinutes') ?? 60;
    selectedLanguage.value = _prefs.getString('selectedLanguage') ?? 'العربية';
    darkModeEnabled.value = _prefs.getBool('darkModeEnabled') ?? false;
    fontSizeMultiplier.value = _prefs.getDouble('fontSizeMultiplier') ?? 1.0;
    vibrateOnNotification.value =
        _prefs.getBool('vibrateOnNotification') ?? true;
    randomAzkarOrder.value = _prefs.getBool('randomAzkarOrder') ?? true;

    // جديد: تحميل حالة التفعيل لكل تذكير
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

    // تحديث الواجهة بعد تحميل جميع الإعدادات.
    update();
  }

  /// تحديث حالة تفعيل الإشعارات العامة وحفظها.
  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled.value = value;
    await _prefs.setBool('notificationsEnabled', value);
  }

  /// تحديث فاصل تكرار التنبيه وحفظه.
  Future<void> setNotificationIntervalMinutes(int value) async {
    notificationIntervalMinutes.value = value;
    await _prefs.setInt('notificationIntervalMinutes', value);
  }

  /// تحديث اللغة المختارة وحفظها.
  Future<void> setSelectedLanguage(String value) async {
    selectedLanguage.value = value;
    await _prefs.setString('selectedLanguage', value);
  }

  /// تحديث حالة الوضع الليلي وحفظها.
  /// تُغير GetX الثيم في التطبيق تلقائياً بناءً على هذه القيمة في GetMaterialApp.
  Future<void> setDarkModeEnabled(bool value) async {
    darkModeEnabled.value = value;
    await _prefs.setBool('darkModeEnabled', value);
  }

  /// تحديث معامل ضرب حجم الخط وحفظه.
  Future<void> setFontSizeMultiplier(double value) async {
    fontSizeMultiplier.value = value;
    await _prefs.setDouble('fontSizeMultiplier', value);
  }

  /// تحديث حالة اهتزاز التنبيه وحفظها.
  Future<void> setVibrateOnNotification(bool value) async {
    vibrateOnNotification.value = value;
    await _prefs.setBool('vibrateOnNotification', value);
  }

  /// تحديث حالة ترتيب الأذكار العشوائي وحفظها.
  Future<void> setRandomAzkarOrder(bool value) async {
    randomAzkarOrder.value = value;
    await _prefs.setBool('randomAzkarOrder', value);
  }

  // جديد: دوال لتحديث حالة تفعيل كل تذكير على حدة
  Future<void> setGeneralDailyAzkarEnabled(bool value) async {
    generalDailyAzkarEnabled.value = value;
    await _prefs.setBool('generalDailyAzkarEnabled', value);
  }

  Future<void> setMorningAzkarReminderEnabled(bool value) async {
    morningAzkarReminderEnabled.value = value;
    await _prefs.setBool('morningAzkarReminderEnabled', value);
  }

  Future<void> setEveningAzkarReminderEnabled(bool value) async {
    eveningAzkarReminderEnabled.value = value;
    await _prefs.setBool('eveningAzkarReminderEnabled', value);
  }

  Future<void> setSleepAzkarReminderEnabled(bool value) async {
    sleepAzkarReminderEnabled.value = value;
    await _prefs.setBool('sleepAzkarReminderEnabled', value);
  }

  Future<void> setTasbeehReminderEnabled(bool value) async {
    tasbeehReminderEnabled.value = value;
    await _prefs.setBool('tasbeehReminderEnabled', value);
  }

  Future<void> setWeeklyFridayReminderEnabled(bool value) async {
    weeklyFridayReminderEnabled.value = value;
    await _prefs.setBool('weeklyFridayReminderEnabled', value);
  }

  /// إعادة تعيين جميع الإعدادات إلى قيمها الافتراضية.
  /// يتم مسح جميع الإعدادات المحفوظة ثم إعادة تحميل الإعدادات الافتراضية.
  Future<void> resetSettings() async {
    await _prefs.clear(); // مسح جميع البيانات من SharedPreferences
    await loadSettings(); // إعادة تحميل الإعدادات (ستعود إلى الافتراضيات)
  }

// This code to save the value of time of reminder : 

   Future<void> saveReminderTime({
    required bool isMorning,
    required TimeOfDay time,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      isMorning ? 'morningHour' : 'eveningHour',
      time.hour,
    );
    await prefs.setInt(
      isMorning ? 'morningMinute' : 'eveningMinute',
      time.minute,
    );
  }

   Future<TimeOfDay?> getReminderTime(bool isMorning) async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(isMorning ? 'morningHour' : 'eveningHour');
    final minute = prefs.getInt(isMorning ? 'morningMinute' : 'eveningMinute');
    
    return (hour != null && minute != null)
        ? TimeOfDay(hour: hour, minute: minute)
        : null;
  }

  Future<void> clearReminderTime(bool isMorning) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(isMorning ? 'morningHour' : 'eveningHour');
    await prefs.remove(isMorning ? 'morningMinute' : 'eveningMinute');
  }
}
