import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // **جديد: استيراد Firebase Messaging**
import 'package:rokenalmuslem/controller/auth/login_data.dart';
import 'package:rokenalmuslem/core/class/statusrequist.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/functions/showToast.dart';
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

            String userId = data['data']['id'].toString();
            myServices.sharedprf.setString("id", userId);
            myServices.sharedprf.setString("username", data['data']['name']);
            myServices.sharedprf.setString("email", data['data']['email']);
            myServices.sharedprf.setString(
              "role_id",
              data['data']['role_id'].toString(),
            );
            myServices.sharedprf.setString(
              "role_name",
              data['data']['role_name'],
            );
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

            // Get.snackbar(
            //   "مرحباً بعودتك",
            //   myServices.sharedprf.getString("username") ?? "",
            //   snackPosition: SnackPosition.BOTTOM,
            //   backgroundColor: Colors.green,
            //   colorText: Colors.white,
            // );
            showToast(
              " مرحبا بك :  ${myServices.sharedprf.getString("username")}",
              Colors.green,
            );
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
