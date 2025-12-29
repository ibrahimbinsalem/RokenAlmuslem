import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/wedgit/buttons/customdrawer.dart'; // تأكد من أن هذا المسار صحيح في مشروعك
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      endDrawer: CustomDrawer(),
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 110,
              pinned: true,
              centerTitle: true,
              floating: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(bottom: 14.0),
                title: Center(
                  child: Text(
                    'المزيد',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary.withOpacity(0.9),
                        scheme.secondary.withOpacity(0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Opacity(
                    opacity: isDark ? 0.1 : 0.12,
                    child: Image.asset(
                      'assets/images/حلقات ذكر .png',
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.2),
                      colorBlendMode: BlendMode.dstATop,
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
                        Scaffold.of(context).openEndDrawer();
                      },
                      splashRadius: 24,
                    );
                  },
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.0,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.92,
                ),
                delegate: SliverChildListDelegate([
                _buildFeatureCard(context, 
                  title: "مواقيت الصلاه",
                  image: "assets/images/praytime.png",
                  color: scheme.primary,
                  onTap: () {
                    Get.toNamed(AppRoute.prytime);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "المصحف",
                  image: "assets/images/book.png",
                  color: scheme.secondary,
                  onTap: () {
                    Get.toNamed(AppRoute.quran);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "خطة ختم القرآن",
                  image: "assets/images/book.png",
                  color: scheme.tertiary,
                  onTap: () {
                    Get.toNamed(AppRoute.quranPlan);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "خطة اليوم",
                  image: "assets/images/book.png",
                  color: scheme.primary.withOpacity(0.85),
                  onTap: () {
                    Get.toNamed(AppRoute.dailyPlan);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "أذكار خاصة",
                  image: "assets/images/مسبحة.png",
                  color: scheme.tertiary,
                  onTap: () {
                    Get.toNamed(AppRoute.customAdkar);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "إحصائيات روحانية",
                  image: "assets/images/masseg icon.png",
                  color: scheme.primary.withOpacity(0.85),
                  onTap: () {
                    Get.toNamed(AppRoute.spiritualStats);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "أسماء الله الحسنى",
                  image: "assets/images/اسماء الله.png",
                  color: scheme.secondary,
                  onTap: () {
                    Get.toNamed(AppRoute.asmaAllah);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "حلقات الذكر",
                  image: "assets/images/حلقات ذكر .png",
                  color: scheme.tertiary,
                  onTap: () {
                    _showComingSoonDialog(context);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "المسبحة الإلكترونية",
                  image: "assets/images/الكترونية.png",
                  color: scheme.primary.withOpacity(0.8),
                  onTap: () {
                    Get.toNamed(AppRoute.msbaha);
                  },
                ),
                // _buildFeatureCard(context, 
                //   title: "أذكار المسلم",
                //   image: "assets/images/دعاء.png",
                //   color: Colors.amberAccent, // لون كهرماني زاهي
                //   onTap: () {},
                // ),
                _buildFeatureCard(context, 
                  title: "اتجاه القبلة",
                  image: "assets/images/القبله.png",
                  color: scheme.secondary.withOpacity(0.8),
                  onTap: () {
                    Get.toNamed(AppRoute.qiblah);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "بيت الاستغفار",
                  image: "assets/images/مسبحة.png",
                  color: scheme.tertiary.withOpacity(0.8),
                  onTap: () {},
                ),
                _buildFeatureCard(context, 
                  title: "فضل الدعاء",
                  image: "assets/images/استغفار.png",
                  color: scheme.primary.withOpacity(0.7),
                  onTap: () {
                    Get.toNamed(AppRoute.fadelalduaa);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "الرقية الشرعية",
                  image: "assets/images/الرقية الشرعية .png",
                  color: scheme.secondary.withOpacity(0.7),
                  onTap: () {
                    Get.toNamed(AppRoute.alrugi);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "الأدعية القرآنية",
                  image: "assets/images/ادعية قرانية .png",
                  color: scheme.tertiary.withOpacity(0.7),
                  onTap: () {
                    Get.toNamed(AppRoute.aduqyQuran);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "أدعية نبوية",
                  image: "assets/images/ادعية نبوية .png",
                  color: scheme.primary.withOpacity(0.6),
                  onTap: () {
                    Get.toNamed(AppRoute.aduqyNabuia);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "أدعية الأنبياء",
                  image: "assets/images/ادعية الانبياء.png",
                  color: scheme.secondary.withOpacity(0.6),
                  onTap: () {
                    Get.toNamed(AppRoute.adaytalanbya);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "الأربعين النووية",
                  image: "assets/images/الاربعون النووية .png",
                  color: scheme.tertiary.withOpacity(0.6),
                  onTap: () {
                    Get.toNamed(AppRoute.alarboun);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "فضل الذكر",
                  image: "assets/images/رمضان .png",
                  color: scheme.primary.withOpacity(0.5),
                  onTap: () {
                    Get.toNamed(AppRoute.fadelaldaker);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "الحج والعمرة",
                  image: "assets/images/الحج والعمره .png",
                  color: scheme.secondary.withOpacity(0.5),
                  onTap: () {
                    _showComingSoonDialog(context);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "قصص الأنبياء",
                  image: "assets/images/story.png",
                  color: scheme.tertiary.withOpacity(0.5),
                  onTap: () {
                    Get.toNamed(AppRoute.prophetStories);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "القصص",
                  image: "assets/images/story.png",
                  color: scheme.primary.withOpacity(0.55),
                  onTap: () {
                    Get.toNamed(AppRoute.stories);
                  },
                ),
                _buildFeatureCard(context, 
                  title: "الإعدادات",
                  image: "assets/images/اعدادات.png",
                  color: scheme.onSurface.withOpacity(0.4),
                  onTap: () {
                    Get.toNamed(AppRoute.setting);
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String image,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [color.withOpacity(0.25), color.withOpacity(0.05)],
                    radius: 0.8,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.45),
                    width: 1.5,
                  ),
                ),
                child: Image.asset(
                  image,
                  width: 42,
                  height: 42,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                height: 3,
                width: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.12),
                      color,
                      color.withOpacity(0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08);
  }

  void _showComingSoonDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Column(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  color: theme.colorScheme.secondary,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  "قريبا",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Text(
              "سيتم إضافة هذه الميزات قريباً بإذن الله",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
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
