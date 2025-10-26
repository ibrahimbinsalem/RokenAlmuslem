import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
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
      isLoading.value = true;
      // ==========================================================
      // هنا سيتم وضع الكود الخاص بالاتصال بـ API لتسجيل الدخول
      // حالياً سنقوم بمحاكاة العملية
      // ==========================================================
      await Future.delayed(const Duration(seconds: 2));
      // افتراض أن تسجيل الدخول ناجح
      print("Login Successful");
      myServices.sharedprf.setString("step", "2"); // أو "loggedin"
      Get.offAllNamed(AppRoute.homePage);

      isLoading.value = false;
    } else {
      Get.snackbar(
        "خطأ في التحقق",
        "الرجاء التأكد من صحة البيانات المدخلة",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void goToSignUp() {
    Get.offNamed(AppRoute.signUp);
  }
}
