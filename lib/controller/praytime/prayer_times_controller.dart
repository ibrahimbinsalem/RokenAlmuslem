import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class PrayerTimesController extends GetxController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentCountry = 'غير محدد'.obs;
  final RxMap<String, String> prayerTimesData = <String, String>{}.obs;
  final RxList<String> countries = <String>[].obs;
  final RxString selectedCountry = ''.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  final RxInt selectedCalculationMethod = 2.obs;
  final RxInt selectedJuristicSchool = 0.obs;

  final Map<int, String> calculationMethods = {
    0: 'Shia Ithna-Ashari',
    1: 'University of Islamic Sciences, Karachi',
    2: 'Muslim World League',
    3: 'Umm Al-Qura University, Makkah',
    4: 'Egyptian General Authority of Survey',
    5: 'Institute of Geophysics, University of Tehran',
    7: 'Islamic University, Damascus',
    8: 'Islamic Community Centre of Kologne',
    9: 'Union Of Islamic Organisations of France',
    10: 'Ministry of Religious Affairs, Tunisia',
    11: 'Grand Cairo',
    12: 'Unified Islamic Committee of Europe',
    13: 'Diyanet İşleri Başkanlığı, Turkey',
    14: 'Spiritual Administration of Muslims of Russia',
    15: 'Moonsighting Committee Worldwide (MCW)',
    16: 'Dubai',
    17: 'Qatar',
    18: 'Kuwait',
    19: 'North America (ISNA)',
    20: 'Singapore',
    21: 'France (UOIF - Angle 18)',
    22: 'France (UOIF - Angle 19)',
    23: 'France (Mosque of Paris)',
    24: 'Morocco (Habous)',
    25: 'Algeria',
    26: 'Libya',
    99: 'Other',
  };

  final Map<int, String> juristicSchools = {
    0: 'Shafi, Hanbali, Maliki',
    1: 'Hanafi',
  };

  @override
  void onInit() async {
    super.onInit();
    await _configureLocalTimeZone();
    await _initializeNotifications();
    await loadPreferences();
    await fetchCountries();

    if (latitude.value != 0.0 && longitude.value != 0.0) {
      await fetchPrayerTimes();
    } else {
      await determinePosition();
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz_data.initializeTimeZones(); // تم التصحيح هنا
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print('Error setting timezone: $e');
      tz.setLocalLocation(tz.getLocation('UTC')); // Fallback to UTC
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification payload: ${response.payload}');
      },
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> _schedulePrayerTimeNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();

    int notificationId = 0;
    for (var entry in prayerTimesData.entries) {
      final prayerName = entry.key;
      final prayerTime = entry.value;

      final now = tz.TZDateTime.now(tz.local);
      final timeParts = prayerTime.split(':');
      if (timeParts.length != 2) continue;

      try {
        final prayerHour = int.parse(timeParts[0]);
        final prayerMinute = int.parse(timeParts[1]);

        tz.TZDateTime scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          prayerHour,
          prayerMinute,
        );

        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
              'prayer_times_channel',
              'أوقات الصلاة',
              channelDescription: 'إشعارات لتذكيرك بأوقات الصلاة',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false,
            );

        const DarwinNotificationDetails iOSPlatformChannelSpecifics =
            DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(
              android: androidPlatformChannelSpecifics,
              iOS: iOSPlatformChannelSpecifics,
            );

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId++,
          'حان وقت صلاة $prayerName',
          'تقبل الله منا ومنكم صالح الأعمال.',
          scheduledDate,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'prayer_time_notification',
        );
      } catch (e) {
        print('Error scheduling notification for $prayerName: $e');
      }
    }
  }

  // باقي الدوال كما هي بدون تغيير...
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
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      await fetchCountryFromCoordinates(position.latitude, position.longitude);
      await fetchPrayerTimes();
    } catch (e) {
      errorMessage.value = 'فشل في تحديد الموقع: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCountryFromCoordinates(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        currentCountry.value = address['country'] ?? 'غير معروف';
        selectedCountry.value = currentCountry.value;
        await savePreferences();
      }
    } catch (e) {
      errorMessage.value = 'فشل في تحديد الدولة من الإحداثيات';
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
              ..sort(),
          );
        } else {
          errorMessage.value = 'هيكلة البيانات غير متوقعة';
        }
      } else {
        errorMessage.value = 'فشل في جلب الدول: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'حدث خطأ في جلب الدول: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPrayerTimes() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (latitude.value == 0.0 && longitude.value == 0.0) {
        errorMessage.value = 'يرجى تحديد الموقع أو السماح بالوصول إليه.';
        return;
      }

      final Uri uri = Uri.parse(
        'http://api.aladhan.com/v1/timings?latitude=${latitude.value}&longitude=${longitude.value}&method=${selectedCalculationMethod.value}&school=${selectedJuristicSchool.value}',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['timings'] != null) {
          final timings = data['data']['timings'];

          prayerTimesData.clear();
          prayerTimesData['الفجر'] = timings['Fajr'];
          prayerTimesData['الشروق'] = timings['Sunrise'];
          prayerTimesData['الظهر'] = timings['Dhuhr'];
          prayerTimesData['العصر'] = timings['Asr'];
          prayerTimesData['المغرب'] = timings['Maghrib'];
          prayerTimesData['العشاء'] = timings['Isha'];
          prayerTimesData['منتصف الليل'] = timings['Midnight'] ?? 'N/A';

          await savePreferences();
          await _schedulePrayerTimeNotifications();
        } else {
          errorMessage.value = 'لا توجد بيانات أوقات صلاة متاحة لهذا الموقع.';
        }
      } else {
        errorMessage.value = 'فشل في جلب أوقات الصلاة: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'حدث خطأ في جلب أوقات الصلاة: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onCountryChanged(String country) async {
    selectedCountry.value = country;
    await fetchCoordinatesForCountry();
    await fetchPrayerTimes();
  }

  void onCalculationMethodChanged(int method) async {
    selectedCalculationMethod.value = method;
    await savePreferences();
    await fetchPrayerTimes();
  }

  void onJuristicSchoolChanged(int school) async {
    selectedJuristicSchool.value = school;
    await savePreferences();
    await fetchPrayerTimes();
  }

  Future<void> fetchCoordinatesForCountry() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?country=${Uri.encodeComponent(selectedCountry.value)}&format=json&limit=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          latitude.value = double.parse(data[0]['lat']);
          longitude.value = double.parse(data[0]['lon']);
        } else {
          errorMessage.value = 'لم يتم العثور على إحداثيات للدولة المحددة.';
        }
      } else {
        errorMessage.value =
            'فشل في جلب إحداثيات الدولة: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'حدث خطأ في تحديد إحداثيات الدولة: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCountry', selectedCountry.value);
    await prefs.setDouble('latitude', latitude.value);
    await prefs.setDouble('longitude', longitude.value);
    await prefs.setInt(
      'selectedCalculationMethod',
      selectedCalculationMethod.value,
    );
    await prefs.setInt('selectedJuristicSchool', selectedJuristicSchool.value);
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCountry.value = prefs.getString('selectedCountry') ?? '';
    latitude.value = prefs.getDouble('latitude') ?? 0.0;
    longitude.value = prefs.getDouble('longitude') ?? 0.0;
    selectedCalculationMethod.value =
        prefs.getInt('selectedCalculationMethod') ?? 2;
    selectedJuristicSchool.value = prefs.getInt('selectedJuristicSchool') ?? 0;
  }

  Future<void> manualRefresh() async {
    await fetchPrayerTimes();
  }
}
