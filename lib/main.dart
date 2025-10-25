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
import 'package:rokenalmuslem/data/database/database_helper.dart';
import 'package:rokenalmuslem/rout.dart'; // هذا الملف يجب أن يحتوي على قائمة المسارات
import 'package:rokenalmuslem/view/screen/more/aboutbage.dart'; // استيراد صفحة حول التطبيق والمطورين
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart'; // **استيراد PrayerTimesController**

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

    // **2. Initialize PrayerTimesController using Get.putAsync**
    // This ensures its async onInit (location, prayer times fetch) completes
    await Get.putAsync<PrayerTimesController>(() async {
      final controller = PrayerTimesController();
      // onInit will be called automatically, which handles async initialization
      return controller;
    }, permanent: true);

    // **3. Initialize AppSettingsController using Get.putAsync**
    // This ensures its async onInit (SharedPreferences load) completes
    await Get.putAsync<AppSettingsController>(() async {
      final controller = AppSettingsController();
      // onInit will be called automatically, which handles async initialization
      return controller;
    }, permanent: true);

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
            final lightTheme = _buildTheme(fontSizeMultiplier, false);
            final darkTheme = _buildTheme(fontSizeMultiplier, true);

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
    return services.sharedprf.getBool('hasSeenOnboarding') ?? false
        ? AppRoute.homePage
        : AppRoute.onBording;
  }

  ThemeData _buildTheme(double fontSizeMultiplier, bool isDark) {
    // الألوان الرئيسية التي تم اختيارها
    const Color primaryColor = Color(0xFF0A84FF); // لون أزرق زاهي
    const Color darkSurface = Color(0xFF1C1C1E); // خلفية أسطح داكنة
    const Color lightSurface = Colors.white; // خلفية أسطح فاتحة
    const Color darkBackground = Color(0xFF121212); // خلفية أغمق
    const Color lightBackground = Color(0xFFF2F2F7); // خلفية فاتحة جداً
    const Color cardColorDark = Color(0xFF282828); // لون بطاقات في الوضع الداكن

    final Brightness brightness = isDark ? Brightness.dark : Brightness.light;
    final Color onSurfaceColor = isDark ? Colors.white70 : Colors.black87;
    final Color onBackgroundColor = isDark ? Colors.white : Colors.black;
    final Color textColor = isDark ? Colors.white : Colors.black;

    final TextTheme customTextTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 32 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: 22 * fontSizeMultiplier,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20 * fontSizeMultiplier,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: 17 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: 15 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * fontSizeMultiplier,
        color: onSurfaceColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * fontSizeMultiplier,
        color: onSurfaceColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12 * fontSizeMultiplier,
        color: onSurfaceColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * fontSizeMultiplier,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12 * fontSizeMultiplier,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: 10 * fontSizeMultiplier,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: const Color(0xFF34C759),
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
        background: isDark ? darkBackground : lightBackground,
        onBackground: onBackgroundColor,
        surface: isDark ? darkSurface : lightSurface,
        onSurface: onSurfaceColor,
      ),
      cardColor: isDark ? cardColorDark : Colors.white,
      appBarTheme: AppBarTheme(
        elevation: 8,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: customTextTheme.headlineLarge!.copyWith(
          color: Colors.white,
          fontSize: 24 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textTheme: customTextTheme,
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? cardColorDark : Colors.white,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return (isDark ? Colors.white : Colors.black).withOpacity(0.6);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return (isDark ? Colors.white : Colors.black).withOpacity(0.2);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: (isDark ? Colors.white : Colors.black).withOpacity(
          0.3,
        ),
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.2),
        valueIndicatorColor: primaryColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
