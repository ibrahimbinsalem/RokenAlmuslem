import 'package:get/get.dart';

validInput(String val, int min, int max, String type) {
  if (type == "username") {
    if (!GetUtils.isUsername(val)) {
      return "Not valid username";
    }
  }

  if (type == "question") {
    if (!GetUtils.isTxt(val)) {
      return "Not valid question";
    }
  }

  if (type == "email") {
    if (!GetUtils.isEmail(val)) {
      return "Not valid email";
    }
  }

  if (type == "phone") {
    if (!GetUtils.isPhoneNumber(val)) {
      return "Not valid Phone";
    }
  }

  if (val.length < min) {
    return "The value can`t less then $min";
  }

  if (val.length > max) {
    return "The value can`t larger  then $max";
  }

  if (val.isEmpty) {
    return "can`t be Empty";
  }
}
