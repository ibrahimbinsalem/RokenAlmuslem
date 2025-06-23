import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Keep if used for other notifications
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart'; // New: For local data storage
import 'package:path_provider/path_provider.dart'; // New: For getting application directory

// App imports
import 'package:rokenalmuslem/bindings/initialbinding.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';
import 'package:rokenalmuslem/core/constant/routes.dart'; // Will need to add AppRoute.quranHome here
import 'package:rokenalmuslem/core/localization/changelocal.dart';
import 'package:rokenalmuslem/core/localization/translation.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/core/services/services.dart';
import 'package:rokenalmuslem/data/database/database_helper.dart'; // Keep if used for other features
import 'package:rokenalmuslem/rout.dart'; // Your defined routes
// New: Quran specific imports
import 'package:rokenalmuslem/view/screen/quran/home_screen.dart';
import 'package:rokenalmuslem/view/screen/quran/detail_screen.dart'; // If you want to navigate directly to it via route

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint("Background task executing: $taskName");

    try {
      // Ensure DatabaseHelper is initialized for background tasks if needed
      // Note: DatabaseHelper.instance assumes it's initialized.
      // For background, you might need a simpler direct initialization or ensure it's
      // handled correctly by `_initializeApp` or a dedicated background init.
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
  // Initialize app-wide services and settings
  await _initializeApp();
  // Initialize date formatting for 'ar' locale
  await initializeDateFormatting('ar');

  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  try {
    // Ensure Flutter widgets are initialized before any Flutter-specific operations
    WidgetsFlutterBinding.ensureInitialized();
    // Initialize GetStorage for general app settings (e.g., onboarding status)
    await GetStorage.init();

    // Initialize core services (e.g., shared preferences)
    await initialServices();

    // Initialize AppSettingsController and load settings
    final settingsController =
        AppSettingsController()
          ..darkModeEnabled.value =
              false // Default values
          ..fontSizeMultiplier.value = 1.0;
    await settingsController.loadSettings();
    Get.put(settingsController, permanent: true);

    // Initialize notification service for foreground/background notifications
    final notificationService = NotificationService();
    await notificationService.initialize();
    Get.put(notificationService, permanent: true);

    // New: Initialize Hive for local data storage
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    // Open Hive boxes for Quran data and user settings (last read position)
    await Hive.openBox('quranData'); // Stores Surah and Ayah data
    await Hive.openBox('quranSettings'); // Stores last read position etc.

    // Initialize Workmanager for background tasks
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    // Schedule any necessary background tasks
    await _scheduleBackgroundTasks();
  } catch (e, stack) {
    debugPrint("App Initialization Error: $e\n$stack");
    // Rethrow to indicate a critical startup failure
    rethrow;
  }
}

// Helper function for background task (resetting Adkar counters)
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

// Helper function to send notification after background task
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

// Helper function to schedule background tasks
Future<void> _scheduleBackgroundTasks() async {
  try {
    await Workmanager().registerPeriodicTask(
      "resetAdkarCountersDaily",
      "resetAdkarCountersTask",
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(minutes: 5), // Adjust as needed
      constraints: Constraints(
        networkType: NetworkType.not_required, // Task doesn't require network
        requiresBatteryNotLow: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy:
          ExistingWorkPolicy.replace, // Replace if already exists
    );
  } catch (e, stack) {
    debugPrint("Task Scheduling Error: $e\n$stack");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GetBuilder for LocalController to manage app locale
    return GetBuilder<LocalController>(
      init: LocalController(), // Initialize LocalController
      builder: (localeController) {
        // GetBuilder for AppSettingsController to manage app theme and font size
        return GetBuilder<AppSettingsController>(
          builder: (appSettings) {
            final myServices = Get.find<MyServices>();

            // Determine dark mode and font size from settings, with fallbacks
            final darkMode = appSettings.darkModeEnabled.value ?? false;
            final fontSizeMultiplier =
                appSettings.fontSizeMultiplier.value ?? 1.0;

            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'روكن المسلم',
              // Apply theme based on dark mode and font size
              theme: _buildTheme(fontSizeMultiplier, false), // Light theme
              darkTheme: _buildTheme(fontSizeMultiplier, true), // Dark theme
              themeMode:
                  darkMode ? ThemeMode.dark : ThemeMode.light, // Set theme mode
              translations: MyTranslation(), // App translations
              locale:
                  localeController.locale.value ??
                  const Locale('ar'), // Current locale
              fallbackLocale: const Locale('ar'), // Fallback locale
              initialRoute: _getInitialRoute(
                myServices,
              ), // Determine initial route (onboarding vs. home)
              getPages: routes, // All defined app routes
              initialBinding: InitialBindings(), // Initial GetX bindings
              builder: (context, child) {
                // Ensure child is not null
                return Directionality(
                  // Apply RTL for Arabic language if needed globally
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

  // Determines the initial route based on whether onboarding has been seen
  String _getInitialRoute(MyServices services) {
    return services.sharedprf.getBool('hasSeenOnboarding') ?? false
        ? AppRoute
            .homePage // Assuming homePage is your main app screen
        : AppRoute.onBording;
  }

  // Builds the ThemeData based on font size multiplier and dark mode
  ThemeData _buildTheme(double fontSizeMultiplier, bool isDark) {
    return ThemeData(
      // Define color scheme for light/dark modes
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: const Color(0xFF0A84FF), // Example primary color
        onPrimary: Colors.white,
        secondary: const Color(0xFF34C759), // Example secondary color
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: isDark ? Colors.black : const Color(0xFFF2F2F7),
        onBackground: isDark ? Colors.white : Colors.black,
        surface: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        onSurface: isDark ? Colors.white : Colors.black,
      ),
      // App bar theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : const Color(0xFF0A84FF),
        titleTextStyle: TextStyle(
          fontSize: 20 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // Text themes for various text styles
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 24 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: 16 * fontSizeMultiplier,
          color: isDark ? Colors.white : Colors.black,
        ),
        // Add other text styles as needed (e.g., headline, title, bodyMedium, labelSmall, etc.)
      ),
      // Card theme for consistent card styling
      cardTheme: CardTheme(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Add other theme properties as per your app's design system
    );
  }
}
