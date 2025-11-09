import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rokenalmuslem/controller/auth/signup_data.dart';
import 'package:rokenalmuslem/core/class/crud.dart';
import 'package:rokenalmuslem/core/class/statusrequist.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/functions/handlingdata.dart';
import 'package:rokenalmuslem/core/functions/showToast.dart';
import 'package:rokenalmuslem/linkapi.dart';

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
      var response = await http.post(
        Uri.parse(AppLink.signUp),
        headers: {
          'authorization':
              'Basic ' + base64Encode(utf8.encode('ibrahim:Shadow7000')),
        },
        body: {
          "username": username.text,
          "password": password.text,
          "email": emailLower,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Fix for malformed JSON response
        String responseString = response.body;
        int firstBrace = responseString.indexOf('}');
        if (firstBrace != -1) {
          responseString = responseString.substring(0, firstBrace + 1);
        }

        var responseBody = jsonDecode(responseString);
        statusRequest = handelingData(responseBody);

        if (responseBody['status'] == 'success') {
          showToast("تم انشاء الحساب الخاص بك بنجاح ", Colors.green);
          Get.offNamed(AppRoute.login, arguments: {"email": emailLower});
        } else {
          showToast(".......".tr, Colors.orange);
          statusRequest =
              StatusRequist.none; // Set to none to show the form again
        }
      } else {
        statusRequest = StatusRequist.serverfilure;
      }

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
