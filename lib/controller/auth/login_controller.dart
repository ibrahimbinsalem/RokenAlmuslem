import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // **جديد: استيراد Firebase Messaging**
import 'package:rokenalmuslem/controller/auth/login_data.dart';
import 'package:rokenalmuslem/core/class/statusrequist.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/functions/showToast.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';
import 'package:rokenalmuslem/core/services/api_service.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/core/services/services.dart';

abstract class LoginController extends GetxController {
  void login();
  void goToSignUp();
}

class LoginControllerImp extends LoginController {
  late TextEditingController email;
  late TextEditingController password;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  MyServices myServices = Get.find();
  LoginData loginData = LoginData();
  StatusRequist statusRequest = StatusRequist.none;

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  void login() async {
    if (formKey.currentState!.validate()) {
      // **جديد: إزالة التركيز من حقول النص لإغلاق لوحة المفاتيح بسلاسة**
      FocusManager.instance.primaryFocus?.unfocus();

      isLoading.value = true;
      statusRequest = StatusRequist.loading;
      var response = await loginData.postData(email.text, password.text);

      response.fold(
        (failure) {
          // معالجة فشل الاتصال بالشبكة أو الخادم
          statusRequest = failure;
          Get.snackbar(
            "خطأ",
            "فشل تسجيل الدخول. تحقق من اتصالك بالإنترنت أو حاول مرة أخرى.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
        (data) async {
          // معالجة استجابة الخادم
          if (data['status'] == 'success') {
            // تم إلغاء التحقق من حالة الحساب (active) بناءً على طلبك
            statusRequest = StatusRequist.succes;
            print("===========${response}");

            final user = data['user'] as Map<String, dynamic>;
            final roles = (user['roles'] as List<dynamic>?) ?? [];
            final role =
                roles.isNotEmpty ? roles.first as Map<String, dynamic> : null;

            String userId = user['id'].toString();
            myServices.sharedprf.setString("id", userId);
            myServices.sharedprf.setString("username", user['name']);
            myServices.sharedprf.setString("email", user['email']);
            if (role != null) {
              myServices.sharedprf.setString(
                "role_id",
                role['id'].toString(),
              );
              myServices.sharedprf.setString(
                "role_name",
                role['name'].toString(),
              );
            }
            String? authToken;
            if (data['token'] != null) {
              authToken = data['token'].toString();
              myServices.sharedprf.setString("token", authToken);
            }
            // myServices.sharedprf.setString(
            //   "userroul",
            //   data['data']['id'].toString(),
            // );
            // myServices.sharedprf.setString(
            //   "userroulname",
            //   data['data']['name'],
            // );
            // myServices.sharedprf.setString(
            //   "usersimage",
            //   data['data']['image'] ?? "",
            // );
            myServices.sharedprf.setString("step", "2");

            // الاشتراك في مواضيع الإشعارات
            await FirebaseMessaging.instance.subscribeToTopic("users");
            await FirebaseMessaging.instance.subscribeToTopic("users$userId");

            if (authToken != null) {
              try {
                final deviceToken =
                    await FirebaseMessaging.instance.getToken();
                if (deviceToken != null) {
                  myServices.sharedprf.setString("device_token", deviceToken);
                  final platform = Platform.isIOS ? 'ios' : 'android';
                  await ApiService().sendDeviceToken(
                    authToken: authToken,
                    deviceToken: deviceToken,
                    platform: platform,
                  );
                } else {
                  debugPrint("Device token is null; skip registration.");
                }
              } catch (e) {
                debugPrint("Device token registration failed: $e");
                showToast(
                  "تعذر حفظ توكن الجهاز، سنحاول لاحقًا.",
                  Colors.orange,
                );
              }

              try {
                final settingsController = Get.find<AppSettingsController>();
                await settingsController.syncFromServer();
              } catch (e) {
                debugPrint("Failed to sync app settings: $e");
              }
            }

            // Get.snackbar(
            //   "مرحباً بعودتك",
            //   myServices.sharedprf.getString("username") ?? "",
            //   snackPosition: SnackPosition.BOTTOM,
            //   backgroundColor: Colors.green,
            //   colorText: Colors.white,
            // );
            final loginKey = "has_logged_in_$userId";
            final isFirstLogin =
                !(myServices.sharedprf.getBool(loginKey) ?? false);
            myServices.sharedprf.setBool(loginKey, true);

            final welcomeMessage = isFirstLogin
                ? "مرحبا بك في تطبيق ركن المسلم"
                : "مرحبا بعودتك إلى تطبيق ركن المسلم";

            if (Get.isRegistered<NotificationService>()) {
                await Get.find<NotificationService>().showNotification(
                  title: "ركن المسلم",
                  body: welcomeMessage,
                );
            }

            showToast(welcomeMessage, Colors.green);
            print(myServices.sharedprf.getString("role_id"));
            print(myServices.sharedprf.getString("role_name"));

            Get.offAllNamed(AppRoute.homePage);
          } else {
            // بيانات الدخول غير صحيحة
            statusRequest = StatusRequist.filuere;

            showToast(
              "البريد الإلكتروني أو كلمة المرور غير صحيحة.",
              Colors.redAccent,
            );
          }
        },
      );

      isLoading.value = false;
    }
  }

  @override
  void goToSignUp() {
    Get.offNamed(AppRoute.signUp);
  }
}
