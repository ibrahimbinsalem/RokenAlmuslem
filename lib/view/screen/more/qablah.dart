// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_qiblah/flutter_qiblah.dart';
// import 'dart:math' show pi;

// import 'package:rokenalmuslem/controller/more/qiblahcontroller.dart'; // لاستخدام قيمة باي للتدوير

// class QiblaPage extends StatelessWidget {
//   const QiblaPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final QiblaController controller = Get.put(QiblaController());

//     // لوحة الألوان (يمكنك استخدام الألوان من الصفحة الرئيسية)
//     const primaryColor = Color(0xFF8FBC8F); // أخضر زمردي
//     const accentColor = Color(0xFFD4AF37); // ذهبي
//     const bgColorStart = Color(0xFF0D1B2A); // أزرق داكن جداً
//     const bgColorEnd = Color(0xFF0F0F1A); // بنفسجي داكن جداً
//     const cardColor = Color(0xFF1A2A3A); // لون بطاقة أزرق داكن معتم

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "تحديد اتجاه القبلة",
//           style: TextStyle(color: Colors.white, fontFamily: 'Tajawal'),
//         ),
//         backgroundColor: bgColorStart,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [bgColorStart, bgColorEnd],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Obx(() {
//           // عرض شاشة التحميل أو رسائل الخطأ/الأذونات
//           if (controller.isLoading.value) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(color: primaryColor),
//                   const SizedBox(height: 20),
//                   Text(
//                     controller.statusMessage.value,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 18,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (!controller.isPermissionGranted.value ||
//               !controller.hasSensor.value) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       !controller.isPermissionGranted.value
//                           ? Icons.location_off
//                           : Icons.compass_calibration,
//                       size: 80,
//                       color: accentColor,
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       controller.statusMessage.value,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 18,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     ElevatedButton.icon(
//                       onPressed: () => controller.retryQiblaDetection(),
//                       icon: const Icon(Icons.refresh, color: Colors.white),
//                       label: const Text(
//                         "إعادة المحاولة / طلب الصلاحيات",
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryColor,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 25,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     if (!controller.isPermissionGranted.value)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 15.0),
//                         child: Text(
//                           "قد تحتاج إلى تفعيل الموقع في إعدادات الجهاز إذا استمرت المشكلة.",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.7),
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           // عرض البوصلة والاتجاهات
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // قاعدة البوصلة (يمكن استبدالها بصورة حقيقية للبوصلة)
//                     Container(
//                       width: MediaQuery.of(context).size.width * 0.8,
//                       height: MediaQuery.of(context).size.width * 0.8,
//                       decoration: BoxDecoration(
//                         color: cardColor.withOpacity(0.8),
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.4),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                         border: Border.all(
//                           color: primaryColor.withOpacity(0.5),
//                           width: 3,
//                         ),
//                       ),
//                       child: const Center(
//                         // يمكنك استخدام Image.asset هنا لخلفية البوصلة
//                         child: Text(
//                           "N", // يمكن استبدالها بصورة حرف N أو رمز الشمال
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 40,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     // سهم يشير إلى الشمال (True North)
//                     // يدور بناءً على اتجاه القبلة (direction)
//                     Transform.rotate(
//                       angle:
//                           ((controller.qiblahDirection.value?.direction ?? 0) *
//                               (pi / 180) *
//                               -1),
//                       alignment: Alignment.center,
//                       child: Icon(
//                         Icons.brightness_1, // دائرة تمثل نقطة الشمال
//                         size: MediaQuery.of(context).size.width * 0.1,
//                         color: Colors.redAccent, // لون أحمر للشمال
//                       ),
//                     ),
//                     // سهم اتجاه القبلة
//                     Transform.rotate(
//                       // `qiblah` هو اتجاه القبلة بالنسبة للشمال المغناطيسي، وهو الأنسب للعرض البصري المباشر
//                       angle:
//                           ((controller.qiblahDirection.value?.qiblah ?? 0) *
//                               (pi / 180) *
//                               -1),
//                       alignment: Alignment.center,
//                       child: Icon(
//                         Icons
//                             .navigation_rounded, // أيقونة سهم تشير إلى اتجاه القبلة
//                         size: MediaQuery.of(context).size.width * 0.4,
//                         color: accentColor,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),
//                 Text(
//                   "اتجاه القبلة: ${controller.qiblahDirection.value?.direction?.toStringAsFixed(1) ?? 'N/A'}°",
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 20,
//                   ),
//                 ),
//                 Text(
//                   "اتجاه الجهاز (بالنسبة للشمال الحقيقي): ${controller.qiblahDirection.value?.direction?.toStringAsFixed(1) ?? 'N/A'}°",
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 18,
//                   ),
//                 ),
//                 Text(
//                   "الانحراف المغناطيسي: ${controller.qiblahDirection.value?.offset?.toStringAsFixed(1) ?? 'N/A'}°",
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   controller.statusMessage.value,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: primaryColor.withOpacity(0.8),
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
