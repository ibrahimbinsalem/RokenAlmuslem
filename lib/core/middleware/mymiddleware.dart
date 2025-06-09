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
    if (myServices.sharedprf.getString("step") == "2") {
      return const RouteSettings(name: AppRoute.homePage);
    }
    if (myServices.sharedprf.getString("step") == "1") {
      return const RouteSettings(name: AppRoute.onBording);
    }

    return null;
  }
}
