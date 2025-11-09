import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rokenalmuslem/core/constant/appcolor.dart';
import 'package:share_plus/share_plus.dart';

// تأكد من المسار الصحيح لوحدة التحكم الخاصة بك
import 'package:rokenalmuslem/controller/ayah_controller.dart';
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart';
import 'package:rokenalmuslem/controller/hadith_controller.dart'; // إضافة متحكم الحديث
import 'package:rokenalmuslem/controller/more/masbahacontroller.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';

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
  final PrayerTimesController prayerController = Get.put(
    PrayerTimesController(),
  );

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

    // لوحة الألوان
    const primaryColor = Color(0xFF8FBC8F);
    const accentColor = Color(0xFFD4AF37);
    const bgColorStart = Color(0xFF0D1B2A);
    const bgColorEnd = Color(0xFF0F0F1A);
    const cardColor = Color(0xFF1A2A3A);
    const iconBgColor = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColorStart, bgColorEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Obx(() {
            if (!tasbeehController.isPrefsInitialized.value) {
              // هذا الشرط سيبقى كما هو لأنه يعمل بشكل صحيح
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    SizedBox(height: 20), // ارتفاع نسبي
                    Text(
                      "جاري تحميل البيانات...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20, // حجم خط نسبي
                      ),
                    ),
                  ],
                ),
              );
            } else {
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
                                fontFamily: 'Uthmanic',
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
                        horizontal: screenWidth * 0.05, // حشو أفقي نسبي
                        vertical: screenHeight * 0.01, // حشو عمودي نسبي
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                                ": اختصارات",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.045, // حجم خط نسبي
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 800.ms, delay: 400.ms)
                              .slideX(begin: 0.1, end: 0),
                        ],
                      ),
                    ),

                    // الأيقونات الرئيسية باستخدام Wrap لجعلها تتكيف
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                      ), // هامش أفقي نسبي
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(
                          screenWidth * 0.06,
                        ), // نصف قطر نسبي
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 15,
                            spreadRadius: 3,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.05), // حشو نسبي
                      child: Wrap(
                        // استخدام Wrap
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: screenWidth * 0.03, // مسافة أفقية نسبية
                        runSpacing: screenHeight * 0.02, // مسافة عمودية نسبية
                        children: [
                          _buildShortcut(
                            context,
                            icon: "assets/images/اسماء الله.png",
                            label: "اسماء الله",
                            onTap: () {
                              Get.toNamed(AppRoute.asmaAllah);
                            },
                            iconBgColor: iconBgColor,
                            sizeFactor: 0.18, // حجم نسبي للأيقونة
                          ).animate().scale(
                            delay: 600.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                          // _buildShortcut(
                          //   context,
                          //   icon: "assets/images/حلقات ذكر .png",
                          //   label: "حلقات ذكر",
                          //   onTap: () {

                          //   },
                          //   iconBgColor: iconBgColor,
                          //   sizeFactor: 0.18,
                          // ).animate().scale(
                          //   delay: 700.ms,
                          //   duration: 400.ms,
                          //   curve: Curves.easeOutBack,
                          // ),
                          _buildShortcut(
                            context,
                            icon: "assets/images/مسبحة.png",
                            label: "بيت الاستغفار",
                            onTap: () {
                              Get.toNamed(AppRoute.msbaha);
                            },
                            iconBgColor: iconBgColor,
                            sizeFactor: 0.18,
                          ).animate().scale(
                            delay: 800.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                          _buildShortcut(
                            context,
                            icon: "assets/images/الاربعون النووية .png",
                            label: "الأربعين النووية",
                            onTap: () {
                              Get.toNamed(AppRoute.alarboun);
                            },
                            iconBgColor: iconBgColor,
                            sizeFactor: 0.18,
                          ).animate().scale(
                            delay: 900.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                        ],
                      ),
                    ),

                    // رسالة يوم الجمعة (تظهر فقط يوم الجمعة)
                    if (isFriday) ...[
                      _buildSectionHeader(
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
                          title: "اية اليوم",
                          onPressed: () {},
                          accentColor: accentColor,
                          screenWidth: screenWidth,
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideX(begin: -0.1, end: 0),
                    _buildAyahCard(
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
                          title: "حديث اليوم",
                          onPressed: () {},
                          accentColor: accentColor,
                          screenWidth: screenWidth,
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideX(begin: 0.1, end: 0),
                    // استخدام Obx لمراقبة التغييرات في hadithController
                    Obx(() {
                          return _buildHadithCard(
                            hadithController,
                            primaryColor,
                            cardColor,
                            screenWidth,
                          );
                        })
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideY(begin: 0.1, end: 0),

                    // أسماء الله الحسنى
                    _buildSectionHeader(
                          title: "اسماء الله الحسنى",
                          onPressed: () {},
                          accentColor: accentColor,
                          screenWidth: screenWidth,
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideX(begin: -0.1, end: 0),
                    _buildAsmaAllahCard(
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
                            fontFamily: 'Uthmanic',
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
            }
          }),
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
    // تهيئة التقويم الهجري باللغة العربية
    HijriCalendar.setLocal('ar');
    // تهيئة التقويم الهجري والميلادي
    var hijriDate = HijriCalendar.now();
    var gregorianDate = DateTime.now();
    // استخدام intl لتهيئة التاريخ
    var gregorianFormatter = DateFormat('EEEE, d MMMM yyyy', 'ar');
    return FutureBuilder<void>(
      future: prayerController.initializationFuture,
      builder: (context, snapshot) {
        // في حالة التحميل أو عدم وجود بيانات بعد
        if (prayerController.isLoading ||
            snapshot.connectionState == ConnectionState.waiting ||
            prayerController.prayerTimesData.isEmpty) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "جاري تحميل أوقات الصلاة...",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(width: 10),
                  CircularProgressIndicator(strokeWidth: 2),
                ],
              ),
            ),
          );
        }

        // في حالة حدوث خطأ
        if (snapshot.hasError) {
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Center(
              child: Text(
                prayerController.errorMessage.value.isNotEmpty
                    ? prayerController.errorMessage.value
                    : "خطأ في تحميل أوقات الصلاة: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        // في حالة اكتمال التحميل بنجاح، نعرض الساعة والعداد
        return StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (context, streamSnapshot) {
            final now = DateTime.now();
            final nextPrayerInfo = prayerController.getNextPrayer();
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

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.02,
              ),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A3A).withOpacity(0.7),
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
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
                  // التاريخ الميلادي والهجري
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hijriDate.toFormat("d MMMM yyyy"),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        gregorianFormatter.format(gregorianDate),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: primaryColor.withOpacity(0.4), height: 20),
                  // الوقت الحالي
                  Text(
                    DateFormat('hh:mm:ss a', 'ar').format(now),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: primaryColor.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // الصلاة القادمة والعداد التنازلي
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        countdown,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ': صلاة $nextPrayerName بعد ',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
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
    return SizedBox(
      width: itemSize * 1.2, // لتوفير مساحة للنص تحت الأيقونة
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(itemSize / 2),
            child: Container(
              height: itemSize,
              width: itemSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconBgColor.withOpacity(0.8),
                    iconBgColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(itemSize / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: iconBgColor.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(itemSize * 0.2),
                child: Image.asset(
                  icon,
                  fit: BoxFit.contain,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
          SizedBox(height: itemSize * 0.08), // ارتفاع نسبي بين الأيقونة والنص
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: itemSize * 0.18, // حجم خط نسبي
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onPressed,
    required Color accentColor,
    required double screenWidth, // استقبل عرض الشاشة
  }) {
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
              color: Colors.white.withOpacity(0.95),
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
    RxMap<String, String> item, // استقبال المتغير التفاعلي
    Color primaryColor,
    Color cardColor,
    double screenWidth, // استقبل عرض الشاشة
  ) {
    final String ayah =
        item.value["ayah"] ?? "جاري تحميل الآية..."; // الوصول للقيمة هنا
    final String surah = item["surah"] ?? "";

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
              color: Colors.white.withOpacity(0.95),
              fontSize: screenWidth * 0.055, // حجم خط نسبي
              fontWeight: FontWeight.w600,
              fontFamily: 'Uthmanic',
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
    HadithController controller, // استقبال المتحكم
    Color primaryColor,
    Color cardColor,
    double screenWidth, // استقبل عرض الشاشة
  ) {
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
                color: Colors.white.withOpacity(0.95),
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
    RxMap<String, String> asmaAllahData, // استقبال المتغير التفاعلي
    Color primaryColor,
    Color cardColor,
    double screenWidth, // استقبل عرض الشاشة
  ) {
    final String name =
        asmaAllahData.value["name"] ?? "جاري التحميل..."; // الوصول للقيمة هنا
    final String dis = asmaAllahData.value["dis"] ?? "يرجى الانتظار.";

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
                    fontFamily: 'Uthmanic',
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
                    color: Colors.white.withOpacity(0.9),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xff8FBC8F),
        content: const Text(
          "تم النسخ بنجاح",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
