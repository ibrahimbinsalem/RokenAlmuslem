import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:rokenalmuslem/core/middleware/mymiddleware.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/screen/adkar/almsa.dart';
import 'package:rokenalmuslem/view/screen/adkar/alsbah.dart';
import 'package:rokenalmuslem/view/screen/adkar/pray.dart';
import 'package:rokenalmuslem/view/screen/home/mainscreen.dart';
import 'package:rokenalmuslem/view/screen/onbording/onbording.dart';

List<GetPage<dynamic>>? routes = [
  // Authe
  GetPage(name: "/", page: () => OnBordiding(), middlewares: [MyMiddleWare()]),

  // Custom :
  // GetPage(name: "/", page: () => OnBordiding()),

  // OnBording :
  GetPage(name: AppRoute.homePage, page: () => MainScreen()),

  // Adkar :
  GetPage(name: AppRoute.alsbah, page: () => Alsbah()),
  GetPage(name: AppRoute.almsa, page: () => AdkarAlmsaPage()),
  GetPage(name: AppRoute.pray, page: () => AdkarSalatView()),
];
