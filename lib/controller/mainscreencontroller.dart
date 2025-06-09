import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/screen/adkar/adkaralmuslem.dart';
import 'package:rokenalmuslem/view/screen/home/homepage.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/view/screen/more/more.dart';
import 'package:rokenalmuslem/view/screen/notification/notification.dart';

abstract class MainScreenController extends GetxController {
  changePage(int i);
}

class MainScreenControllerImp extends MainScreenController {
  int curentpage = 0;

  List<Widget> listpage = [
    HomePage(),
    NotificationsScreen(),
    AdkarAlmuslam(),
    MorePage(),
  ];

  final iconList = <IconData>[
    Icons.home,
    Icons.person,
    Icons.settings,
    Icons.abc_outlined,
  ];

  goToCreateReport() {}

  @override
  changePage(int i) {
    curentpage = i;
    update();
  }
}
