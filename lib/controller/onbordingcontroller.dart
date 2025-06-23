import 'package:get/get.dart';

abstract class OnBordingController extends GetxController {}

class OnBordingControllerImpl extends OnBordingController {
  final List<Map<String, String>> onboardingData = [
    {
      "title": "مرحبًا بكم في تطبيق ركن المسلم",
      "subtitle": "خيرُكم من تعلَّم القرآن وعلَّمه",
      "image": "assets/images/log.png",
    },
    {
      "title": "الأذكار اليومية",
      "subtitle":
          "احفظ أذكارك اليومية مع ركن المسلم مع معرفة اوقات الصلاة الخاصه بمنطقتك ",
      "image": "assets/images/logo.png",
    },
    {
      "title": "ابدأ رحلتك الروحانية",
      "subtitle": "تقرب إلى الله في كل لحظة مع أذكار الصباح والمساء",
      "image": "assets/images/friydaysonan.png",
    },
  ];
}
