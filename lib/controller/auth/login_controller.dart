import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // **جديد: استيراد Firebase Messaging**
import 'package:google_sign_in/google_sign_in.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

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
          await _handleAuthResponse(data);
        },
      );

      isLoading.value = false;
    }
  }

  @override
  void goToSignUp() {
    Get.offNamed(AppRoute.signUp);
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        isLoading.value = false;
        return;
      }

      final googleAuth = await account.authentication;
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        showToast('تعذر الحصول على بيانات جوجل.', Colors.redAccent);
        return;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseToken = await userCredential.user?.getIdToken(true);
      if (firebaseToken == null) {
        showToast('تعذر الحصول على توكن فيربيز.', Colors.redAccent);
        return;
      }

      final response = await loginData.postFirebase(firebaseToken);
      response.fold(
        (failure) {
          statusRequest = failure;
          showToast('فشل تسجيل الدخول بجوجل.', Colors.redAccent);
        },
        (data) async {
          await _handleAuthResponse(data);
        },
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} ${e.message}');
      if (e.code == 'network-request-failed') {
        showToast('تحقق من اتصال الإنترنت.', Colors.redAccent);
      } else if (e.code == 'invalid-credential') {
        showToast('بيانات جوجل غير صالحة.', Colors.redAccent);
      } else {
        showToast('تعذر تسجيل الدخول بجوجل.', Colors.redAccent);
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      showToast('حدث خطأ أثناء تسجيل الدخول بجوجل.', Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleAuthResponse(dynamic data) async {
    if (data['status'] != 'success') {
      statusRequest = StatusRequist.filuere;
      showToast(
        "البريد الإلكتروني أو كلمة المرور غير صحيحة.",
        Colors.redAccent,
      );
      return;
    }

    statusRequest = StatusRequist.succes;
    final user = data['user'] as Map<String, dynamic>;
    final roles = (user['roles'] as List<dynamic>?) ?? [];
    final role = roles.isNotEmpty ? roles.first as Map<String, dynamic> : null;

    String userId = user['id'].toString();
    myServices.sharedprf.setString("id", userId);
    myServices.sharedprf.setString("username", user['name']);
    myServices.sharedprf.setString("email", user['email']);
    if (role != null) {
      myServices.sharedprf.setString("role_id", role['id'].toString());
      myServices.sharedprf.setString("role_name", role['name'].toString());
    }
    String? authToken;
    if (data['token'] != null) {
      authToken = data['token'].toString();
      myServices.sharedprf.setString("token", authToken);
    }
    myServices.sharedprf.setString("step", "2");

    final loginKey = "has_logged_in_$userId";
    final isFirstLogin = !(myServices.sharedprf.getBool(loginKey) ?? false);
    myServices.sharedprf.setBool(loginKey, true);

    showToast("تم تسجيل الدخول بنجاح", Colors.green);
    Get.offAllNamed(AppRoute.homePage);

    Future.microtask(() async {
      try {
        FirebaseMessaging.instance.subscribeToTopic("users");
        FirebaseMessaging.instance.subscribeToTopic("users$userId");
      } catch (e) {
        debugPrint("Topic subscription failed: $e");
      }

      if (authToken != null) {
        try {
          final deviceToken = await FirebaseMessaging.instance.getToken();
          if (deviceToken != null) {
            myServices.sharedprf.setString("device_token", deviceToken);
            final platform = Platform.isIOS ? 'ios' : 'android';
            await ApiService().sendDeviceToken(
              authToken: authToken,
              deviceToken: deviceToken,
              platform: platform,
            );
          }
        } catch (e) {
          debugPrint("Device token registration failed: $e");
          showToast("تعذر حفظ توكن الجهاز، سنحاول لاحقًا.", Colors.orange);
        }

        try {
          final settingsController = Get.find<AppSettingsController>();
          await settingsController.syncFromServer();
        } catch (e) {
          debugPrint("Failed to sync app settings: $e");
        }
      }

      final welcomeMessage =
          isFirstLogin
              ? "مرحبا بك في تطبيق ركن المسلم"
              : "مرحبا بعودتك إلى تطبيق ركن المسلم";

      if (Get.isRegistered<NotificationService>()) {
        await Get.find<NotificationService>().showNotification(
          title: "ركن المسلم",
          body: welcomeMessage,
        );
      }
    });
  }
}
