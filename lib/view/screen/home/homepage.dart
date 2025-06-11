import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

// تأكد من المسار الصحيح لوحدة التحكم الخاصة بك
import 'package:rokenalmuslem/controller/more/masbahacontroller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> items = [
    {
      "ayah": "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
      "sorah": "سورة الشرح",
      "hadyth": "من سلك طريقًا يلتمس فيه علمًا سهل الله له به طريقًا إلى الجنة",
      "alrawy": "رواه مسلم",
    },
  ];

  final TasbeehController tasbeehController = Get.put(TasbeehController());

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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    SizedBox(height: screenHeight * 0.02), // ارتفاع نسبي
                    Text(
                      "جاري تحميل البيانات...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: screenWidth * 0.04, // حجم خط نسبي
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
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
                                "اختصارات:",
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
                            onTap: () {},
                            iconBgColor: iconBgColor,
                            sizeFactor: 0.18, // حجم نسبي للأيقونة
                          ).animate().scale(
                            delay: 600.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                          _buildShortcut(
                            context,
                            icon: "assets/images/حلقات ذكر .png",
                            label: "حلقات ذكر",
                            onTap: () {},
                            iconBgColor: iconBgColor,
                            sizeFactor: 0.18,
                          ).animate().scale(
                            delay: 700.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                          _buildShortcut(
                            context,
                            icon: "assets/images/مسبحة.png",
                            label: "بيت الاستغفار",
                            onTap: () {},
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
                            onTap: () {},
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

                    // رسالة يوم الجمعة
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
                          items[0],
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
                    _buildHadithCard(
                          items[0],
                          primaryColor,
                          cardColor,
                          screenWidth,
                        )
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
                    Obx(
                          () => _buildAsmaAllahCard(
                            tasbeehController.currentAsmaAllah.value,
                            primaryColor,
                            cardColor,
                            screenWidth,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: Duration(seconds: 1))
                        .slideY(begin: 0.1, end: 0),

                    // تذييل الصفحة
                    SizedBox(height: screenHeight * 0.06), // ارتفاع نسبي
                    Text(
                          "أذكاري",
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
                      "V1.0.0",
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
                    iconBgColor.withValues(alpha: 0.8),
                    iconBgColor.withValues(alpha: 0.8),
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
    Map<String, String> item,
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
          Text(
            item["ayah"]!,
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
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: screenWidth * 0.05), // ارتفاع نسبي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _copyToClipboard(item["ayah"]!, context),
                    icon: Icon(
                      Icons.copy_outlined,
                      color: primaryColor,
                      size: screenWidth * 0.06, // حجم أيقونة نسبي
                    ),
                    tooltip: 'نسخ الآية',
                  ),
                  IconButton(
                    onPressed: () {
                      /* TODO: إضافة وظيفة المشاركة */
                    },
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
                item["sorah"]!,
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
    Map<String, String> item,
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
          Text(
            item["hadyth"]!,
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
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: screenWidth * 0.05), // ارتفاع نسبي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _copyToClipboard(item["hadyth"]!, context),
                    icon: Icon(
                      Icons.copy_outlined,
                      color: primaryColor,
                      size: screenWidth * 0.06, // حجم أيقونة نسبي
                    ),
                    tooltip: 'نسخ الحديث',
                  ),
                  IconButton(
                    onPressed: () {
                      /* TODO: إضافة وظيفة المشاركة */
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
              Text(
                item["alrawy"]!,
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
    Map<String, String> asmaAllahData,
    Color primaryColor,
    Color cardColor,
    double screenWidth, // استقبل عرض الشاشة
  ) {
    final String name = asmaAllahData["name"] ?? "جاري التحميل...";
    final String dis = asmaAllahData["dis"] ?? "يرجى الانتظار.";

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
                  textAlign: TextAlign.center,
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
                  onPressed: () {
                    /* TODO: إضافة وظيفة المشاركة */
                  },
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
}
