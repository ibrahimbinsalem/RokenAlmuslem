import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

// App imports
import 'package:rokenalmuslem/bindings/initialbinding.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/localization/changelocal.dart';
import 'package:rokenalmuslem/core/localization/translation.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/core/services/services.dart';
import 'package:rokenalmuslem/core/theme/app_theme.dart';
import 'package:rokenalmuslem/data/database/database_helper.dart';
import 'package:rokenalmuslem/rout.dart'; // هذا الملف يجب أن يحتوي على قائمة المسارات
import 'package:rokenalmuslem/view/screen/more/aboutbage.dart'; // استيراد صفحة حول التطبيق والمطورين
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart'; // **استيراد PrayerTimesController**
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rokenalmuslem/core/services/firebase_messaging_handler.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint("Background task executing: $taskName");

    try {
      final dbHelper = DatabaseHelper.instance;

      if (taskName == "resetAdkarCountersTask") {
        debugPrint("Resetting adkar counters in background...");
        await _resetAllAdkarCounters(dbHelper);
        await _sendResetNotification();
        return true;
      }

      return false;
    } catch (e, stack) {
      debugPrint("Task Error: $e\n$stack");
      return false;
    }
  });
}

Future<void> main() async {
  await _initializeApp();
  await initializeDateFormatting('ar');
  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // جعل عمليات Firebase Messaging غير معرقلة لبدء التشغيل
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint("========================================");
      debugPrint("FCM Token: $fcmToken");
      debugPrint("========================================");
      // Attempt to subscribe to a topic, but don't let it block startup if it fails.
      FirebaseMessaging.instance
          .subscribeToTopic('all_users')
          .then((_) {
            debugPrint("Successfully subscribed to 'all_users' topic");
          })
          .catchError((e) {
            debugPrint("Failed to subscribe to 'all_users' topic: $e");
          });
    } catch (e) {
      debugPrint("Firebase Messaging setup failed (likely offline): $e");
      // لا تقم بإعادة رمي الخطأ، اسمح للتطبيق بالاستمرار
    }
    await GetStorage.init();
    await initialServices();

    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    // Open Hive boxes
    await Future.wait([
      Hive.openBox('quranData'),
      Hive.openBox('quranSettings'),
    ]);

    // **1. Initialize NotificationService first as other controllers depend on it**
    final notificationService = NotificationService();
    await notificationService.initialize();
    Get.put(notificationService, permanent: true);

    try {
      await FirebaseMessaging.instance.requestPermission();
      await notificationService.requestPermissions();
    } catch (e) {
      debugPrint("Notification permission request failed: $e");
    }

    final messagingHandler = FirebaseMessagingHandler();
    await messagingHandler.initialize();
    Get.put(messagingHandler, permanent: true);

    // **2. Initialize PrayerTimesController using Get.putAsync**
    // This ensures its async onInit (location, prayer times fetch) completes
    await Get.putAsync<PrayerTimesController>(() async {
      final controller = PrayerTimesController();
      // onInit will be called automatically, which handles async initialization
      return controller;
    }, permanent: true);

    // **3. Initialize AppSettingsController synchronously**
    // It will find the already initialized PrayerTimesController when needed.
    Get.put<AppSettingsController>(AppSettingsController(), permanent: true);

    // Initialize Workmanager
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await _scheduleBackgroundTasks();
  } catch (e, stack) {
    debugPrint("App Initialization Error: $e\n$stack");
    rethrow;
  }
}

Future<void> _resetAllAdkarCounters(DatabaseHelper dbHelper) async {
  final tables = [
    DatabaseHelper.morningAdkarTableName,
    DatabaseHelper.eveningAdkarTableName,
    DatabaseHelper.adkarSalatTableName,
    DatabaseHelper.adkarAfterSalatTableName,
    DatabaseHelper.adkarHomeTableName,
    DatabaseHelper.adkarAlnomTableName,
    DatabaseHelper.adkarAladanTableName,
    DatabaseHelper.adkarAlmasjidTableName,
    DatabaseHelper.adkarAlastygadTableName,
    DatabaseHelper.adkarAlwswiTableName,
    DatabaseHelper.adkarAlkhlaTableName,
    DatabaseHelper.adkarEatTableName,
    DatabaseHelper.adayahForDeadTableName,
    DatabaseHelper.asmaAllahTableName,
    DatabaseHelper.fadelAlDuaaTableName,
    DatabaseHelper.adayaQuraniyaTableName,
    DatabaseHelper.ruqyahsTableName,
  ];

  for (final table in tables) {
    await dbHelper.resetAllDhikrCountsToInitial(table);
  }
}

Future<void> _sendResetNotification() async {
  try {
    final notificationService = Get.find<NotificationService>();
    await notificationService.showNotification(
      title: "تم إعادة تعيين الأذكار",
      body: "تم إعادة تعيين جميع عدادات الأذكار بنجاح",
      payload: "reset_completed",
    );
  } catch (e, stack) {
    debugPrint("Notification Error: $e\n$stack");
  }
}

Future<void> _scheduleBackgroundTasks() async {
  try {
    await Workmanager().registerPeriodicTask(
      "resetAdkarCountersDaily",
      "resetAdkarCountersTask",
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(minutes: 5),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  } catch (e, stack) {
    debugPrint("Task Scheduling Error: $e\n$stack");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalController>(
      init: LocalController(),
      builder: (localeController) {
        return GetX<AppSettingsController>(
          builder: (appSettings) {
            final myServices = Get.find<MyServices>();

            final darkMode = appSettings.darkModeEnabled.value;
            final fontSizeMultiplier = appSettings.fontSizeMultiplier.value;

            // بناء الثيمات باستخدام القيم الديناميكية
            final lightTheme = AppTheme.light(fontSizeMultiplier);
            final darkTheme = AppTheme.dark(fontSizeMultiplier);

            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'روكن المسلم',
              theme: lightTheme, // الثيم الفاتح
              darkTheme: darkTheme, // الثيم الداكن
              themeMode:
                  darkMode
                      ? ThemeMode.dark
                      : ThemeMode.light, // لتغيير الوضع الليلي
              translations: MyTranslation(),
              locale: localeController.locale.value ?? const Locale('ar'),
              fallbackLocale: const Locale('ar'),
              initialRoute: _getInitialRoute(myServices),
              getPages: routes, // قائمة المسارات الخاصة بك
              initialBinding: InitialBindings(),
              builder: (context, child) {
                return Directionality(
                  textDirection:
                      localeController.locale.value?.languageCode == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }

  String _getInitialRoute(MyServices services) {
    return "/"; // دع الوسيط (Middleware) يقرر المسار الصحيح
  }
}
