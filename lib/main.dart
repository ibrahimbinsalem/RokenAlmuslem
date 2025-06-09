import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rokenalmuslem/bindings/initialbinding.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/localization/changelocal.dart';
import 'package:rokenalmuslem/core/localization/translation.dart';
import 'package:rokenalmuslem/core/services/services.dart';
import 'package:rokenalmuslem/rout.dart';

// new imports for workmanager and database_helper
import 'package:workmanager/workmanager.dart';
import 'package:rokenalmuslem/data/database/database_helper.dart';

// this function must be top-level function or static.
// it will be called by workmanager when the task is due in the background.
@pragma('vm:entry-point') // important to work on iOS and Android
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print("Background task executing: $taskName");

    // Initialize DatabaseHelper here because it is a separate environment from the main app environment.
    final dbHelper = DatabaseHelper();

    if (taskName == "resetAdkarCountersTask") {
      // Call the function that resets the counters in the database.
      await dbHelper.resetAllDhikrCountsToInitial(
        DatabaseHelper.morningAdkarTableName,
      );
      await dbHelper.resetAllDhikrCountsToInitial(
        DatabaseHelper.eveningAdkarTableName,
      );
      await dbHelper.resetAllDhikrCountsToInitial(
        DatabaseHelper.adkarSalatTableName,
      );
      print("Adkar counters reset to initial counts in background!");
    }
    return Future.value(true); // must return true to indicate success.
  });
}

void main() async {
  // Ensure Flutter Widgets are initialized before any async operations.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize services first (like GetX services)
  // This will initialize MyServices and store SharedPreferences
  await initialServices();

  // Initialize Workmanager: must be after WidgetsFlutterBinding.ensureInitialized()
  await Workmanager().initialize(
    callbackDispatcher, // This is the function that will be called in the background
    isInDebugMode:
        true, // set it to true in development to see logs in Logcat/Console
  );

  // Schedule the periodic task to reset adkar counters every 24 hours.
  Workmanager().registerPeriodicTask(
    "resetAdkarCountersDaily", // unique task name
    "resetAdkarCountersTask", // task name that will be sent to callbackDispatcher
    initialDelay: const Duration(
      seconds: 30,
    ), // for testing, set it to 30 seconds, in production you can modify it
    frequency: const Duration(
      hours: 24,
    ), // time interval between each execution (24 hours)
    existingWorkPolicy:
        ExistingWorkPolicy
            .replace, // replace any previous task with the same name
  );

  // Check if the onboarding screen has been shown before
  // Access sharedprf through MyServices which was initialized using Get.putAsync
  final MyServices myServices = Get.find<MyServices>();
  bool hasSeenOnboarding =
      myServices.sharedprf.getBool('hasSeenOnboarding') ?? false;

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    // LocalController is initialized here because it is required to build GetMaterialApp
    final LocalController localeController = Get.put(LocalController());

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: MyTranslation(), // GetX translations
        locale:
            localeController.locale.value, // set language based on controller
        fallbackLocale: const Locale(
          'en',
        ), // fallback language if language is not found
        theme: localeController.theme.value, // set theme based on controller
        initialBinding: InitialBindings(), // initial GetX bindings
        getPages: routes, // define app pages and routes
        // set initial route based on onboarding status
        initialRoute:
            hasSeenOnboarding ? AppRoute.homePage : AppRoute.onBording,
        builder: (context, child) {
          // set text direction based on selected language
          return Directionality(
            textDirection:
                localeController.locale.value.languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
            child: child!,
          );
        },
      ),
    );
  }
}
