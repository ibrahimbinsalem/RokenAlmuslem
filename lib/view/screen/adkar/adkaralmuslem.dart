import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:rokenalmuslem/core/constant/routes.dart'; // تأكد من أن هذا المسار صحيح

class AdkarAlmuslam extends StatelessWidget {
  const AdkarAlmuslam({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم Theme.of(context) للحصول على الثيم الحالي الذي تم بناؤه في main.dart
    final ThemeData currentTheme = Theme.of(context);

    return Scaffold(
      backgroundColor:
          currentTheme.colorScheme.surface, // خلفية متناسقة مع الثيم
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: false,
            centerTitle: true, // هذا يوسّط العنوان في SliverAppBar
            floating: true, // للسماح بالشريط بالاختفاء والظهور بسرعة
            elevation: 8, // إضافة ظل للشريط العلوي
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                bottom: 16.0,
              ), // مسافة سفلية للعنوان
              title: Center(
                // لف العنوان بـ Center widget لضمان التوسيط
                child: Text(
                  'أذكار المسلم',
                  style: currentTheme.appBarTheme.titleTextStyle?.copyWith(
                    fontSize: 22,
                  ), // استخدام نمط العنوان من الثيم مع تعديل الحجم
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green[900]!, // أخضر أغمق
                      Colors.green[700]!, // أخضر متوسط
                      Colors.green[500]!, // أخضر فاتح
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                // يمكن إضافة صورة خلفية خفيفة هنا إذا لزم الأمر
                // child: Opacity(
                //   opacity: 0.1,
                //   child: Image.asset(
                //     'assets/images/islamic_pattern.png', // مثال لصورة
                //     fit: BoxFit.cover,
                //     color: Colors.black.withOpacity(0.3),
                //     colorBlendMode: BlendMode.dstATop,
                //   ),
                // ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    0.95, // ** تم التعديل هنا: جعل البطاقات أطول قليلاً لمنع التجاوز **
              ),
              delegate: SliverChildListDelegate([
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار المساء",
                  icon: Icons.nightlight_round,
                  color: Colors.deepPurpleAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.almsa);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار الصباح",
                  icon: Icons.wb_sunny,
                  color: Colors.amberAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.alsbah);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار بعد الصلاة",
                  icon: Icons.mosque, // أيقونة مسجد
                  color: Colors.lightGreenAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.afterpray);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار الصلاة",
                  icon: Icons.person_pin_outlined, // أيقونة شخص يصلي
                  color: Colors.blueAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.pray);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار النوم",
                  icon: Icons.bedtime,
                  color: Colors.indigoAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.sleep);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار الآذان",
                  icon: Icons.volume_up, // أيقونة مكبر صوت مناسبة للآذان
                  color: Colors.tealAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.aladan);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار المسجد",
                  icon: Icons.account_balance, // أيقونة مسجد
                  color: Colors.brown.shade300,
                  onTap: () {
                    Get.toNamed(AppRoute.almsjed);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار الإستيقاظ",
                  icon: Icons.alarm,
                  color: Colors.cyanAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.alastygad);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار المنزل",
                  icon: Icons.home,
                  color: Colors.orangeAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.almanzel);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار الوضوء",
                  icon: Icons.water_drop,
                  color: Colors.lightBlueAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.washing);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار الخلاء",
                  icon: Icons.wc, // أيقونة حمام
                  color: Colors.pinkAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.alkhla);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار الطعام",
                  icon: Icons.restaurant,
                  color: Colors.redAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.eat);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أذكار أخرى",
                  icon: Icons.more_horiz,
                  color: Colors.grey.shade400,
                  onTap: () {
                    _showComingSoonDialog(context);
                  },
                ),
                _buildAdkarCard(
                  context, // تمرير السياق
                  title: "أدعية للميّت",
                  icon: Icons.sentiment_dissatisfied_outlined, // أيقونة تعبيرية
                  color: Colors.deepOrangeAccent,
                  onTap: () {
                    Get.toNamed(AppRoute.fordead);
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdkarCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 6, // ظل أفضل
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ), // زوايا أكثر استدارة
      clipBehavior: Clip.antiAlias, // لضمان ظهور التدرج بشكل صحيح داخل الحدود
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // تدرج لوني خفيف للبطاقة
              colors: [
                theme.cardColor, // استخدام لون البطاقة من الثيم
                theme.cardColor.withOpacity(0.9),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;
              final iconBox = (maxHeight * 0.46).clamp(58.0, 84.0);
              final iconPadding = (iconBox * 0.24).clamp(10.0, 18.0);
              final spacing = (maxHeight * 0.06).clamp(6.0, 12.0);
              final showDivider = maxHeight > 145;

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: iconBox,
                      height: iconBox,
                      padding: EdgeInsets.all(iconPadding),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.05),
                          ],
                          radius: 0.8,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: iconBox * 0.5,
                        color: color,
                      ),
                    ),
                    SizedBox(height: spacing),
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showDivider) ...[
                      SizedBox(height: spacing),
                      Container(
                        height: 3,
                        width: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: theme.cardColor, // خلفية متناسقة
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            title: Column(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  color: theme.colorScheme.primary, // لون الأيقونة من الثيم
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  "قريبا",
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Text(
              "سيتم إضافة هذه الأذكار قريباً بإذن الله",
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, // زر بلون مميز
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  "حسناً",
                  style: theme.textTheme.labelLarge!.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ), // نص الزر بلون متناسق
                ),
              ),
            ],
          ),
    );
  }
}
