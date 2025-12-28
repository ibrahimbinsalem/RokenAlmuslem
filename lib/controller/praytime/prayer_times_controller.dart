import 'package:flutter/material.dart';
import 'package:rokenalmuslem/data/database/database_helper.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart'; // استيراد مكتبة intl

// استيراد NotificationService
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart'; // للوصول إلى إعدادات الاهتزاز

class PrayerTimesController extends GetxController {
  // --- State Variables ---
  bool isLoading = true;
  final RxString errorMessage = ''.obs;
  final RxMap<String, String> prayerTimesData = <String, String>{}.obs;

  // Location
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxString currentAddress = 'جاري تحديد الموقع...'.obs;

  // Prayer Times Settings
  final Rx<CalculationMethod> calculationMethod =
      CalculationMethod.muslim_world_league.obs;

  // --- New State Variables for Adjustments & Approval ---
  final RxBool isApproved = false.obs;
  final RxMap<String, int> prayerTimeAdjustments = <String, int>{}.obs;
  final RxMap<String, String> originalPrayerTimes = <String, String>{}.obs;

  final Rx<Madhab> madhab = Madhab.shafi.obs;

  late NotificationService _notificationService;
  late AppSettingsController _appSettingsController; // لإعدادات الاهتزاز

  // Future للتحميل الأولي
  late Future<void> initializationFuture;

  static const int prayerFajrId = 1000;
  static const int prayerSunriseId = 1001; // شروق
  static const int prayerDhuhrId = 1002; // ظهر
  static const int prayerAsrId = 1003; // عصر
  static const int prayerMaghribId = 1004; // مغرب
  static const int prayerIshaId = 1005; // عشاء

  // --- Mappings for UI ---
  final Map<CalculationMethod, String> calculationMethodNames = {
    CalculationMethod.muslim_world_league: 'رابطة العالم الإسلامي',
    CalculationMethod.egyptian: 'الهيئة المصرية العامة للمساحة',
    CalculationMethod.karachi: 'جامعة العلوم الإسلامية، كراتشي',
    CalculationMethod.umm_al_qura: 'جامعة أم القرى، مكة المكرمة',
    CalculationMethod.dubai: 'هيئة دبي للأوقاف',
    CalculationMethod.qatar: 'وزارة الأوقاف والشؤون الإسلامية القطرية',
    CalculationMethod.kuwait: 'الكويت',
    CalculationMethod.moon_sighting_committee: 'لجنة رؤية الهلال',
    CalculationMethod.north_america:
        'الجمعية الإسلامية لأمريكا الشمالية (ISNA)',
    CalculationMethod.singapore: 'المجلس الإسلامي في سنغافورة',
    CalculationMethod.turkey: 'رئاسة الشؤون الدينية التركية',
    CalculationMethod.tehran: 'معهد الجيوفيزياء، جامعة طهران',
    CalculationMethod.other: 'أخرى',
  };

  final Map<Madhab, String> madhabNames = {
    Madhab.shafi: 'شافعي، مالكي، حنبلي',
    Madhab.hanafi: 'حنفي',
  };

  @override
  void onInit() {
    super.onInit();
    // نقوم بإسناد عملية التهيئة إلى Future ليتم تتبعه في الواجهة
    initializationFuture = _initialize();
  }

  @override
  void onReady() {
    super.onReady();
    // يتم حقن AppSettingsController هنا بعد التأكد من تهيئة جميع المتحكمات
    _appSettingsController = Get.find<AppSettingsController>();
  }

  // دالة التهيئة الجديدة التي تعيد Future
  Future<void> _initialize() async {
    try {
      isLoading = true;
      update();

      _notificationService = Get.find<NotificationService>();
      await _configureLocalTimeZone();

      // 1. تحميل الإعدادات والموقع المحفوظين أولاً
      await loadPreferences();
      final prefs = await SharedPreferences.getInstance();
      final prayerTimesEnabled =
          prefs.getBool('prayerTimesNotificationsEnabled') ?? false;
      if (!prayerTimesEnabled) {
        errorMessage.value = '';
        isLoading = false;
        update();
        return;
      }
      final travelModeEnabled = prefs.getBool('travelModeEnabled') ?? false;
      final smartPrayerUpdatesEnabled =
          prefs.getBool('smartPrayerUpdatesEnabled') ?? true;
      if (!latitude.value.isFinite ||
          !longitude.value.isFinite ||
          latitude.value.abs() > 90 ||
          longitude.value.abs() > 180) {
        latitude.value = 0.0;
        longitude.value = 0.0;
        currentAddress.value = 'موقع غير صالح';
      }

      // 2. محاولة جلب أوقات الصلاة من قاعدة البيانات المحلية أولاً
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dbHelper = DatabaseHelper.instance;
      Map<String, String>? localPrayerTimes;
      try {
        localPrayerTimes = await dbHelper.getPrayerTimesForDate(today);
      } catch (e) {
        print("Failed to read prayer times from DB: $e");
      }

      if (localPrayerTimes != null) {
        print("Found prayer times in local DB for today. Displaying them.");
        prayerTimesData.value = {
          'الفجر': localPrayerTimes['fajr']!,
          'الشروق': localPrayerTimes['sunrise']!,
          'الظهر': localPrayerTimes['dhuhr']!,
          'العصر': localPrayerTimes['asr']!,
          'المغرب': localPrayerTimes['maghrib']!,
          'العشاء': localPrayerTimes['isha']!,
        };
        originalPrayerTimes.value = Map.from(prayerTimesData);
        _applyAdjustments();
      } else {
        // إذا لم توجد بيانات محلية، حاول حسابها إذا كان الموقع محفوظًا
        if (latitude.value != 0.0 && longitude.value != 0.0) {
          print(
            "No local DB data. Calculating prayer times from saved location.",
          );
          fetchPrayerTimes(suppressErrors: true);
        } else {
          // **جديد**: إذا لم يكن هناك موقع محفوظ، ابدأ عملية تحديد الموقع
          // هذا سيحدث فقط في أول مرة يفتح فيها المستخدم التطبيق
          if (latitude.value == 0.0 && longitude.value == 0.0) {
            print(
              "No saved location or local prayer times. Starting position determination...",
            );
            await determinePosition();
          }
          errorMessage.value =
              'الموقع غير محدد. يرجى تحديث الموقع لحساب أوقات الصلاة.';
        }
      }

      if (smartPrayerUpdatesEnabled && latitude.value != 0.0) {
        final thresholdKm = travelModeEnabled ? 5.0 : 25.0;
        await refreshIfLocationChanged(
          thresholdKm: thresholdKm,
          forceGps: travelModeEnabled,
        );
      }
    } catch (e) {
      print("An error occurred during initialization: $e");
      errorMessage.value = '';
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print("Timezone configured: $timeZoneName");
    } catch (e) {
      print(
        "Failed to get local timezone, falling back to Asia/Aden. Error: $e",
      );
      tz.setLocalLocation(tz.getLocation('Asia/Aden'));
    }
  }

  Future<void> schedulePrayerTimeNotifications({
    required bool enableVibration,
    required bool playSound,
  }) async {
    if (prayerTimesData.isEmpty) {
      print('Prayer times data is empty, cannot schedule notifications.');
      return;
    }

    // أولاً، قم بإلغاء الإشعارات القديمة لأوقات الصلاة لتجنب التكرار
    await cancelAllPrayerTimeNotifications();
    final myCoordinates = Coordinates(latitude.value, longitude.value);
    final params = calculationMethod.value.getParameters();
    params.madhab = madhab.value;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    final prayersToSchedule = {
      'الفجر': {
        'id': prayerFajrId,
        'time': prayerTimes.fajr,
        'type': 'prayerFajr',
      },
      'الشروق': {
        'id': prayerSunriseId,
        'time': prayerTimes.sunrise,
        'type': 'prayerSunrise',
      },
      'الظهر': {
        'id': prayerDhuhrId,
        'time': prayerTimes.dhuhr,
        'type': 'prayerDhuhr',
      },
      'العصر': {
        'id': prayerAsrId,
        'time': prayerTimes.asr,
        'type': 'prayerAsr',
      },
      'المغرب': {
        'id': prayerMaghribId,
        'time': prayerTimes.maghrib,
        'type': 'prayerMaghrib',
      },
      'العشاء': {
        'id': prayerIshaId,
        'time': prayerTimes.isha,
        'type': 'prayerIsha',
      },
    };

    for (var prayerEntry in prayersToSchedule.entries) {
      final prayer = prayerEntry.value;
      final prayerName = prayerEntry.key;
      final prayerTimeUTC = prayer['time'] as DateTime;
      // يجب تحويل وقت الصلاة (بتوقيت UTC) إلى TZDateTime للمنطقة الزمنية المحلية
      // لضمان جدولة الإشعار بشكل صحيح.
      final scheduledDateTime = tz.TZDateTime.from(prayerTimeUTC, tz.local);

      // نستخدم دالة مخصصة لجدولة إشعار يومي متكرر في منطقة زمنية محددة.
      // هذه الدالة تستخدم TZDateTime لضمان الدقة مع التوقيت الصيفي/الشتوي.
      // تم التغيير إلى scheduleDailyReminder لأنها الدالة الموجودة في الخدمة
      await _notificationService.scheduleDailyReminder(
        id: prayer['id'] as int,
        title: 'حان وقت صلاة $prayerName',
        body: 'تقبل الله منا ومنكم صالح الأعمال',
        time: TimeOfDay.fromDateTime(scheduledDateTime), // تمرير TimeOfDay
        enableVibration: enableVibration, // تمرير إعداد الاهتزاز
        playSound: playSound, // تمرير إعداد الصوت
        payload: json.encode({
          'type': prayer['type'] as String,
          'prayerName': prayerName, // Arabic prayer name
        }),
      );
    }
    print('Prayer time notifications scheduled by PrayerTimesController.');
  }

  Future<void> cancelAllPrayerTimeNotifications() async {
    await _notificationService.cancelNotification(prayerFajrId);
    await _notificationService.cancelNotification(prayerSunriseId);
    await _notificationService.cancelNotification(prayerDhuhrId);
    await _notificationService.cancelNotification(prayerAsrId);
    await _notificationService.cancelNotification(prayerMaghribId);
    await _notificationService.cancelNotification(prayerIshaId);
    print('Cancelled all specific prayer time notifications.');
  }

  TimeOfDay parseTimeOfDay(String timeString) {
    try {
      // محاولة تحليل التنسيق العربي hh:mm a (مثل: 05:30 صباحًا)
      DateFormat format12hrAmPm = DateFormat('hh:mm a', 'ar');
      DateTime tempTime = format12hrAmPm.parse(timeString);
      return TimeOfDay.fromDateTime(tempTime);
    } catch (_) {
      // إذا فشل التنسيق الأول، جرب تنسيق 24 ساعة (مثل: 17:30)
      try {
        DateFormat format24hr = DateFormat('HH:mm');
        DateTime tempTime = format24hr.parse(timeString.split(' ')[0]);
        return TimeOfDay.fromDateTime(tempTime);
      } catch (e) {
        print("Error parsing time string: $timeString. Error: $e");
        return const TimeOfDay(hour: 0, minute: 0);
      }
    }
  }

  Future<void> determinePosition({bool useSavedAsFallback = false}) async {
    try {
      isLoading = true;
      update();
      errorMessage.value = '';
      currentAddress.value = 'جاري طلب صلاحيات الموقع...';

      var status = await Permission.location.request();
      Position? position;

      if (status.isGranted) {
        currentAddress.value = 'جاري تحديد موقعك...';
        try {
          // محاولة الحصول على الموقع الحالي مع مهلة زمنية لتجنب التوقف
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 15),
          );
        } catch (e) {
          print("Could not get current position: $e. Trying last known.");
          // إذا فشل، حاول الحصول على آخر موقع معروف
          position = await Geolocator.getLastKnownPosition();
        }
      } else if (status.isDenied) {
        errorMessage.value =
            'تم رفض إذن الوصول للموقع. لا يمكن حساب أوقات الصلاة.';
      } else if (status.isPermanentlyDenied) {
        errorMessage.value =
            'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.';
        openAppSettings();
      }

      if (position != null) {
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        // **جديد**: بعد تحديد الموقع بنجاح، قم بحفظه وجلب أوقات الصلاة وتفاصيل الموقع
        await savePreferences();
        fetchPrayerTimes();
        // محاولة تحديث اسم الموقع في الخلفية
        fetchLocationDetails(latitude.value, longitude.value).catchError((e) {
          print("Could not update location name in background: $e");
        });
      } else {
        // إذا فشلت كل المحاولات ولم يكن هناك موقع محفوظ
        if (!useSavedAsFallback ||
            (latitude.value == 0.0 && longitude.value == 0.0)) {
          errorMessage.value = 'فشل تحديد الموقع. يرجى التحقق من خدمات الموقع.';
        }
      }
    } catch (e) {
      print("Error in determinePosition: $e");
      if (!useSavedAsFallback ||
          (latitude.value == 0.0 && longitude.value == 0.0)) {
        errorMessage.value = 'فشل في تحديد الموقع. حاول مرة أخرى.';
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> refreshIfLocationChanged({
    double thresholdKm = 25,
    bool forceGps = false,
  }) async {
    try {
      if (latitude.value == 0.0 && longitude.value == 0.0) {
        return;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      Position? position = await Geolocator.getLastKnownPosition();
      if (forceGps || position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (_) {}
      }
      if (position == null) {
        return;
      }

      final distanceMeters = Geolocator.distanceBetween(
        latitude.value,
        longitude.value,
        position.latitude,
        position.longitude,
      );
      if (distanceMeters < thresholdKm * 1000) {
        return;
      }

      latitude.value = position.latitude;
      longitude.value = position.longitude;
      await savePreferences();
      fetchPrayerTimes(suppressErrors: true);
      fetchLocationDetails(latitude.value, longitude.value).catchError((e) {
        print("Could not update location name in background: $e");
      });

      if (Get.isRegistered<AppSettingsController>()) {
        final settings = Get.find<AppSettingsController>();
        if (settings.notificationsEnabled.value &&
            settings.prayerTimesNotificationsEnabled.value) {
          await schedulePrayerTimeNotifications(
            enableVibration: settings.vibrateOnNotification.value,
            playSound: true,
          );
        }
      }
    } catch (e) {
      print("refreshIfLocationChanged error: $e");
    }
  }

  Future<void> fetchLocationDetails(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10&addressdetails=1&accept-language=ar',
        ),
        // إضافة Headers للامتثال لسياسة Nominatim
        headers: {
          'User-Agent': 'RokenAlmuslem/1.0 (ibrahimghanem707@gmail.com)',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        final city =
            address['city'] ??
            address['town'] ??
            address['village'] ??
            'مكان غير معروف';
        final country = address['country'] ?? 'دولة غير معروفة';
        currentAddress.value = '$city, $country';
      } else {
        print(
          'Failed to fetch location name. Status code: ${response.statusCode}',
        );
        currentAddress.value = 'فشل في تحديد اسم الموقع';
      }
    } catch (e) {
      print('Error fetching location details: $e');
      // فقط قم بتغيير العنوان إذا لم يكن هناك عنوان محفوظ بالفعل
      if (currentAddress.value == 'جاري تحديد الموقع...' ||
          currentAddress.value == 'موقع محفوظ') {
        currentAddress.value = 'لا يوجد اتصال بالشبكة';
      }
      // لا تقم بتعيين errorMessage هنا لمنع ظهور رسائل خطأ مزعجة في وضع عدم الاتصال
    }
    await savePreferences();
  }

  void fetchPrayerTimes({bool suppressErrors = false}) {
    if (latitude.value == 0.0 && longitude.value == 0.0) {
      if (!suppressErrors) {
        errorMessage.value = 'الموقع غير محدد. لا يمكن حساب أوقات الصلاة.';
      }
      return;
    }

    if (!suppressErrors) {
      errorMessage.value = '';
    }
    isLoading = true;
    // No need for update() here, as determinePosition already called it.
    try {
      final myCoordinates = Coordinates(latitude.value, longitude.value);
      final params = calculationMethod.value.getParameters();
      params.madhab = madhab.value;
      final prayerTimes = PrayerTimes.today(myCoordinates, params);

      prayerTimesData.clear();
      prayerTimesData['الفجر'] = _formatTime(prayerTimes.fajr);
      prayerTimesData['الشروق'] = _formatTime(prayerTimes.sunrise);
      prayerTimesData['الظهر'] = _formatTime(prayerTimes.dhuhr);
      prayerTimesData['العصر'] = _formatTime(prayerTimes.asr);
      prayerTimesData['المغرب'] = _formatTime(prayerTimes.maghrib);
      prayerTimesData['العشاء'] = _formatTime(prayerTimes.isha);

      // Store original times and apply adjustments
      originalPrayerTimes.value = Map.from(prayerTimesData);
      _applyAdjustments();

      print("Prayer times calculated successfully for ${currentAddress.value}");

      // **جديد**: تخزين أوقات الصلاة في قاعدة البيانات المحلية
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dbHelper = DatabaseHelper.instance;
      dbHelper.insertOrUpdatePrayerTimes(today, prayerTimesData);

      savePreferences();
    } catch (e) {
      print("Error calculating prayer times: $e");
      if (!suppressErrors) {
        errorMessage.value = 'حدث خطأ أثناء حساب أوقات الصلاة.';
      }
    } finally {
      isLoading = false;
      update();
    }
  }

  String _formatTime(DateTime time) {
    // We need to show the time in the device's local timezone, not UTC.
    // The adhan package returns times in UTC by default.
    final localTime = tz.TZDateTime.from(time, tz.local);
    return DateFormat('hh:mm a', 'ar').format(localTime);
  }

  void _applyAdjustments() {
    prayerTimeAdjustments.forEach((prayerName, adjustment) {
      if (originalPrayerTimes.containsKey(prayerName)) {
        final originalTimeStr = originalPrayerTimes[prayerName]!;
        final time = parseTimeOfDay(originalTimeStr);
        final originalDateTime = DateTime(2023, 1, 1, time.hour, time.minute);
        final adjustedDateTime = originalDateTime.add(
          Duration(minutes: adjustment),
        );
        prayerTimesData[prayerName] = _formatTime(adjustedDateTime);
      }
    });
  }

  void adjustPrayerTime(String prayerName, int minutes) {
    final currentAdjustment = prayerTimeAdjustments[prayerName] ?? 0;
    final newAdjustment = currentAdjustment + minutes;
    prayerTimeAdjustments[prayerName] = newAdjustment;

    // Apply adjustment to the displayed time
    if (originalPrayerTimes.containsKey(prayerName)) {
      final originalTimeStr = originalPrayerTimes[prayerName]!;
      final time = parseTimeOfDay(originalTimeStr);
      final originalDateTime = DateTime(2023, 1, 1, time.hour, time.minute);
      final adjustedDateTime = originalDateTime.add(
        Duration(minutes: newAdjustment),
      );
      prayerTimesData[prayerName] = _formatTime(adjustedDateTime);
    }
  }

  void setPrayerTimeAdjustment(String prayerName, int totalAdjustment) {
    prayerTimeAdjustments[prayerName] = totalAdjustment;

    // Apply adjustment to the displayed time
    if (originalPrayerTimes.containsKey(prayerName)) {
      final originalTimeStr = originalPrayerTimes[prayerName]!;
      final time = parseTimeOfDay(originalTimeStr);
      final originalDateTime = DateTime(2023, 1, 1, time.hour, time.minute);
      final adjustedDateTime = originalDateTime.add(
        Duration(minutes: totalAdjustment),
      );
      prayerTimesData[prayerName] = _formatTime(adjustedDateTime);
    }
    // We use update() to notify listeners of this specific change if needed,
    // especially for the dialog UI.
    update([prayerName]);
  }

  Future<void> saveAndApproveTimes() async {
    final prefs = await SharedPreferences.getInstance();
    // Save adjustments
    final adjustmentsJson = json.encode(prayerTimeAdjustments);
    await prefs.setString('prayerTimeAdjustments', adjustmentsJson);

    // Mark as approved
    isApproved.value = true;
    await prefs.setBool('prayerTimesApproved', true);

    // Reschedule notifications with the new times
    final bool hasPermission = await _checkAndRequestExactAlarmPermission();
    if (hasPermission) {
      await schedulePrayerTimeNotifications(
        enableVibration: _appSettingsController.vibrateOnNotification.value,
        playSound: _appSettingsController.prayerTimesNotificationsEnabled.value,
      );

      Get.snackbar(
        'تم الحفظ',
        'تم اعتماد التوقيتات الجديدة وجدولة الإشعارات.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> _checkAndRequestExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) {
      return true;
    }

    final requestedStatus = await Permission.scheduleExactAlarm.request();
    if (requestedStatus.isGranted) {
      return true;
    }

    // If denied, guide the user to settings.
    Get.snackbar(
      'الإذن مطلوب',
      'لتنبيهات أوقات الصلاة، يرجى تفعيل صلاحية "التنبيهات والتذكيرات".',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: () => openAppSettings(),
        child: const Text('الإعدادات'),
      ),
    );
    return false;
  }

  void onCalculationMethodChanged(CalculationMethod? method) {
    if (method != null) {
      calculationMethod.value = method;
      fetchPrayerTimes();
    }
  }

  void onJuristicSchoolChanged(Madhab? school) {
    if (school != null) {
      madhab.value = school;
      fetchPrayerTimes();
    }
  }

  Future<void> savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', latitude.value);
      await prefs.setDouble('longitude', longitude.value);
      await prefs.setString('calculationMethod', calculationMethod.value.name);
      await prefs.setString('madhab', madhab.value.name);
      await prefs.setString('currentAddress', currentAddress.value);
      await prefs.setBool('prayerTimesApproved', isApproved.value);

      // Save adjustments
      final adjustmentsJson = json.encode(
        prayerTimeAdjustments.map((key, value) => MapEntry(key, value)),
      );
      await prefs.setString('prayerTimeAdjustments', adjustmentsJson);

      print("Preferences saved.");
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      latitude.value = prefs.getDouble('latitude') ?? 0.0;
      longitude.value = prefs.getDouble('longitude') ?? 0.0;
      currentAddress.value =
          prefs.getString('currentAddress') ?? 'جاري تحديد الموقع...';
      isApproved.value = prefs.getBool('prayerTimesApproved') ?? false;

      // Load adjustments
      final adjustmentsJson = prefs.getString('prayerTimeAdjustments');
      if (adjustmentsJson != null) {
        final decodedMap = json.decode(adjustmentsJson) as Map<String, dynamic>;
        prayerTimeAdjustments.value = decodedMap.map(
          (key, value) => MapEntry(key, value as int),
        );
      }

      final savedMethod = prefs.getString('calculationMethod');
      if (savedMethod != null) {
        calculationMethod.value = CalculationMethod.values.firstWhere(
          (e) => e.name == savedMethod,
          orElse: () => CalculationMethod.muslim_world_league,
        );
      }

      final savedMadhab = prefs.getString('madhab');
      if (savedMadhab != null) {
        madhab.value = Madhab.values.firstWhere(
          (e) => e.name == savedMadhab,
          orElse: () => Madhab.shafi,
        );
      }
      print("Preferences loaded.");
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  Future<void> manualRefresh() async {
    await determinePosition();
  }

  // دالة جديدة لجلب الصلاة القادمة
  Map<String, dynamic> getNextPrayer() {
    final now = DateTime.now();
    final myCoordinates = Coordinates(latitude.value, longitude.value);
    final params = calculationMethod.value.getParameters();
    params.madhab = madhab.value;

    // حساب أوقات الصلاة لليوم الحالي واليوم التالي
    final todayPrayerTimes = PrayerTimes.today(myCoordinates, params);
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowDateComponents = DateComponents.from(tomorrow);
    final tomorrowPrayerTimes = PrayerTimes(
      myCoordinates,
      tomorrowDateComponents,
      params,
    );

    final prayerTimesList = [
      {'name': 'الفجر', 'time': todayPrayerTimes.fajr},
      {'name': 'الشروق', 'time': todayPrayerTimes.sunrise},
      {'name': 'الظهر', 'time': todayPrayerTimes.dhuhr},
      {'name': 'العصر', 'time': todayPrayerTimes.asr},
      {'name': 'المغرب', 'time': todayPrayerTimes.maghrib},
      {'name': 'العشاء', 'time': todayPrayerTimes.isha},
      // إضافة صلاة الفجر لليوم التالي كخيار أخير
      {'name': 'الفجر', 'time': tomorrowPrayerTimes.fajr},
    ];

    // تطبيق التعديلات اليدوية على أوقات الصلاة
    final adjustedPrayerTimes =
        prayerTimesList.map((p) {
          final prayerName = p['name'] as String;
          final prayerTime = p['time'] as DateTime;
          final adjustment = prayerTimeAdjustments[prayerName] ?? 0;
          return {
            'name': prayerName,
            'time': prayerTime.add(Duration(minutes: adjustment)),
          };
        }).toList();

    // البحث عن أول صلاة وقتها بعد الوقت الحالي
    for (final prayer in adjustedPrayerTimes) {
      final prayerTime = prayer['time'] as DateTime;
      if (prayerTime.isAfter(now)) {
        return prayer;
      }
    }

    // في حالة عدم وجود صلاة قادمة (وهو أمر غير محتمل بسبب إضافة فجر اليوم التالي)
    return {'name': 'غير معروف', 'time': null};
  }

  // --- Deprecated/Removed Methods ---
  // The following methods are no longer needed with the new local calculation approach.
  // - fetchCountries()
  // - onCountryChanged()
  // - fetchCoordinatesForCountry()
  // - The old fetchPrayerTimes() that used HTTP.
  // - The old _formatTime that parsed a string.
  // - The old maps for calculation methods and schools by integer.
  // تم إزالة الخصائص الوهمية (Dummy properties) لأن الواجهة (praytime.dart) لا تستخدمها.
  // RxString get selectedCountry => ''.obs;
  // RxList<String> get countries => <String>[].obs;
  Future<void> onCountryChanged(String country) async {
    // This is now handled by location services.
    Get.snackbar('ملاحظة', 'يتم تحديد الدولة تلقائياً عبر الموقع الجغرافي.');
  }
}
