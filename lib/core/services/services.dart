import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rokenalmuslem/controller/notificationcontroller.dart';
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';

// If you want to use Firebase in the future
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

class MyServices extends GetxService {
  late SharedPreferences sharedprf;

  Future<MyServices> init() async {
    print('Initializing MyServices...');

    // Here you can add Firebase initialization if you uncommented it
    // Make sure to import 'package:firebase_core/firebase_core.dart';
    // and provide the correct FirebaseOptions
    // await Firebase.initializeApp();

    sharedprf = await SharedPreferences.getInstance();
    print('SharedPreferences initialized in MyServices.');
    return this;
  }
}

// This function registers MyServices in GetX
initialServices() async {
  // تهيئة الخدمات الأساسية التي لا تعتمد على خدمات أخرى
  await Get.putAsync(() => MyServices().init());
  // **الإصلاح**: استخدام putAsync لتهيئة خدمة الإشعارات والتأكد من اكتمالها
  await Get.putAsync<NotificationService>(() async {
    final service = NotificationService();
    await service.initialize();
    return service;
  });

  // تهيئة المتحكمات التي تعتمد على الخدمات السابقة
  // الترتيب مهم هنا
  Get.put(PrayerTimesController());
  Get.put(AppSettingsController());

  // NotificationsController يعتمد على كل ما سبق
  Get.put(NotificationsController());
  print("All core services and controllers have been initialized.");
}
