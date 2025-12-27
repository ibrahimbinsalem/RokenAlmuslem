import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:rokenalmuslem/controller/mainscreencontroller.dart';
import 'package:rokenalmuslem/view/wedgit/buttons/butomNpar.dart';
import 'package:rokenalmuslem/view/wedgit/buttons/floatacctionbutom.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MainScreenControllerImp controllerImp = Get.put(MainScreenControllerImp());
    controllerImp.curentpage = controllerImp.curentpage;
    return GetBuilder<MainScreenControllerImp>(
      builder: (controller) {
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          body: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (bool didPop, result) async {
                  if (controller.curentpage != 0) {
                    controller.curentpage--;
                  } else {
                    Get.defaultDialog(
                      title: "Exit App",
                      middleText: "Are you sure you want to exit the app?",
                      textConfirm: "Yes",
                      textCancel: "No",
                      confirmTextColor: Colors.red,
                      onConfirm: () {
                        exit(0);
                      },
                    );
                    return Future.value();
                  }
                },
                child: controller.listpage.elementAt(controller.curentpage),
              );
            },
          ),
          bottomNavigationBar: CosmicNavBar(),
        );
      },
    );
  }
}
