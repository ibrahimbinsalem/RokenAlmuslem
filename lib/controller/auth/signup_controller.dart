import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/auth/signup_data.dart';
import 'package:rokenalmuslem/core/class/crud.dart';
import 'package:rokenalmuslem/core/class/statusrequist.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/functions/handlingdata.dart';
import 'package:rokenalmuslem/core/functions/showToast.dart';

abstract class SignUpController extends GetxController {
  void signup();
  void goToLogin();
}

class SignUpControllerImp extends SignUpController {
  late TextEditingController username;
  late TextEditingController email;
  late TextEditingController password;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  StatusRequist statusRequest = StatusRequist.none;
  SignUpData signupData = SignUpData(Crud());

  @override
  void onInit() {
    username = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  signup() async {
    var formdata = formKey.currentState;

    if (formdata!.validate()) {
      statusRequest = StatusRequist.loading;
      update();
      final String emailLower = email.text.toLowerCase();
      var response = await signupData.postData(
        username.text,
        emailLower,
        password.text,
      );

      response.fold(
        (failure) {
          statusRequest = failure;
          showToast("فشل إنشاء الحساب. حاول مرة أخرى.", Colors.redAccent);
        },
        (data) {
          statusRequest = handelingData(data);
          if (data['status'] == 'success') {
            showToast("تم إنشاء الحساب بنجاح، يرجى تسجيل الدخول.", Colors.green);
            Get.offNamed(AppRoute.login, arguments: {"email": emailLower});
          } else {
            showToast("فشل إنشاء الحساب.", Colors.orange);
            statusRequest = StatusRequist.none;
          }
        },
      );

      update();
    } else {
      print("SignUp Not Succes");
    }
  }

  @override
  void goToLogin() {
    Get.offNamed(AppRoute.login);
  }
}
