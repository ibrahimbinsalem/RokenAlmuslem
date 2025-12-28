import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/constant/routes.dart'; // تأكد من أن هذا المسار صحيح
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class AdkarAlmuslam extends StatelessWidget {
  const AdkarAlmuslam({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ModernScaffold(
      title: 'أذكار المسلم',
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اذكار يومية بروح هادئة',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اختر القسم المناسب وابدأ الذكر بسهولة',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
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
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildListDelegate([
                _buildAdkarCard(
                  context,
                  title: "أذكار المساء",
                  icon: Icons.nightlight_round,
                  accent: scheme.primary,
                  onTap: () {
                    Get.toNamed(AppRoute.almsa);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار الصباح",
                  icon: Icons.wb_sunny,
                  accent: scheme.secondary,
                  onTap: () {
                    Get.toNamed(AppRoute.alsbah);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار بعد الصلاة",
                  icon: Icons.mosque,
                  accent: scheme.tertiary,
                  onTap: () {
                    Get.toNamed(AppRoute.afterpray);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار الصلاة",
                  icon: Icons.person_pin_outlined,
                  accent: scheme.primary.withOpacity(0.8),
                  onTap: () {
                    Get.toNamed(AppRoute.pray);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار النوم",
                  icon: Icons.bedtime,
                  accent: scheme.secondary.withOpacity(0.8),
                  onTap: () {
                    Get.toNamed(AppRoute.sleep);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار الآذان",
                  icon: Icons.volume_up,
                  accent: scheme.tertiary.withOpacity(0.8),
                  onTap: () {
                    Get.toNamed(AppRoute.aladan);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار المسجد",
                  icon: Icons.account_balance,
                  accent: scheme.primary.withOpacity(0.65),
                  onTap: () {
                    Get.toNamed(AppRoute.almsjed);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار الإستيقاظ",
                  icon: Icons.alarm,
                  accent: scheme.secondary.withOpacity(0.65),
                  onTap: () {
                    Get.toNamed(AppRoute.alastygad);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار المنزل",
                  icon: Icons.home,
                  accent: scheme.tertiary.withOpacity(0.65),
                  onTap: () {
                    Get.toNamed(AppRoute.almanzel);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار الوضوء",
                  icon: Icons.water_drop,
                  accent: scheme.primary.withOpacity(0.55),
                  onTap: () {
                    Get.toNamed(AppRoute.washing);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار الخلاء",
                  icon: Icons.wc,
                  accent: scheme.secondary.withOpacity(0.55),
                  onTap: () {
                    Get.toNamed(AppRoute.alkhla);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار الطعام",
                  icon: Icons.restaurant,
                  accent: scheme.tertiary.withOpacity(0.55),
                  onTap: () {
                    Get.toNamed(AppRoute.eat);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أذكار أخرى",
                  icon: Icons.more_horiz,
                  accent: scheme.onSurface.withOpacity(0.5),
                  onTap: () {
                    _showComingSoonDialog(context);
                  },
                ),
                _buildAdkarCard(
                  context,
                  title: "أدعية للميّت",
                  icon: Icons.sentiment_dissatisfied_outlined,
                  accent: scheme.primary.withOpacity(0.7),
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
    required Color accent,
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
              color: accent.withOpacity(0.4),
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
                            accent.withOpacity(0.2),
                            accent.withOpacity(0.05),
                          ],
                          radius: 0.8,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: iconBox * 0.5,
                        color: accent,
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
                              accent.withOpacity(0.1),
                              accent,
                              accent.withOpacity(0.1),
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
