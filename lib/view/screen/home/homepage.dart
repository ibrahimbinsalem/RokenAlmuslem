import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';

// تأكد من المسار الصحيح لوحدة التحكم الخاصة بك
import 'package:rokenalmuslem/controller/ayah_controller.dart';
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart';
import 'package:rokenalmuslem/controller/hadith_controller.dart'; // إضافة متحكم الحديث
import 'package:rokenalmuslem/controller/more/masbahacontroller.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';

class _ShortcutConfig {
  final String id;
  final String icon;
  final String label;
  final String? route;
  final bool comingSoon;

  const _ShortcutConfig({
    required this.id,
    required this.icon,
    required this.label,
    this.route,
    this.comingSoon = false,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TasbeehController tasbeehController = Get.put(TasbeehController());
  final AyahController ayahController = Get.put(AyahController());
  // إضافة متحكم الحديث
  final HadithController hadithController = Get.put(HadithController());
  // إضافة متحكم أوقات الصلاة
  final PrayerTimesController prayerController =
      Get.find<PrayerTimesController>();
  final AppSettingsController appSettings = Get.find<AppSettingsController>();

  String _appVersion = ''; // متغير لتخزين رقم الإصدار

  @override
  void initState() {
    super.initState();
    _loadAppVersion(); // استدعاء الدالة عند بدء تشغيل الصفحة
  }

  // دالة لجلب رقم الإصدار من pubspec.yaml
  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() => _appVersion = packageInfo.version);
    } catch (e) {
      print("Could not get app version: $e");
      setState(() => _appVersion = 'N/A');
    }
  }

  // دالة للتحقق مما إذا كان اليوم جمعة
  bool get isFriday {
    final now = DateTime.now();
    return now.weekday == DateTime.friday;
  }

  @override
  Widget build(BuildContext context) {
    // استخدم MediaQuery للحصول على أبعاد الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // لوحة الألوان
    final primaryColor = scheme.primary;
    final accentColor = scheme.secondary;
    final cardColor = scheme.surface;
    final iconBgColor = scheme.primary.withOpacity(isDark ? 0.2 : 0.12);
    final textPrimary = isDark ? Colors.white : scheme.onBackground;
    final textSecondary =
        isDark ? Colors.white70 : scheme.onBackground.withOpacity(0.7);
    const shortcuts = [
      _ShortcutConfig(
        id: 'quran',
        icon: 'assets/images/book.png',
        label: 'المصحف',
        route: AppRoute.quran,
      ),
      _ShortcutConfig(
        id: 'asma_allah',
        icon: 'assets/images/اسماء الله.png',
        label: 'اسماء الله',
        route: AppRoute.asmaAllah,
      ),
      _ShortcutConfig(
        id: 'pray_times',
        icon: 'assets/images/praytime.png',
        label: 'مواقيت الصلاة',
        route: AppRoute.prytime,
      ),
      _ShortcutConfig(
        id: 'zikr_groups',
        icon: 'assets/images/حلقات ذكر .png',
        label: 'حلقات الذكر',
        comingSoon: true,
      ),
      _ShortcutConfig(
        id: 'tasbeeh',
        icon: 'assets/images/الكترونية.png',
        label: 'المسبحة الإلكترونية',
        route: AppRoute.msbaha,
      ),
      _ShortcutConfig(
        id: 'qiblah',
        icon: 'assets/images/القبله.png',
        label: 'اتجاه القبلة',
        route: AppRoute.qiblah,
      ),
      _ShortcutConfig(
        id: 'istighfar_house',
        icon: 'assets/images/مسبحة.png',
        label: 'بيت الاستغفار',
        route: AppRoute.msbaha,
      ),
      _ShortcutConfig(
        id: 'fadel_al_duaa',
        icon: 'assets/images/استغفار.png',
        label: 'فضل الدعاء',
        route: AppRoute.fadelalduaa,
      ),
      _ShortcutConfig(
        id: 'ruqyah',
        icon: 'assets/images/الرقية الشرعية .png',
        label: 'الرقية الشرعية',
        route: AppRoute.alrugi,
      ),
      _ShortcutConfig(
        id: 'duaa_quran',
        icon: 'assets/images/ادعية قرانية .png',
        label: 'الأدعية القرآنية',
        route: AppRoute.aduqyQuran,
      ),
      _ShortcutConfig(
        id: 'duaa_nabuia',
        icon: 'assets/images/ادعية نبوية .png',
        label: 'أدعية نبوية',
        route: AppRoute.aduqyNabuia,
      ),
      _ShortcutConfig(
        id: 'duaa_prophets',
        icon: 'assets/images/ادعية الانبياء.png',
        label: 'أدعية الأنبياء',
        route: AppRoute.adaytalanbya,
      ),
      _ShortcutConfig(
        id: 'forty_hadith',
        icon: 'assets/images/الاربعون النووية .png',
        label: 'الأربعين النووية',
        route: AppRoute.alarboun,
      ),
      _ShortcutConfig(
        id: 'fadel_al_dhikr',
        icon: 'assets/images/رمضان .png',
        label: 'فضل الذكر',
        route: AppRoute.fadelaldaker,
      ),
      _ShortcutConfig(
        id: 'hajj_umrah',
        icon: 'assets/images/الحج والعمره .png',
        label: 'الحج والعمرة',
        comingSoon: true,
      ),
      _ShortcutConfig(
        id: 'prophet_stories',
        icon: 'assets/images/story.png',
        label: 'قصص الأنبياء',
        route: AppRoute.prophetStories,
      ),
      _ShortcutConfig(
        id: 'stories',
        icon: 'assets/images/story.png',
        label: 'القصص',
        route: AppRoute.stories,
      ),
      _ShortcutConfig(
        id: 'settings',
        icon: 'assets/images/اعدادات.png',
        label: 'الإعدادات',
        route: AppRoute.setting,
      ),
      _ShortcutConfig(
        id: 'quran_plan',
        icon: 'assets/images/book.png',
        label: 'خطة الختم',
        route: AppRoute.quranPlan,
      ),
      _ShortcutConfig(
        id: 'custom_adkar',
        icon: 'assets/images/مسبحة.png',
        label: 'أذكار خاصة',
        route: AppRoute.customAdkar,
      ),
      _ShortcutConfig(
        id: 'spiritual_stats',
        icon: 'assets/images/masseg icon.png',
        label: 'إحصائيات',
        route: AppRoute.spiritualStats,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: GetX<TasbeehController>(
            builder: (controller) {
              if (!controller.isPrefsInitialized.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: primaryColor),
                      const SizedBox(height: 20), // ارتفاع نسبي
                      Text(
                        "جاري تحميل البيانات...",
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 20, // حجم خط نسبي
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // --== ويدجت جديد لعرض الوقت والتاريخ والصلاة القادمة ==--
                    // نستخدم Obx هنا للاستماع إلى التغييرات في prayerController

                    // البسملة
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.04, // حشو علوي نسبي
                        bottom: screenHeight * 0.02, // حشو سفلي نسبي
                      ),
                      child: Center(
                        child: Text(
                              " بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ ",
                              style: TextStyle(
                                fontSize: screenWidth * 0.07, // حجم خط نسبي
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontFamily: 'Amiri',
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: primaryColor.withOpacity(0.5),
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 800.ms, delay: 200.ms)
                            .slideY(begin: 0.1, end: 0),
                      ),
                    ),

                    _buildHeaderSection(
                      context,
                      primaryColor,
                      accentColor,
                      screenWidth,
                    ),

                    // اختصارات
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.01,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      'اختصارات',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Container(
                                    width: screenWidth * 0.08,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          primaryColor.withOpacity(0.1),
                                          primaryColor.withOpacity(0.5),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              )
                              .animate()
                              .fadeIn(duration: 800.ms, delay: 350.ms)
                              .slideX(begin: 0.1, end: 0),
                          InkWell(
                                onTap:
                                    () =>
                                        _showShortcutPicker(context, shortcuts),
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: EdgeInsets.all(screenWidth * 0.02),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor.withOpacity(0.2),
                                        accentColor.withOpacity(0.18),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.25),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.18),
                                        blurRadius: 12,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: primaryColor,
                                    size: screenWidth * 0.05,
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 800.ms, delay: 400.ms)
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1, 1),
                              ),
                        ],
                      ),
                    ),

                    // الأيقونات الرئيسية باستخدام Wrap لجعلها تتكيف
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                      ), // هامش أفقي نسبي
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cardColor.withOpacity(0.9),
                            cardColor.withOpacity(0.65),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          screenWidth * 0.06,
                        ), // نصف قطر نسبي
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.05), // حشو نسبي
                      child: GetX<AppSettingsController>(
                        builder: (settings) {
                          final enabledIds =
                              settings.shortcutsLoaded.value
                                  ? settings.enabledShortcuts.value.toSet()
                                  : AppSettingsController.defaultShortcuts
                                      .toSet();
                          final visibleShortcuts =
                              shortcuts
                                  .where((item) => enabledIds.contains(item.id))
                                  .toList();

                          final columns = screenWidth > 420 ? 4 : 3;
                          final spacing = screenWidth * 0.035;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  childAspectRatio: 0.78,
                                ),
                            itemCount: visibleShortcuts.length,
                            itemBuilder: (context, index) {
                              final item = visibleShortcuts[index];
                              final accent =
                                  Color.lerp(
                                    scheme.primary,
                                    scheme.secondary,
                                    (index % 4) / 3,
                                  )!;
                              return _buildShortcut(
                                context,
                                icon: item.icon,
                                label: item.label,
                                onTap: () => _handleShortcutTap(context, item),
                                iconBgColor: accent,
                                sizeFactor: columns == 4 ? 0.16 : 0.2,
                              ).animate().scale(
                                delay: (500 + (index * 90)).ms,
                                duration: 350.ms,
                                curve: Curves.easeOutBack,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // رسالة يوم الجمعة (تظهر فقط يوم الجمعة)
                    if (isFriday) ...[
                      _buildSectionHeader(
                            context: context,
                            title: "رسالة يوم الجمعة",
                            onPressed: () {},
                            accentColor: accentColor,
                            screenWidth: screenWidth, // تمرير عرض الشاشة
                          )
                          .animate()
                          .fadeIn(delay: Duration(seconds: 1))
                          .slideX(begin: 0.1, end: 0),
                      Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04, // هامش أفقي نسبي
                              vertical: screenHeight * 0.01, // هامش عمودي نسبي
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.05,
                              ), // نصف قطر نسبي
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.05,
                              ), // نصف قطر نسبي
                              child: Image.asset(
                                "assets/images/سنن يوم الجمعة .jpeg",
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: Duration(seconds: 1))
                          .slideY(begin: 0.1, end: 0),
                    ],

                    // آية اليوم
                    _buildSectionHeader(
                          context: context,
                          title: "اية اليوم",
                          onPressed: () {},
                          accentColor: accentColor,
                          screenWidth: screenWidth,
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideX(begin: -0.1, end: 0),
                    _buildAyahCard(
                          context,
                          ayahController
                              .currentAyah, // تمرير المتغير التفاعلي مباشرة
                          primaryColor,
                          cardColor,
                          screenWidth,
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideY(begin: 0.1, end: 0),

                    // حديث اليوم
                    _buildSectionHeader(
                          context: context,
                          title: "حديث اليوم",
                          onPressed: () {},
                          accentColor: accentColor,
                          screenWidth: screenWidth,
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideX(begin: 0.1, end: 0),
                    // استخدام GetX لمراقبة التغييرات في hadithController
                    GetX<HadithController>(
                          builder: (controller) {
                            return _buildHadithCard(
                              context,
                              controller,
                              primaryColor,
                              cardColor,
                              screenWidth,
                            );
                          },
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideY(begin: 0.1, end: 0),

                    // أسماء الله الحسنى
                    _buildSectionHeader(
                          context: context,
                          title: "اسماء الله الحسنى",
                          onPressed: () {},
                          accentColor: accentColor,
                          screenWidth: screenWidth,
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideX(begin: -0.1, end: 0),
                    _buildAsmaAllahCard(
                          context,
                          tasbeehController
                              .currentAsmaAllah, // تمرير المتغير التفاعلي مباشرة
                          primaryColor,
                          cardColor,
                          screenWidth,
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideY(begin: 0.1, end: 0),

                    // تذييل الصفحة
                    SizedBox(height: screenHeight * 0.06), // ارتفاع نسبي
                    Text(
                          "ركن المسلم",
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: screenWidth * 0.08, // حجم خط نسبي
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri',
                            shadows: [
                              Shadow(
                                blurRadius: 8.0,
                                color: primaryColor.withOpacity(0.6),
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideY(begin: 0.1, end: 0),
                    Divider(
                      indent: screenWidth * 0.25, // هامش نسبي
                      endIndent: screenWidth * 0.25, // هامش نسبي
                      thickness: 3,
                      color: accentColor,
                    ).animate().fadeIn(delay: Duration(seconds: 1)),
                    SizedBox(height: screenHeight * 0.02), // ارتفاع نسبي
                    Text(
                      "V$_appVersion", // استخدام المتغير لعرض الإصدار
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: screenWidth * 0.035,
                      ), // حجم خط نسبي
                    ).animate().fadeIn(delay: Duration(seconds: 2)),
                    SizedBox(height: screenHeight * 0.04), // ارتفاع نسبي
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ================ Widgets مساعدة =================

  // الويدجت الجديد لعرض الوقت والتاريخ والصلاة القادمة
  Widget _buildHeaderSection(
    BuildContext context,
    Color primaryColor,
    Color accentColor,
    double screenWidth,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = scheme.surface;
    final cardText = scheme.onSurface;
    final cardTextSecondary = scheme.onSurface.withOpacity(0.7);
    final textSecondary = scheme.onBackground.withOpacity(0.7);

    // تهيئة التقويم الهجري باللغة العربية
    HijriCalendar.setLocal('ar');
    // تهيئة التقويم الهجري والميلادي
    var hijriDate = HijriCalendar.now();
    var gregorianDate = DateTime.now();
    // استخدام intl لتهيئة التاريخ
    var gregorianFormatter = DateFormat('EEEE, d MMMM yyyy', 'ar');

    Widget buildStatusCard({
      required IconData icon,
      required String title,
      required String message,
      Widget? action,
      Color? iconColor,
    }) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.02,
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(isDark ? 0.6 : 0.95),
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: iconColor ?? primaryColor,
              size: screenWidth * 0.09,
            ),
            SizedBox(height: screenWidth * 0.03),
            Text(
              title,
              style: TextStyle(
                color: cardText,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenWidth * 0.015),
            Text(
              message,
              style: TextStyle(
                color: cardTextSecondary,
                fontSize: screenWidth * 0.035,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: screenWidth * 0.03),
              action,
            ],
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
    }

    return GetX<AppSettingsController>(
      builder: (settings) {
        final isEnabled = settings.prayerTimesNotificationsEnabled.value;
        return GetBuilder<PrayerTimesController>(
          builder: (controller) {
            final hasLocation =
                controller.latitude.value != 0.0 &&
                controller.longitude.value != 0.0;

            if (!isEnabled) {
              return buildStatusCard(
                icon: Icons.notifications_off_outlined,
                title: 'أوقات الصلاة غير مفعّلة',
                message: 'فعّل مواقيت الصلاة من الإعدادات لعرض الأوقات.',
                action: OutlinedButton.icon(
                  onPressed: () => Get.toNamed(AppRoute.setting),
                  icon: const Icon(Icons.settings),
                  label: const Text('فتح الإعدادات'),
                ),
              );
            }

            if (!hasLocation) {
              return buildStatusCard(
                icon: Icons.my_location,
                title: 'حدد موقعك',
                message: 'يلزم تحديد المنطقة لعرض مواقيت الصلاة بدقة.',
                action: ElevatedButton.icon(
                  onPressed: () => controller.determinePosition(),
                  icon: const Icon(Icons.location_on),
                  label: const Text('تحديد الموقع'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: scheme.onPrimary,
                  ),
                ),
              );
            }

            if (controller.isLoading) {
              return buildStatusCard(
                icon: Icons.access_time,
                title: 'جاري تحميل أوقات الصلاة',
                message: 'يتم حساب الأوقات الآن، يرجى الانتظار.',
                action: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('تحميل...', style: TextStyle(color: textSecondary)),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return buildStatusCard(
                icon: Icons.wifi_off,
                title: 'تعذر جلب الأوقات',
                message: controller.errorMessage.value,
                iconColor: scheme.error,
                action: OutlinedButton.icon(
                  onPressed: () => controller.determinePosition(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              );
            }

            if (controller.prayerTimesData.isEmpty) {
              return buildStatusCard(
                icon: Icons.access_time_outlined,
                title: 'لا توجد أوقات متاحة',
                message: 'قم بتحديث الموقع لإظهار مواقيت الصلاة.',
                action: OutlinedButton.icon(
                  onPressed: () => controller.determinePosition(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث الموقع'),
                ),
              );
            }

            return StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, streamSnapshot) {
                final now = DateTime.now();
                final nextPrayerInfo = controller.getNextPrayer();
                final nextPrayerName = nextPrayerInfo['name'] ?? 'غير معروف';
                final nextPrayerTime = nextPrayerInfo['time'] as DateTime?;

                String countdown = '...';
                if (nextPrayerTime != null) {
                  final difference = nextPrayerTime.difference(now);
                  if (difference.isNegative) {
                    countdown = 'حان الآن';
                  } else {
                    final hours = difference.inHours;
                    final minutes = difference.inMinutes.remainder(60);
                    final seconds = difference.inSeconds.remainder(60);
                    countdown =
                        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                  }
                }
                final countdownLabel =
                    countdown == 'حان الآن'
                        ? 'حان الآن وقت صلاة $nextPrayerName'
                        : 'تبقى $countdown لصلاة $nextPrayerName';

                final prayerOrder = [
                  'الفجر',
                  'الشروق',
                  'الظهر',
                  'العصر',
                  'المغرب',
                  'العشاء',
                ];
                final prayerIcons = {
                  'الفجر': Icons.bedtime_outlined,
                  'الشروق': Icons.wb_sunny_outlined,
                  'الظهر': Icons.light_mode,
                  'العصر': Icons.brightness_5_outlined,
                  'المغرب': Icons.nights_stay_outlined,
                  'العشاء': Icons.dark_mode,
                };
                final prayerItems =
                    prayerOrder
                        .where(controller.prayerTimesData.containsKey)
                        .map(
                          (name) =>
                              MapEntry(name, controller.prayerTimesData[name]!),
                        )
                        .toList();

                final locationLabel =
                    controller.currentAddress.value.trim().isEmpty
                        ? 'حدد موقعك'
                        : controller.currentAddress.value;
                final methodLabel =
                    controller.calculationMethodNames[controller
                        .calculationMethod
                        .value] ??
                    'طريقة الحساب';
                final madhabLabel =
                    controller.madhabNames[controller.madhab.value] ?? 'المذهب';
                final nextPrayerTimeLabel =
                    nextPrayerTime != null
                        ? DateFormat('hh:mm a', 'ar').format(nextPrayerTime)
                        : '--:--';

                DateTime? previousPrayerTime;
                double progressValue = 0;
                if (prayerItems.isNotEmpty && nextPrayerTime != null) {
                  final today = DateTime(now.year, now.month, now.day);
                  final parsedTimes =
                      prayerItems.map((entry) {
                          final timeOfDay = controller.parseTimeOfDay(
                            entry.value,
                          );
                          return MapEntry(
                            entry.key,
                            DateTime(
                              today.year,
                              today.month,
                              today.day,
                              timeOfDay.hour,
                              timeOfDay.minute,
                            ),
                          );
                        }).toList()
                        ..sort((a, b) => a.value.compareTo(b.value));

                  final prevCandidates =
                      parsedTimes
                          .where((entry) => !entry.value.isAfter(now))
                          .toList();
                  if (prevCandidates.isNotEmpty) {
                    previousPrayerTime = prevCandidates.last.value;
                  } else {
                    previousPrayerTime = parsedTimes.last.value.subtract(
                      const Duration(days: 1),
                    );
                  }

                  var endTime = nextPrayerTime;
                  if (previousPrayerTime != null &&
                      endTime.isBefore(previousPrayerTime!)) {
                    endTime = endTime.add(const Duration(days: 1));
                  }
                  if (previousPrayerTime != null) {
                    final totalSeconds =
                        endTime.difference(previousPrayerTime!).inSeconds;
                    final elapsedSeconds =
                        now.difference(previousPrayerTime!).inSeconds;
                    if (totalSeconds > 0) {
                      progressValue = (elapsedSeconds / totalSeconds).clamp(
                        0.0,
                        1.0,
                      );
                    }
                  }
                }
                final progressPercent = (progressValue * 100)
                    .clamp(0, 100)
                    .toStringAsFixed(0);

                Widget buildDateChip(String label) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: scheme.onSurface.withOpacity(0.08),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: cardTextSecondary,
                        fontSize: screenWidth * 0.032,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                Widget buildInfoChip(String label, IconData icon) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.onSurface.withOpacity(0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 14, color: scheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: cardTextSecondary,
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.02,
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.048),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.065),
                    gradient: LinearGradient(
                      colors: [
                        scheme.surface,
                        scheme.surface.withOpacity(isDark ? 0.82 : 0.96),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.18),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.22),
                        blurRadius: 26,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.95),
                                  accentColor.withOpacity(0.95),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.mosque_outlined,
                              color: scheme.onPrimary,
                              size: screenWidth * 0.06,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'مواقيت الصلاة',
                                  style: TextStyle(
                                    color: cardText,
                                    fontSize: screenWidth * 0.052,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.place_outlined,
                                      size: 16,
                                      color: cardTextSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        locationLabel,
                                        style: TextStyle(
                                          color: cardTextSecondary,
                                          fontSize: screenWidth * 0.032,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: accentColor.withOpacity(0.4),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  nextPrayerName,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  nextPrayerTimeLabel,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          buildInfoChip(
                            'الطريقة: $methodLabel',
                            Icons.calculate_outlined,
                          ),
                          buildInfoChip(
                            'المذهب: $madhabLabel',
                            Icons.account_balance_outlined,
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.035),
                      Center(
                        child: Text(
                          DateFormat('hh:mm a', 'ar').format(now),
                          style: TextStyle(
                            color: cardText,
                            fontSize: screenWidth * 0.12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri',
                            shadows: [
                              Shadow(
                                blurRadius: 14,
                                color: primaryColor.withOpacity(0.35),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.onSurface.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            countdownLabel,
                            style: TextStyle(
                              color: cardTextSecondary,
                              fontSize: screenWidth * 0.036,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 10,
                          backgroundColor: scheme.onSurface.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'انقضى $progressPercent% من الوقت إلى الصلاة القادمة',
                        style: TextStyle(
                          color: cardTextSecondary,
                          fontSize: screenWidth * 0.03,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          buildDateChip(
                            'هجري: ${hijriDate.toFormat("dd MMMM yyyy")}',
                          ),
                          buildDateChip(
                            'ميلادي: ${gregorianFormatter.format(gregorianDate)}',
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.04),
                      Divider(
                        color: scheme.onSurface.withOpacity(0.08),
                        height: 1,
                      ),
                      SizedBox(height: screenWidth * 0.035),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: prayerItems.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: screenWidth > 420 ? 3 : 2,
                          crossAxisSpacing: screenWidth * 0.03,
                          mainAxisSpacing: screenWidth * 0.03,
                          childAspectRatio: 2.6,
                        ),
                        itemBuilder: (context, index) {
                          final entry = prayerItems[index];
                          final isNext = entry.key == nextPrayerName;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color:
                                  isNext
                                      ? accentColor.withOpacity(0.16)
                                      : scheme.onSurface.withOpacity(0.05),
                              border: Border.all(
                                color:
                                    isNext
                                        ? accentColor.withOpacity(0.5)
                                        : scheme.onSurface.withOpacity(0.08),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: screenWidth * 0.08,
                                  height: screenWidth * 0.08,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        isNext
                                            ? accentColor.withOpacity(0.2)
                                            : primaryColor.withOpacity(0.15),
                                  ),
                                  child: Icon(
                                    prayerIcons[entry.key] ?? Icons.access_time,
                                    size: screenWidth * 0.045,
                                    color: isNext ? accentColor : primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          color: cardText,
                                          fontSize: screenWidth * 0.034,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        entry.value,
                                        style: TextStyle(
                                          color: cardTextSecondary,
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildShortcut(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
    required Color iconBgColor,
    double sizeFactor = 0.18, // عامل نسبي لحجم الأيقونة
  }) {
    final double itemSize = MediaQuery.of(context).size.width * sizeFactor;
    final scheme = Theme.of(context).colorScheme;
    final textColor = scheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: itemSize * 0.12,
            horizontal: itemSize * 0.06,
          ),
          decoration: BoxDecoration(
            color: scheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: iconBgColor.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: iconBgColor.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: itemSize * 0.6,
                height: itemSize * 0.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconBgColor.withOpacity(0.28),
                      iconBgColor.withOpacity(0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    icon,
                    width: itemSize * 0.36,
                    height: itemSize * 0.36,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: itemSize * 0.12),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: itemSize * 0.16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShortcutPicker(
    BuildContext context,
    List<_ShortcutConfig> shortcuts,
  ) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'إدارة الاختصارات',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GetX<AppSettingsController>(
                      builder: (settings) {
                        final enabledIds =
                            settings.enabledShortcuts.value.toSet();
                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemBuilder: (context, index) {
                            final item = shortcuts[index];
                            return SwitchListTile.adaptive(
                              value: enabledIds.contains(item.id),
                              onChanged: (value) {
                                settings.setShortcutEnabled(item.id, value);
                              },
                              activeColor: scheme.primary,
                              title: Text(
                                item.label,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              secondary: CircleAvatar(
                                backgroundColor: scheme.primary.withOpacity(
                                  0.12,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Image.asset(item.icon),
                                ),
                              ),
                            );
                          },
                          separatorBuilder:
                              (_, __) => Divider(
                                color: scheme.onSurface.withOpacity(0.08),
                                height: 1,
                              ),
                          itemCount: shortcuts.length,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('تم'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleShortcutTap(BuildContext context, _ShortcutConfig item) {
    if (item.route != null) {
      Get.toNamed(item.route!);
      return;
    }
    if (item.comingSoon) {
      _showComingSoonDialog(context);
    }
  }

  void _showComingSoonDialog(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('قريبًا'),
          content: const Text('هذه الميزة قيد التطوير وستتوفر قريبًا.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: scheme.primary),
              child: const Text('حسنًا'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required VoidCallback onPressed,
    required Color accentColor,
    required double screenWidth, // استقبل عرض الشاشة
  }) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    return Padding(
      padding: EdgeInsets.only(
        top: screenWidth * 0.07, // حشو علوي نسبي
        bottom: screenWidth * 0.03, // حشو سفلي نسبي
        right: screenWidth * 0.06, // حشو أيمن نسبي
        left: screenWidth * 0.06, // حشو أيسر نسبي
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: accentColor,
              size: screenWidth * 0.05, // حجم أيقونة نسبي
            ),
            tooltip: 'عرض المزيد',
          ),
          Text(
            ": $title",
            style: TextStyle(
              color: textColor,
              fontSize: screenWidth * 0.05, // حجم خط نسبي
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: accentColor.withOpacity(0.3),
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahCard(
    BuildContext context,
    RxMap<String, String> item, // استقبال المتغير التفاعلي
    Color primaryColor,
    Color cardColor,
    double screenWidth, // استقبل عرض الشاشة
  ) {
    final String ayah =
        item.value["ayah"] ?? "جاري تحميل الآية..."; // الوصول للقيمة هنا
    final String surah = item["surah"] ?? "";
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
      ), // هامش أفقي نسبي
      padding: EdgeInsets.all(screenWidth * 0.05), // حشو نسبي
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(screenWidth * 0.05), // نصف قطر نسبي
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            ayah,
            style: TextStyle(
              color: textColor,
              fontSize: screenWidth * 0.055, // حجم خط نسبي
              fontWeight: FontWeight.w600,
              fontFamily: 'Amiri',
              height: 1.8,
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            textAlign: TextAlign.right,
            // textDirection: TextDirection.ltr,
          ),
          SizedBox(height: screenWidth * 0.05), // ارتفاع نسبي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _copyToClipboard(ayah, context),
                    icon: Icon(
                      Icons.copy_outlined,
                      color: primaryColor,
                      size: screenWidth * 0.06, // حجم أيقونة نسبي
                    ),
                    tooltip: 'نسخ الآية',
                  ),
                  IconButton(
                    onPressed:
                        () => _shareContent(
                          'آية اليوم:\n\n"$ayah"\n- $surah',
                          context,
                        ),
                    icon: Icon(
                      Icons.share_rounded,
                      color: primaryColor,
                      size: screenWidth * 0.06, // حجم أيقونة نسبي
                    ),
                    tooltip: 'مشاركة الآية',
                  ),
                ],
              ),
              Text(
                surah,
                style: TextStyle(
                  color: primaryColor,
                  fontStyle: FontStyle.italic,
                  fontSize: screenWidth * 0.04, // حجم خط نسبي
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHadithCard(
    BuildContext context,
    HadithController controller, // استقبال المتحكم
    Color primaryColor,
    Color cardColor,
    double screenWidth, // استقبل عرض الشاشة
  ) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
      ), // هامش أفقي نسبي
      padding: EdgeInsets.all(screenWidth * 0.05), // حشو نسبي
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(screenWidth * 0.05), // نصف قطر نسبي
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // التحقق من حالة التحميل والخطأ
          if (controller.isLoading.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Colors.cyan),
              ),
            )
          else if (controller.errorMessage.value.isNotEmpty &&
              controller.currentHadith.value == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: screenWidth * 0.04,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (controller.currentHadith.value != null)
            Text(
              controller.currentHadith.value!.text!,
              style: TextStyle(
                color: textColor,
                fontSize: screenWidth * 0.05, // حجم خط نسبي
                fontWeight: FontWeight.w600,
                height: 1.6,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black.withOpacity(0.4),
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.right,
            ),
          SizedBox(height: screenWidth * 0.05), // ارتفاع نسبي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (controller.currentHadith.value != null)
                        _copyToClipboard(
                          controller.currentHadith.value!.text!,
                          context,
                        );
                    },
                    icon: Icon(
                      Icons.copy_outlined,
                      color: primaryColor,
                      size: screenWidth * 0.06, // حجم أيقونة نسبي
                    ),
                    tooltip: 'نسخ الحديث',
                  ),
                  IconButton(
                    onPressed: () {
                      if (controller.currentHadith.value != null)
                        _shareContent(
                          'حديث اليوم:\n\n"${controller.currentHadith.value!.text}"\n- ${controller.currentHadith.value!.source}',
                          context,
                        );
                    },
                    icon: Icon(
                      Icons.share_rounded,
                      color: primaryColor,
                      size: screenWidth * 0.06, // حجم أيقونة نسبي
                    ),
                    tooltip: 'مشاركة الحديث',
                  ),
                ],
              ),
              if (controller.currentHadith.value != null)
                Text(
                  controller.currentHadith.value!.source!,
                  style: TextStyle(
                    color: primaryColor,
                    fontStyle: FontStyle.italic,
                    fontSize: screenWidth * 0.04, // حجم خط نسبي
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAsmaAllahCard(
    BuildContext context,
    RxMap<String, String> asmaAllahData, // استقبال المتغير التفاعلي
    Color primaryColor,
    Color cardColor,
    double screenWidth, // استقبل عرض الشاشة
  ) {
    final String name =
        asmaAllahData.value["name"] ?? "جاري التحميل..."; // الوصول للقيمة هنا
    final String dis = asmaAllahData.value["dis"] ?? "يرجى الانتظار.";
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
      ), // هامش أفقي نسبي
      padding: EdgeInsets.all(screenWidth * 0.05), // حشو نسبي
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(screenWidth * 0.05), // نصف قطر نسبي
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: screenWidth * 0.03,
              bottom: screenWidth * 0.02,
            ), // حشو نسبي
            child: Text(
                  name,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: screenWidth * 0.12, // حجم خط نسبي كبير للاسم
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: primaryColor.withOpacity(0.6),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                )
                .animate(key: ValueKey(name))
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1, end: 0),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.025,
            ), // حشو نسبي
            child: Text(
                  dis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: screenWidth * 0.045, // حجم خط نسبي
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.right,
                )
                .animate(key: ValueKey(dis))
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.1, end: 0),
          ),
          Divider(
            indent: screenWidth * 0.05, // هامش نسبي
            endIndent: screenWidth * 0.05, // هامش نسبي
            color: Colors.grey,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenWidth * 0.025,
            ), // حشو نسبي
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => _copyToClipboard(name, context),
                  icon: Icon(
                    Icons.copy_outlined,
                    color: primaryColor,
                    size: screenWidth * 0.06, // حجم أيقونة نسبي
                  ),
                  tooltip: 'نسخ الاسم',
                ),
                IconButton(
                  onPressed:
                      () => _shareContent(
                        'من أسماء الله الحسنى:\n\n$name\n\n$dis',
                        context,
                      ),
                  icon: Icon(
                    Icons.share_rounded,
                    color: primaryColor,
                    size: screenWidth * 0.06, // حجم أيقونة نسبي
                  ),
                  tooltip: 'مشاركة الاسم',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: scheme.primary,
        content: Text(
          "تم النسخ بنجاح",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: scheme.onPrimary,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.02,
          left: MediaQuery.of(context).size.width * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
        ),
      ),
    );
  }

  void _shareContent(String text, BuildContext context) {
    // هذا السطر يساعد في تحديد مكان ظهور قائمة المشاركة على أجهزة iPad
    final box = context.findRenderObject() as RenderBox?;

    Share.share(
      text,
      subject:
          'مشاركة من تطبيق ركن المسلم', // عنوان المشاركة (يظهر في الإيميل مثلاً)
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
