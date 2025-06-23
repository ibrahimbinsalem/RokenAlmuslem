// import 'package:baligne/core/constant/theamdata.dart';
// import 'package:baligne/core/functions/fcmconfig.dart';
// import 'package:baligne/core/services/services.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LocalController extends GetxController {
//   Locale? startLang;
//   MyServices myServices = Get.find();
//   ThemeData appTheam = themeEnglish;
//   final RxString selectedLang = 'en'.obs;
//   late SharedPreferences _prefs;

//     Future<void> changeLang(String langcode) async {
//     if (selectedLang.value == langcode) return;

//     selectedLang.value = langcode;
//     Locale locale = Locale(langcode);

//     await myServices.sharedprf.setString("lang", langcode);
//     await _prefs.setString('lang', langcode);

//     Get.updateLocale(locale);
//     appTheam = langcode == "ar" ? themeArabic : themeEnglish;
//     Get.changeTheme(appTheam);

//     update();
//   }

//   //   changeLang(String langcode) {
//   //   Locale locale = Locale(langcode);
//   //   myServices.sharedprf.setString("lang", langcode);
//   //   Get.updateLocale(locale);
//   //   appTheam = langcode == "ar" ? themeArabic : themeEnglish;
//   //   Get.changeTheme(appTheam);
//   // }

//   // @override
//   // void onInit() {
//   //   super.onInit();
//   //   _loadSavedLang();
//   // }

//   Future<void> _loadSavedLang() async {
//     _prefs = await SharedPreferences.getInstance();
//     String? savedLang = _prefs.getString('lang');

//     if (savedLang != null) {
//       selectedLang.value = savedLang;
//       startLang = Locale(savedLang);
//       appTheam = savedLang == "ar" ? themeArabic : themeEnglish;
//     } else {
//       startLang = Locale(Get.deviceLocale?.languageCode ?? 'en');
//       selectedLang.value = Get.deviceLocale?.languageCode ?? 'en';
//       appTheam = themeEnglish;
//     }
//   }

//   // void changeLang2(String langCode) async {
//   //   if (selectedLang.value == langCode) return;

//   //   selectedLang.value = langCode;
//   //   await Get.updateLocale(Locale(langCode));
//   //   await _prefs.setString('language', langCode);
//   //   update();
//   // }

//   // requistPerLocation() async {
//   //   bool serviceEnabled;
//   //   LocationPermission permission;
//   //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   //   if (!serviceEnabled) {
//   //     return Get.snackbar("تنبيه", "الرجاء تحديد موقعك بالخريطه");
//   //   }
//   //   permission = await Geolocator.checkPermission();

//   //   if (permission == LocationPermission.denied) {
//   //     permission = await Geolocator.requestPermission();
//   //     if (permission == LocationPermission.denied) {
//   //       // Permissions are denied, next time you could try

//   //       return Get.snackbar("تنبيه", "الرجاء اعطاء الصلاحية");
//   //     }
//   //   }

//   //   if (permission == LocationPermission.deniedForever) {
//   //     // Permissions are denied forever, handle appropriately.
//   //     return Get.snackbar(
//   //       "تنبيه",
//   //       "في حال عدم فتح الصلاحيه لا يمكنك استخدام التطبيق ",
//   //     );
//   //   }
//   // }

//   @override
//   void onInit() {
//     _loadSavedLang();

//     // requestPermissionNotification();
//     // fcmconfig();
//     // requistPerLocation();

//     // String? sharedPrefLang = myServices.sharedprf.getString("lang");
//     // if (sharedPrefLang == "ar") {
//     //   startLang = const Locale("ar");
//     // } else if (sharedPrefLang == "en") {
//     //   startLang = const Locale("en");
//     // } else {
//     //   // Default language based on device locale
//     //   startLang = Locale(Get.deviceLocale!.languageCode);
//     //   appTheam = themeEnglish;
//     // }

//     _loadSavedLang();

//     super.onInit();
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rokenalmuslem/core/constant/theamdata.dart';
import 'package:rokenalmuslem/core/services/services.dart';

class LocalController extends GetxController {
  final MyServices myServices = Get.find();

  Rx<Locale> locale = const Locale('en').obs;
  Rx<ThemeData> theme = themeEnglish.obs;

  get isRtl => null;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLang();
  }

  void _loadSavedLang() {
    final savedLang = myServices.sharedprf.getString("lang");
    if (savedLang == "ar") {
      locale.value = const Locale("ar");
      theme.value = themeArabic;
    } else if (savedLang == "en") {
      locale.value = const Locale("en");
      theme.value = themeEnglish;
    } else {
      locale.value = Get.deviceLocale ?? const Locale('en');
      theme.value = themeEnglish;
    }
  }

  Future<void> changeLang(String langCode) async {
    if (locale.value.languageCode == langCode) return;

    locale.value = Locale(langCode);
    theme.value = langCode == "ar" ? themeArabic : themeEnglish;

    await myServices.sharedprf.setString("lang", langCode);
    Get.updateLocale(locale.value);
    Get.changeTheme(theme.value);
  }
}
