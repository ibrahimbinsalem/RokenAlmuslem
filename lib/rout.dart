import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:rokenalmuslem/core/middleware/mymiddleware.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/screen/adkar/afterpray.dart';
import 'package:rokenalmuslem/view/screen/adkar/aladan.dart';
import 'package:rokenalmuslem/view/screen/adkar/alastygad.dart';
import 'package:rokenalmuslem/view/screen/adkar/almanzel.dart';
import 'package:rokenalmuslem/view/screen/adkar/almsa.dart';
import 'package:rokenalmuslem/view/screen/adkar/almsjed.dart';
import 'package:rokenalmuslem/view/screen/adkar/alsbah.dart';
import 'package:rokenalmuslem/view/screen/adkar/badroom.dart';
import 'package:rokenalmuslem/view/screen/adkar/eat.dart';
import 'package:rokenalmuslem/view/screen/adkar/fordead.dart';
import 'package:rokenalmuslem/view/screen/adkar/pray.dart';
import 'package:rokenalmuslem/view/screen/adkar/sleep.dart';
import 'package:rokenalmuslem/view/screen/adkar/washing.dart';
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
  GetPage(name: AppRoute.afterpray, page: () => AdkarAfterSalatView()),
  GetPage(name: AppRoute.sleep, page: () => AdkarAlnomView()),
  GetPage(name: AppRoute.aladan, page: () => AdkarAladanView()),
  GetPage(name: AppRoute.almsjed, page: () => AdkarAlmsjadView()),
  GetPage(name: AppRoute.alastygad, page: () => AdkarAlastygadView()),
  GetPage(name: AppRoute.almanzel, page: () => AdkarHomeView()),
  GetPage(name: AppRoute.washing, page: () => AdkarAlwswiView()),
  GetPage(name: AppRoute.alkhla, page: () => AdkarAlkhlaView()),
  GetPage(name: AppRoute.eat, page: () => AdkarEatView()),
  GetPage(name: AppRoute.fordead, page: () => AdayahForDeadView()),
];
