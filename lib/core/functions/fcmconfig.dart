// import 'package:admin_app/core/constant/color.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/route_manager.dart';

// requestPermissionNotification() async {
//   NotificationSettings settings = await FirebaseMessaging.instance
//       .requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         carPlay: false,
//         criticalAlert: false,
//         provisional: false,
//         sound: true,
//       );
// }

// fcmconfig() {
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print("<=========Notification=========>");
//     print(message.notification!.title);
//     print(message.notification!.body);
//     Get.snackbar(
//       message.notification!.title!,
//       message.notification!.body!,
//       backgroundColor: ColorsApp.appbar,
//       colorText: Colors.white,
//       icon: Icon(Icons.notification_add, color: Colors.white, size: 40),
//     );

//     refrachPageNotification(message.data);
//   });
// }

// refrachPageNotification(data) {
//   print("================== Page Id=====================>");
//   print(data["pageid"]);
//   print("================== Page Name=====================>");
//   print(data["pagename"]);

//   print("==================== Curent Route=====================>");
//   print(Get.currentRoute);

//   if (Get.currentRoute == "/homepage" && data["pagename"] == "deliv") {
//     // PandingControllerImp controller = Get.find();
//     // controller.refrachOrder();
//   }
// }
