import 'dart:async'; // تم إضافة هذا الاستيراد للتعامل مع StreamSubscription
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

class QiblaController extends GetxController {
  // إحداثيات الكعبة المشرفة
  static const double kaabaLat = 21.422487;
  static const double kaabaLong = 39.826206;
  static const double directionThreshold = 5.0; // هامش الخطأ بالدرجات

  // متغيرات الاتجاه والموقع
  RxDouble heading = 0.0.obs;
  RxDouble qiblaDirection = 0.0.obs;
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;
  RxBool isFacingQibla = false.obs;
  RxBool notificationPlayed = false.obs;

  // متغير لحفظ اشتراك البوصلة
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void onInit() {
    super.onInit();
    _initCompass(); // تهيئة مستمع البوصلة
    getCurrentLocation(); // الحصول على الموقع الأولي
  }

  // هذه الدالة تُستدعى تلقائيًا عند إزالة Controller من الذاكرة (مثل إغلاق الصفحة)
  @override
  void onClose() {
    _compassSubscription?.cancel(); // إلغاء الاشتراك في أحداث البوصلة
    print('Compass subscription cancelled.');
    // إعادة تعيين المتغيرات للحالة الأولية إذا لزم الأمر
    heading.value = 0.0;
    qiblaDirection.value = 0.0;
    latitude.value = 0.0;
    longitude.value = 0.0;
    isLoading.value = true;
    errorMessage.value = '';
    isFacingQibla.value = false;
    notificationPlayed.value = false;
    super.onClose();
  }

  void _initCompass() {
    // حفظ الاشتراك في المتغير
    _compassSubscription = FlutterCompass.events?.listen(
      (CompassEvent event) {
        double newHeading = event.heading ?? 0;
        heading.value = (newHeading + 360) % 360;

        print('Compass Heading: ${heading.value.toStringAsFixed(1)}°');

        _calculateQiblaDirection();
        _checkIfFacingQibla();
      },
      onError: (error) {
        errorMessage.value = 'تعذر الوصول إلى البوصلة: $error';
        isLoading.value = false;
        print('Compass Error: $error');
      },
    );
  }

  Future<void> getCurrentLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value =
            'تم تعطيل خدمات الموقع. يرجى تفعيلها من إعدادات جهازك.';
        isLoading.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          errorMessage.value =
              'تم رفض أذونات الموقع. يرجى منح الإذن للوصول إلى الموقع.';
          isLoading.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value =
            'تم رفض أذونات الموقع بشكل دائم. يرجى تمكينها يدويًا من إعدادات التطبيق.';
        isLoading.value = false;
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      print(
        'Current Location: Lat=${latitude.value.toStringAsFixed(4)}, Long=${longitude.value.toStringAsFixed(4)}',
      );

      _calculateQiblaDirection();
      isLoading.value = false;
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value =
          'تعذر الحصول على الموقع: ${e.toString()}. يرجى التأكد من اتصالك بالإنترنت.';
      isLoading.value = false;
      print('Location Error: $e');
    }
  }

  void _calculateQiblaDirection() {
    if (latitude.value == 0.0 || longitude.value == 0.0) return;

    double phiK = kaabaLat * pi / 180.0;
    double lambdaK = kaabaLong * pi / 180.0;
    double phi = latitude.value * pi / 180.0;
    double lambda = longitude.value * pi / 180.0;

    double psi =
        180.0 /
        pi *
        atan2(
          sin(lambdaK - lambda),
          cos(phi) * tan(phiK) - sin(phi) * cos(lambdaK - lambda),
        );

    qiblaDirection.value = (psi + 360) % 360;

    print(
      'Calculated Qibla Direction: ${qiblaDirection.value.toStringAsFixed(1)}°',
    );
  }

  void _checkIfFacingQibla() {
    double normalizedHeading = (heading.value + 360) % 360;
    double normalizedQibla = (qiblaDirection.value + 360) % 360;

    double difference = (normalizedQibla - normalizedHeading).abs();
    difference = difference > 180 ? 360 - difference : difference;

    bool facing = difference <= directionThreshold;

    if (facing && !isFacingQibla.value) {
      _triggerHapticFeedback();
    } else if (!facing && isFacingQibla.value) {
      notificationPlayed.value = false;
    }

    isFacingQibla.value = facing;
  }

  void _triggerHapticFeedback() async {
    if (notificationPlayed.value) return;

    notificationPlayed.value = true;

    bool hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(duration: 500);
    }
  }
}
