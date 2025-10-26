import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';

abstract class SignUpController extends GetxController {
  void signUp();
  void goToLogin();
}

class SignUpControllerImp extends SignUpController {
  late TextEditingController username;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController password;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    username = TextEditingController();
    email = TextEditingController();
    phone = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  void signUp() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      // ==========================================================
      // هنا سيتم وضع الكود الخاص بالاتصال بـ API لإنشاء الحساب
      // حالياً سنقوم بمحاكاة العملية
      // ==========================================================
      await Future.delayed(const Duration(seconds: 2));
      // افتراض أن إنشاء الحساب ناجح
      print("Sign Up Successful");
      // بعد النجاح، ننتقل إلى شاشة التحقق
      Get.offNamed(AppRoute.verifyCode, arguments: {"email": email.text});
      isLoading.value = false;
    } else {
      Get.snackbar(
        "خطأ في التحقق",
        "الرجاء التأكد من صحة جميع البيانات المدخلة",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void goToLogin() {
    Get.offNamed(AppRoute.login);
  }
}
