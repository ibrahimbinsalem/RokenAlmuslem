import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart'; // استيراد مكتبة intl

// استيراد NotificationService
import 'package:rokenalmuslem/core/services/localnotification.dart';

class PrayerTimesController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentCountry = 'غير محدد'.obs;
  final RxMap<String, String> prayerTimesData = <String, String>{}.obs;
  final RxList<String> countries = <String>[].obs;
  final RxString selectedCountry = ''.obs;
  final RxString selectedCity = ''.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  final RxInt selectedCalculationMethod = 2.obs;
  final RxInt selectedJuristicSchool = 0.obs;
  final RxInt timeAdjustment = 0.obs; // التعديل بالدقائق لليمن

  late NotificationService _notificationService;

  // معرفات الإشعارات الثابتة لأوقات الصلاة
  // (نفس المعرفات في AppSettingsController لضمان التناسق)
  static const int prayerFajrId = 1000;
  static const int prayerSunriseId = 1001;
  static const int prayerDhuhrId = 1002;
  static const int prayerAsrId = 1003;
  static const int prayerMaghribId = 1004;
  static const int prayerIshaId = 1005;

  final Map<int, String> calculationMethods = {
    0: 'الشيعة الاثنا عشرية',
    1: 'جامعة العلوم الإسلامية، كراتشي',
    2: 'رابطة العالم الإسلامي',
    3: 'جامعة أم القرى، مكة',
    4: 'هيئة المساحة المصرية',
    5: 'معهد الجيوفيزياء، جامعة طهران',
    7: 'الجامعة الإسلامية، دمشق',
    8: 'مركز الجالية الإسلامية، كولونيا',
    9: 'اتحاد الجمعيات الإسلامية لفرنسا',
    10: 'وزارة الشؤون الدينية، تونس',
    11: 'القاهرة الكبرى',
    12: 'اللجنة الإسلامية الموحدة لأوروبا',
    13: 'ديانيت işleri başkanlığı، تركيا',
    14: 'إدارة شؤون المسلمين في روسيا',
    15: 'لجنة رؤية الهلال العالمية (MCW)',
    16: 'دبي',
    17: 'قطر',
    18: 'الكويت',
    19: 'أمريكا الشمالية (ISNA)',
    20: 'سنغافورة',
    21: 'فرنسا (UOIF - زاوية 18)',
    22: 'فرنسا (UOIF - زاوية 19)',
    23: 'فرنسا (مسجد باريس)',
    24: 'المغرب (هيئة الحبوس)',
    25: 'الجزائر',
    26: 'ليبيا',
    99: 'أخرى',
  };

  final Map<int, String> juristicSchools = {
    0: 'شافعي، حنبلي، مالكي',
    1: 'حنفي',
  };

  @override
  void onInit() async {
    super.onInit();
    _notificationService = Get.find<NotificationService>();
    await _configureLocalTimeZone();
    await loadPreferences();
    await fetchCountries();

    if (selectedCountry.value.isEmpty ||
        selectedCountry.value.contains('اليمن')) {
      selectedCalculationMethod.value = 2;
      selectedJuristicSchool.value = 0;
      timeAdjustment.value = 60;
    }

    if (latitude.value == 0.0 || longitude.value == 0.0) {
      await determinePosition();
    } else {
      await fetchPrayerTimes();
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Aden'));
    }
  }

  // دالة عامة لجدولة جميع تنبيهات أوقات الصلاة (يتم استدعاؤها من AppSettingsController)
  Future<void> schedulePrayerTimeNotifications({required bool enableVibration, required bool playSound}) async {
    // Note: cancellation logic is handled by AppSettingsController's _syncNotificationsState
    // which calls cancelAllNotifications() for ALL notifications before re-scheduling enabled ones.
    // So, we don't need to cancel here if AppSettingsController manages it globally.

    if (prayerTimesData.isNotEmpty) {
      // تعريف الصلوات بالترتيب المنطقي والاسم العربي ومعرفاتها
      final List<Map<String, dynamic>> prayersToSchedule = [
        {'name': 'الفجر', 'time': prayerTimesData['الفجر']!, 'id': prayerFajrId, 'type': 'prayerFajr'},
        {'name': 'الشروق', 'time': prayerTimesData['الشروق']!, 'id': prayerSunriseId, 'type': 'prayerSunrise'},
        {'name': 'الظهر', 'time': prayerTimesData['الظهر']!, 'id': prayerDhuhrId, 'type': 'prayerDhuhr'},
        {'name': 'العصر', 'time': prayerTimesData['العصر']!, 'id': prayerAsrId, 'type': 'prayerAsr'},
        {'name': 'المغرب', 'time': prayerTimesData['المغرب']!, 'id': prayerMaghribId, 'type': 'prayerMaghrib'},
        {'name': 'العشاء', 'time': prayerTimesData['العشاء']!, 'id': prayerIshaId, 'type': 'prayerIsha'},
      ];

      for (var prayer in prayersToSchedule) {
        await _notificationService.scheduleDailyReminder(
          id: prayer['id'],
          title: 'حان وقت صلاة ${prayer['name']}',
          body: 'تقبل الله منا ومنكم صالح الأعمال',
          time: _parseTimeOfDay(prayer['time']),
          payload: json.encode({ // Include structured payload
            'type': prayer['type'], // Specific prayer type
            'prayerName': prayer['name'], // Arabic prayer name
          }),
      
        );
      }
      print('Prayer time notifications scheduled by PrayerTimesController.');
    } else {
      print('Prayer times data is empty, cannot schedule notifications.');
    }
  }
  
  // دالة لإلغاء جميع إشعارات أوقات الصلاة المجدولة (من خلال معرفاتها المعروفة)
  Future<void> cancelAllPrayerTimeNotifications() async {
    await _notificationService.cancelNotification(prayerFajrId);
    await _notificationService.cancelNotification(prayerSunriseId);
    await _notificationService.cancelNotification(prayerDhuhrId);
    await _notificationService.cancelNotification(prayerAsrId);
    await _notificationService.cancelNotification(prayerMaghribId);
    await _notificationService.cancelNotification(prayerIshaId);
    print('Cancelled all specific prayer time notifications.');
  }

  // دالة مساعدة لتحويل الوقت من "HH:MM ص/م" أو "HH:MM" إلى TimeOfDay
  TimeOfDay _parseTimeOfDay(String timeString) {
    try {
      DateFormat format24hr = DateFormat('HH:mm');
      DateTime tempTime = format24hr.parse(timeString.split(' ')[0]);
      return TimeOfDay.fromDateTime(tempTime);
    } catch (_) {
      DateFormat format12hrAmPm = DateFormat('hh:mm a', 'ar');
      DateTime tempTime = format12hrAmPm.parse(timeString);
      return TimeOfDay.fromDateTime(tempTime);
    }
  }

  Future<void> determinePosition() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value = 'خدمة الموقع معطلة. يرجى تفعيلها';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage.value = 'تم رفض صلاحيات الموقع';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'صلاحيات الموقع مرفوضة بشكل دائم';
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      if (position.latitude == 0.0 && position.longitude == 0.0) {
        latitude.value = 15.3694; // Sana'a default
        longitude.value = 44.1910;
        selectedCountry.value = 'اليمن';
      } else {
        latitude.value = position.latitude;
        longitude.value = position.latitude; // Should be position.longitude
      }

      await fetchLocationDetails(latitude.value, longitude.value);
      await fetchPrayerTimes();
    } catch (e) {
      latitude.value = 15.3694; // Sana'a default
      longitude.value = 44.1910;
      selectedCountry.value = 'اليمن';
      errorMessage.value = 'تم استخدام موقع صنعاء الافتراضي. خطأ: $e';
      await fetchPrayerTimes();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLocationDetails(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10&addressdetails=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        currentCountry.value = address['country'] ?? 'غير محدد';
        selectedCountry.value = currentCountry.value;
        selectedCity.value =
            address['city'] ?? address['town'] ?? address['village'] ?? '';

        if (selectedCountry.value.contains('اليمن')) {
          selectedCalculationMethod.value = 2;
          selectedJuristicSchool.value = 0;
          timeAdjustment.value = 60;
        }

        await savePreferences();
      }
    } catch (e) {
      print('Error fetching location details: $e');
    }
  }

  Future<void> fetchCountries() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          countries.assignAll(
            data
                .map((item) => item['name']['common'].toString())
                .where((name) => name.isNotEmpty)
                .toList()
              ..sort((a, b) => a.compareTo(b)),
          );

          if (!countries.contains('Yemen')) {
            countries.add('Yemen');
            countries.sort();
          }
        }
      } else {
        errorMessage.value = 'فشل في جلب قائمة الدول';
      }
    } catch (e) {
      errorMessage.value = 'حدث خطأ في جلب الدول: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPrayerTimes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      int method = selectedCalculationMethod.value;
      if (selectedCountry.value.contains('اليمن')) {
        method = 2;
      }

      final response = await http.get(
        Uri.parse(
          'http://api.aladhan.com/v1/timings?latitude=${latitude.value}&longitude=${longitude.value}&method=$method&school=${selectedJuristicSchool.value}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['timings'] != null) {
          final timings = data['data']['timings'];
          prayerTimesData.clear();

          final apiPrayerNames = {
            'Fajr': 'الفجر',
            'Sunrise': 'الشروق',
            'Dhuhr': 'الظهر',
            'Asr': 'العصر',
            'Maghrib': 'المغرب',
            'Isha': 'العشاء',
          };

          if (selectedCountry.value.contains('اليمن')) {
            apiPrayerNames.forEach((key, value) {
              if (timings.containsKey(key)) {
                prayerTimesData[value] = _adjustTime(
                  timings[key],
                  timeAdjustment.value,
                );
              }
            });
          } else {
            apiPrayerNames.forEach((key, value) {
              if (timings.containsKey(key)) {
                prayerTimesData[value] = _formatTime(timings[key]);
              }
            });
          }
          await savePreferences();
        }
      } else {
        errorMessage.value = 'فشل في جلب أوقات الصلاة: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'حدث خطأ في جلب أوقات الصلاة: $e';
    } finally {
      isLoading.value = false;
    }
  }

  String _adjustTime(String time, int minutesToAdd) {
    try {
      DateFormat apiFormat = DateFormat('HH:mm');
      DateTime parsedDateTime = apiFormat.parse(time);
      parsedDateTime = parsedDateTime.add(Duration(minutes: minutesToAdd));
      return DateFormat('hh:mm a', 'ar').format(parsedDateTime);
    } catch (e) {
      print('Error adjusting time: $e');
      return time;
    }
  }

  String _formatTime(String time) {
    try {
      DateFormat apiFormat = DateFormat('HH:mm');
      DateTime parsedDateTime = apiFormat.parse(time);
      return DateFormat('hh:mm a', 'ar').format(parsedDateTime);
    } catch (e) {
      print('Error formatting time: $e');
      return time;
    }
  }

  Future<void> onCountryChanged(String country) async {
    selectedCountry.value = country;
    selectedCity.value = '';
    await savePreferences();

    if (country.contains('اليمن')) {
      selectedCalculationMethod.value = 2;
      selectedJuristicSchool.value = 0;
      timeAdjustment.value = 60;
    } else {
      timeAdjustment.value = 0;
      selectedCalculationMethod.value = 2;
      selectedJuristicSchool.value = 0;
    }
    await fetchCoordinatesForCountry();
  }

  Future<void> fetchCoordinatesForCountry() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      String query = selectedCountry.value;
      if (selectedCity.isNotEmpty) {
        query = '$query, $selectedCity';
      }

      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          latitude.value = double.parse(data[0]['lat']);
          longitude.value = double.parse(data[0]['lon']);
          await savePreferences();
          await fetchPrayerTimes();
        } else {
          errorMessage.value = 'لم يتم العثور على إحداثيات للدولة/المدينة المحددة.';
        }
      } else {
        errorMessage.value = 'فشل في تحديد الإحداثيات: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'حدث خطأ في تحديد الإحداثيات: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedCountry', selectedCountry.value);
      await prefs.setString('selectedCity', selectedCity.value);
      await prefs.setDouble('latitude', latitude.value);
      await prefs.setDouble('longitude', longitude.value);
      await prefs.setInt(
        'selectedCalculationMethod',
        selectedCalculationMethod.value,
      );
      await prefs.setInt(
        'selectedJuristicSchool',
        selectedJuristicSchool.value,
      );
      await prefs.setInt('timeAdjustment', timeAdjustment.value);

      if (prayerTimesData.isNotEmpty) {
        await prefs.setString('prayerTimesData', json.encode(prayerTimesData));
      }
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      selectedCountry.value = prefs.getString('selectedCountry') ?? '';
      selectedCity.value = prefs.getString('selectedCity') ?? '';
      latitude.value = prefs.getDouble('latitude') ?? 0.0;
      longitude.value = prefs.getDouble('longitude') ?? 0.0;
      selectedCalculationMethod.value =
          prefs.getInt('selectedCalculationMethod') ?? 2;
      selectedJuristicSchool.value =
          prefs.getInt('selectedJuristicSchool') ?? 0;
      timeAdjustment.value = prefs.getInt('timeAdjustment') ?? 0;

      final savedTimes = prefs.getString('prayerTimesData');
      if (savedTimes != null) {
        prayerTimesData.assignAll(
          Map<String, String>.from(json.decode(savedTimes)),
        );
      }
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }

  void updateTimeAdjustment(int minutes) {
    timeAdjustment.value = minutes;
    savePreferences();
    fetchPrayerTimes();
  }

  Future<void> manualRefresh() async {
    await fetchPrayerTimes();
  }
}
