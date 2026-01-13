import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:rokenalmuslem/core/middleware/mymiddleware.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/auth/login.dart';
import 'package:rokenalmuslem/view/auth/signup.dart';
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
import 'package:rokenalmuslem/view/screen/more/aboutbage.dart';
import 'package:rokenalmuslem/view/screen/more/adayanabuaya.dart';
import 'package:rokenalmuslem/view/screen/more/adayaquran.dart';
import 'package:rokenalmuslem/view/screen/more/adayatalanbya.dart';
import 'package:rokenalmuslem/view/screen/more/alarboun.dart';
import 'package:rokenalmuslem/view/screen/more/alrugi.dart';
import 'package:rokenalmuslem/view/screen/more/app_rating.dart';
import 'package:rokenalmuslem/view/screen/more/app_suggestion.dart';
import 'package:rokenalmuslem/view/screen/more/asmaallah.dart';
import 'package:rokenalmuslem/view/screen/more/help_center.dart';
import 'package:rokenalmuslem/view/screen/more/support_chat.dart';
import 'package:rokenalmuslem/view/screen/more/fadelaldaker.dart';
import 'package:rokenalmuslem/view/screen/more/fadelalduaa.dart';
import 'package:rokenalmuslem/view/screen/more/msbaha.dart';
import 'package:rokenalmuslem/view/screen/more/praytime.dart';
import 'package:rokenalmuslem/view/screen/more/prophet_stories.dart';
import 'package:rokenalmuslem/view/screen/more/prophet_story_detail.dart';
import 'package:rokenalmuslem/view/screen/more/stories.dart';
import 'package:rokenalmuslem/view/screen/more/story_detail.dart';
import 'package:rokenalmuslem/view/screen/more/qablah.dart';
import 'package:rokenalmuslem/view/screen/more/setting.dart';
import 'package:rokenalmuslem/view/screen/more/quran_plan.dart';
import 'package:rokenalmuslem/view/screen/more/daily_plan.dart';
import 'package:rokenalmuslem/view/screen/more/custom_adkar.dart';
import 'package:rokenalmuslem/view/screen/more/spiritual_stats.dart';
import 'package:rokenalmuslem/view/screen/onbording/onbording.dart';
import 'package:rokenalmuslem/view/screen/quran/detail_screen.dart';
import 'package:rokenalmuslem/view/screen/quran/home_screen.dart';

List<GetPage<dynamic>>? routes = [
  // Auth
  GetPage(name: "/", page: () => MainScreen(), middlewares: [MyMiddleWare()]),
  GetPage(name: AppRoute.login, page: () => const LoginView()),
  GetPage(name: AppRoute.signUp, page: () => const SignUpView()),
  // GetPage(name: AppRoute.verifyCode, page: () => const VerifyCodeView()),

  // OnBording :
  GetPage(name: AppRoute.onBording, page: () => OnBordiding()),

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

  // More :
  GetPage(name: AppRoute.asmaAllah, page: () => AsmaAllahView()),
  GetPage(name: AppRoute.msbaha, page: () => TasbeehView()),
  GetPage(name: AppRoute.qiblah, page: () => QiblaView()),
  GetPage(name: AppRoute.fadelalduaa, page: () => FadelAlDuaaPage()),
  GetPage(name: AppRoute.alrugi, page: () => AlrugiView()),
  GetPage(name: AppRoute.aduqyQuran, page: () => AdayaQuraniyaView()),
  GetPage(name: AppRoute.aduqyNabuia, page: () => AdayahNabuiaView()),
  GetPage(name: AppRoute.adaytalanbya, page: () => AdayaAlanbiaView()),
  GetPage(name: AppRoute.alarboun, page: () => FortyHadithView()),
  GetPage(name: AppRoute.fadelaldaker, page: () => FadelAlDkerView()),
  GetPage(name: AppRoute.setting, page: () => SettingsPage()),
  GetPage(name: AppRoute.prytime, page: () => PrayerTimesView()),
  GetPage(name: AppRoute.prophetStories, page: () => const ProphetStoriesView()),
  GetPage(
    name: AppRoute.prophetStoryDetail,
    page: () => const ProphetStoryDetailView(),
  ),
  GetPage(name: AppRoute.stories, page: () => const StoriesView()),
  GetPage(name: AppRoute.storyDetail, page: () => const StoryDetailView()),
  GetPage(name: AppRoute.quran, page: () => SurahListPage()),
  GetPage(name: AppRoute.quranPlan, page: () => QuranPlanView()),
  GetPage(name: AppRoute.customAdkar, page: () => CustomAdkarView()),
  GetPage(name: AppRoute.spiritualStats, page: () => SpiritualStatsView()),
  GetPage(name: AppRoute.dailyPlan, page: () => const DailyPlanView()),
  GetPage(name: AppRoute.appRating, page: () => const AppRatingView()),
  GetPage(name: AppRoute.supportChat, page: () => const SupportChatView()),
  GetPage(name: AppRoute.helpCenter, page: () => const HelpCenterView()),
  GetPage(name: AppRoute.suggestions, page: () => const AppSuggestionView()),
  // GetPage(name: AppRoute.surahDetail, page: () => SurahDetailPage(surah:)),

  // Settings :
  GetPage(name: AppRoute.about, page: () => AboutUsPage()),
];
