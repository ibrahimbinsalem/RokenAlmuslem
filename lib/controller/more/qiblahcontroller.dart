// import 'dart:async';
// import 'package:get/get.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_qiblah/flutter_qiblah.dart';
// import 'dart:math' show pi; // لاستخدام قيمة باي

// class QiblaController extends GetxController {
//   // يمثل اتجاه القبلة بالنسبة للشمال الحقيقي، وheading هو اتجاه الجهاز
//   Rx<QiblahDirection?> qiblahDirection = Rx<QiblahDirection?>(null);
//   RxString statusMessage = "جاري تهيئة المستشعرات...".obs;
//   RxBool isLoading = true.obs;
//   RxBool isPermissionGranted = false.obs;
//   RxBool hasSensor = true.obs;

//   StreamSubscription<QiblahDirection>? _qiblahSubscription;

//   @override
//   void onInit() {
//     super.onInit();
//     _checkLocationPermission();
//   }

//   @override
//   void onClose() {
//     _qiblahSubscription?.cancel();
//     super.onClose();
//   }

//   Future<void> _checkLocationPermission() async {
//     // التحقق من توفر مستشعر البوصلة (حزمة flutter_qiblah تتولى ذلك أيضاً)
//     // *** هذا هو السطر الذي تم تصحيحه الآن ***
//     bool? compassAvailable = await FlutterQiblah.androidDeviceSensorSupport();
//     if (compassAvailable == false) {
//       hasSensor.value = false;
//       statusMessage.value = "لا يوجد مستشعر بوصلة أو جيروسكوب في جهازك.";
//       isLoading.value = false;
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         statusMessage.value = "صلاحيات الموقع مرفوضة. لا يمكن تحديد القبلة.";
//         isPermissionGranted.value = false;
//         isLoading.value = false;
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       statusMessage.value = "صلاحيات الموقع مرفوضة بشكل دائم. يرجى تفعيلها يدوياً من الإعدادات.";
//       isPermissionGranted.value = false;
//       isLoading.value = false;
//       return;
//     }

//     if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
//       isPermissionGranted.value = true;
//       statusMessage.value = "تمت الموافقة على صلاحيات الموقع. جاري تحديد القبلة...";
//       _startQiblahListening();
//     } else {
//       // هذه الحالة يجب أن لا تحدث إذا كانت حالات الرفض معالجة
//       statusMessage.value = "حالة غير متوقعة للأذونات.";
//       isLoading.value = false;
//     }
//   }

//   void _startQiblahListening() {
//     isLoading.value = true;
//     _qiblahSubscription = FlutterQiblah.qiblahStream.listen((qiblahData) {
//       qiblahDirection.value = qiblahData;
//       isLoading.value = false;
//       statusMessage.value = "قم بتدوير جهازك حتى يشير السهم للأعلى نحو القبلة.";
//     }, onError: (error) {
//       print("Error in Qiblah Stream: $error");
//       statusMessage.value = "حدث خطأ أثناء تحديد القبلة: ${error.toString()}";
//       isLoading.value = false;
//     });
//   }

//   // دالة لإعادة المحاولة (مثلاً بعد رفض الأذونات)
//   void retryQiblaDetection() {
//     isLoading.value = true;
//     statusMessage.value = "جاري إعادة المحاولة...";
//     qiblahDirection.value = null; // إعادة تعيين البيانات
//     _checkLocationPermission(); // ابدأ العملية من جديد
//   }
// }