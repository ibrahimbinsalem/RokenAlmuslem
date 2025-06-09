
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/mainscreencontroller.dart';
import 'package:rokenalmuslem/core/constant/color.dart';
import 'package:rokenalmuslem/core/services/services.dart';

class CustomFlatAction extends StatelessWidget {
  const CustomFlatAction({super.key});

  @override
  Widget build(BuildContext context) {
    MainScreenControllerImp controller = Get.put(MainScreenControllerImp());
    MyServices myServices = Get.find();
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: ColorsApp.white.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 9),
          ),
        ],
        borderRadius: BorderRadius.circular(30),
        color: ColorsApp.primer,
      ),
      child: ClipOval(
        child: Material(
          elevation: 10,
          color: ColorsApp.primer,
          child: InkWell(
            overlayColor: WidgetStateProperty.all(Colors.black26),

            onTap: () {
              controller.goToCreateReport();
            },
            child: SizedBox(
              height: 65,
              width: 65,
              child: Icon(Icons.add_circle_outline, color: ColorsApp.white),
            ),
          ),
        ),
      ),
    );
  }
}
