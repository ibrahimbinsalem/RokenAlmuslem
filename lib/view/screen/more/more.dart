import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/wedgit/buttons/customdrawer.dart'; // تأكد من أن هذا المسار صحيح في مشروعك

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // خلفية أغمق قليلاً وأكثر نعومة
      endDrawer: CustomDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100, // زيادة ارتفاع الشريط العلوي لإعطاء مساحة أكبر
            pinned: true,
            centerTitle: true,
            floating: true,
            elevation: 8, // إضافة ظل للشريط العلوي
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                bottom: 16.0,
              ), // مسافة سفلية للعنوان
              title: Center(
                child: const Text(
                  'المزيد',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24, // حجم أكبر للعنوان
                    letterSpacing: 1.2, // تباعد بين الحروف
                  ),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal[900]!,
                      Colors.teal[700]!,
                      Colors.teal[500]!,
                    ], // تدرج لوني أغنى
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Opacity(
                  opacity: 0.1, // تقليل شفافية الصورة أكثر
                  child: Image.asset(
                    'assets/images/حلقات ذكر .png',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3), // لون تراكب أغمق
                    colorBlendMode: BlendMode.dstATop, // وضع دمج لتحسين المظهر
                  ),
                ),
              ),
            ),
            actions: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      Scaffold.of(
                        context,
                      ).openEndDrawer(); // فتح القائمة الجانبية
                    },
                    splashRadius: 24, // حجم تأثير النقر
                  );
                },
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0, // تحديد أقصى عرض لكل عنصر
                crossAxisSpacing: 13,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9, // تعديل نسبة العرض إلى الارتفاع
              ), // استخدام هذا الـ delegate يجعله متجاوبًا
              delegate: SliverChildListDelegate([
                _buildFeatureCard(
                  title: "مواقيت الصلاه",
                  image: "assets/images/praytime.png",
                  color: Colors.deepPurpleAccent, // لون بنفسجي زاهي
                  onTap: () {
                    Get.toNamed(AppRoute.prytime);
                  },
                ),
                _buildFeatureCard(
                  title: "أسماء الله الحسنى",
                  image: "assets/images/اسماء الله.png",
                  color: Colors.lightBlueAccent, // لون أزرق فاتح زاهي
                  onTap: () {
                    Get.toNamed(AppRoute.asmaAllah);
                  },
                ),
                _buildFeatureCard(
                  title: "حلقات الذكر",
                  image: "assets/images/حلقات ذكر .png",
                  color: Colors.blueAccent, // لون أزرق زاهي
                  onTap: () {
                    _showComingSoonDialog(context);
                  },
                ),
                _buildFeatureCard(
                  title: "المسبحة الإلكترونية",
                  image: "assets/images/الكترونية.png",
                  color: Colors.lightGreenAccent, // لون أخضر فاتح زاهي
                  onTap: () {
                    Get.toNamed(AppRoute.msbaha);
                  },
                ),
                // _buildFeatureCard(
                //   title: "أذكار المسلم",
                //   image: "assets/images/دعاء.png",
                //   color: Colors.amberAccent, // لون كهرماني زاهي
                //   onTap: () {},
                // ),
                _buildFeatureCard(
                  title: "اتجاه القبلة",
                  image: "assets/images/القبله.png",
                  color: Colors.orangeAccent, // لون برتقالي زاهي
                  onTap: () {
                    Get.toNamed(AppRoute.qiblah);
                  },
                ),
                _buildFeatureCard(
                  title: "بيت الاستغفار",
                  image: "assets/images/مسبحة.png",
                  color: Colors.cyanAccent, // لون سماوي زاهي
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "فضل الدعاء",
                  image: "assets/images/استغفار.png",
                  color: Colors.indigoAccent, // لون نيلي زاهي
                  onTap: () {
                    Get.toNamed(AppRoute.fadelalduaa);
                  },
                ),
                _buildFeatureCard(
                  title: "الرقية الشرعية",
                  image: "assets/images/الرقية الشرعية .png",
                  color: Colors.redAccent, // لون أحمر زاهي
                  onTap: () {
                    Get.toNamed(AppRoute.alrugi);
                  },
                ),
                _buildFeatureCard(
                  title: "الأدعية القرآنية",
                  image: "assets/images/ادعية قرانية .png",
                  color: Colors.tealAccent, // لون تركوازي زاهي
                  onTap: () {
                    Get.toNamed(AppRoute.aduqyQuran);
                  },
                ),
                _buildFeatureCard(
                  title: "أدعية نبوية",
                  image: "assets/images/ادعية نبوية .png",
                  color: Colors.brown.shade300, // لون بني فاتح
                  onTap: () {
                    Get.toNamed(AppRoute.aduqyNabuia);
                  },
                ),
                _buildFeatureCard(
                  title: "أدعية الأنبياء",
                  image: "assets/images/ادعية الانبياء.png",
                  color: Colors.pinkAccent, // لون وردي زاهي
                  onTap: () {
                    Get.toNamed(AppRoute.adaytalanbya);
                  },
                ),
                _buildFeatureCard(
                  title: "الأربعين النووية",
                  image: "assets/images/الاربعون النووية .png",
                  color: Colors.deepOrangeAccent, // لون برتقالي داكن زاهي
                  onTap: () {
                    Get.toNamed(AppRoute.alarboun);
                  },
                ),
                _buildFeatureCard(
                  title: "فضل الذكر",
                  image: "assets/images/رمضان .png",
                  color: Colors.limeAccent, // لون ليموني زاهي
                  onTap: () {
                    Get.toNamed(AppRoute.fadelaldaker);
                  },
                ),
                _buildFeatureCard(
                  title: "الحج والعمرة",
                  image: "assets/images/الحج والعمره .png",
                  color: Colors.purpleAccent, // لون أرجواني زاهي
                  onTap: () {
                    _showComingSoonDialog(context);
                  },
                ),
                _buildFeatureCard(
                  title: "القصص",
                  image: "assets/images/story.png",
                  color: Colors.purpleAccent, // لون أرجواني زاهي
                  onTap: () {
                    _showComingSoonDialog(context);
                  },
                ),
                _buildFeatureCard(
                  title: "الإعدادات",
                  image: "assets/images/اعدادات.png",
                  color: Colors.grey.shade400, // لون رمادي فاتح
                  onTap: () {
                    Get.toNamed(AppRoute.setting);
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String image,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6, // زيادة الظل للبطاقات
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ), // زوايا أكثر استدارة
      clipBehavior: Clip.antiAlias, // لضمان ظهور التدرج بشكل صحيح داخل الحدود
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          // استخدام Ink لتطبيق التدرج اللوني
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // تدرج لوني خفيف للبطاقة
              colors: [
                const Color(0xFF2B2B2B), // لون أساسي أغمق للبطاقة
                const Color(0xFF1E1E1E).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1.5,
            ), // حدود أكثر بروزًا
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(
                    18,
                  ), // مساحة داخلية أكبر للأيقونة
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      // تدرج شعاعي لخلفية الأيقونة
                      colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                      radius: 0.8,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.5), // حدود الأيقونة
                      width: 2,
                    ),
                    boxShadow: [
                      // ظل للأيقونة
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    image,
                    width: 45,
                    height: 45,
                  ), // حجم أكبر للأيقونة
                ),
                const SizedBox(height: 16), // مسافة أكبر
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17, // حجم خط أكبر
                    fontWeight: FontWeight.bold,
                    shadows: [
                      // ظل خفيف للنص
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10), // مسافة أكبر
                Container(
                  height: 3, // سمك أكبر للخط الفاصل
                  width: 60, // طول أكبر للخط الفاصل
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // تدرج لوني للخط الفاصل
                      colors: [
                        color.withOpacity(0.1),
                        color,
                        color.withOpacity(0.1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C2C2C), // لون خلفية أغمق للمربع
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25), // زوايا أكثر استدارة
            ),
            title: const Column(
              children: [
                Icon(
                  Icons.hourglass_empty, // أيقونة "قريبًا"
                  color: Colors.amberAccent,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  "قريبا",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: const Text(
              "سيتم إضافة هذه الميزات قريباً بإذن الله",
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center, // توسيط الزر
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.teal, // زر بلون مميز
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  "حسناً",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }
}
