import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

alertExitApp(){

return Get.defaultDialog(
  title: "Exsiption",
  middleText: "Do you Want to Exite the App",
  actions: [
    ElevatedButton(onPressed: (){
      exit(0);

    }, child: Text("Yes")),

      ElevatedButton(onPressed: (){
        Get.back();

    }, child: Text("No")),




  ]

);



}