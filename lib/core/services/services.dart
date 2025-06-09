// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:get/get.dart';
// import 'package:get/get_state_manager/get_state_manager.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Add this import

// class MyServices extends GetxService {
//   late SharedPreferences sharedprf;

//   Future<MyServices> init() async {
//     // await Firebase.initializeApp(
//     //   options: FirebaseOptions(
//     //     apiKey: 'AIzaSyAKxVd_apT8ixiNzXzffV0TYDkof-m6qrw',
//     //     appId: '1:937202513401:android:1995b3c5b340b018663928',
//     //     messagingSenderId: '937202513401',
//     //     projectId: 'ecooapp-fa946',
//     //     storageBucket: 'ecooapp-fa946.firebasestorage.app',
//     //   ),
//     // );

//     // await Firebase.initializeApp();
//     // String? token = await FirebaseMessaging.instance.getToken();
//     // print("Token====================== $token");

//     sharedprf = await SharedPreferences.getInstance();
//     return this;
//   }
// }

// initialServices() async {
//   await Get.putAsync(() => MyServices().init());
// }

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// If you want to use Firebase in the future
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

class MyServices extends GetxService {
  late SharedPreferences sharedprf;

  Future<MyServices> init() async {
    print('Initializing MyServices...');

    // Here you can add Firebase initialization if you uncommented it
    // Make sure to import 'package:firebase_core/firebase_core.dart';
    // and provide the correct FirebaseOptions
    // await Firebase.initializeApp();

    sharedprf = await SharedPreferences.getInstance();
    print('SharedPreferences initialized in MyServices.');
    return this;
  }
}

// This function registers MyServices in GetX
initialServices() async {
  // Get.putAsync is used to initialize services that require non-blocking operations (like await)
  await Get.putAsync(() => MyServices().init());
}
