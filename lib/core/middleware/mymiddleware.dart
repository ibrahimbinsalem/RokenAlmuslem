import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/services/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class MyMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;

  MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    String? step = myServices.sharedprf.getString("step");

    // إذا كان المستخدم قد شاهد شاشة الترحيب (step = "1" أو "2")، اسمح له بالمرور إلى الصفحة الرئيسية
    if (step == "1" || step == "2") {
      return null; // لا تقم بإعادة التوجيه، دعه يذهب إلى المسار المطلوب (وهو الصفحة الرئيسية من "/")
    }
    // إذا لم يشاهد شاشة الترحيب بعد، قم بتوجيهه إليها
    if (step == "0" || step == null) {
      return const RouteSettings(name: AppRoute.onBording);
    }

    return null;
  }
}
