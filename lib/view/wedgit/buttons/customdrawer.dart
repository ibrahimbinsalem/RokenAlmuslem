import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/services/services.dart';
import 'package:share_plus/share_plus.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    MyServices myServices = Get.find();
    bool isLoggedIn = myServices.sharedprf.getString("step") == "2";

    return Drawer(
      child: Container(
        color: const Color(0xFF1A1A1A), // لون خلفية أغمق قليلاً
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            isLoggedIn ? _buildUserHeader(theme) : _buildGuestHeader(theme),
            _buildDrawerItem(
              icon: Icons.home_outlined,
              text: 'الرئيسية',
              onTap: () {
                // يفترض أن لديك صفحة رئيسية معرفة في MainScreen
                // إذا كانت الصفحة الرئيسية هي أول صفحة في المكدس، يمكنك استخدام Get.offAllNamed
                Get.offAllNamed(AppRoute.homePage);
              },
            ),
            if (isLoggedIn)
              _buildDrawerItem(
                icon: Icons.settings_outlined,
                text: 'الإعدادات',
                onTap: () {
                  Get.back(); // إغلاق القائمة أولاً
                  Get.toNamed(AppRoute.setting);
                },
              ),
            const Divider(color: Colors.white24, indent: 16, endIndent: 16),
            _buildDrawerItem(
              icon: Icons.info_outline,
              text: 'حول التطبيق',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoute.about);
              },
            ),
            _buildDrawerItem(
              icon: Icons.share_outlined,
              text: 'مشاركة التطبيق',
              onTap: () {
                Get.back();
                Share.share(
                  'تحقق من تطبيق ركن المسلم، رفيقك اليومي للعبادة والذكر. \n\n [رابط التطبيق على المتجر]',
                  subject: 'تطبيق ركن المسلم',
                );
              },
            ),
            if (isLoggedIn) ...[
              const Divider(color: Colors.white24, indent: 16, endIndent: 16),
              _buildDrawerItem(
                icon: Icons.logout,
                text: 'تسجيل الخروج',
                onTap: () {
                  // هنا يمكنك إضافة منطق تسجيل الخروج
                  myServices.sharedprf.setString("step", "1");
                  Get.offAllNamed(AppRoute.homePage);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(ThemeData theme) {
    // بيانات المستخدم - في التطبيق الفعلي، يجب أن تأتي هذه من متحكم المستخدم (User Controller)
    const String userName = "اسم المستخدم";
    const String userEmail = "user.email@example.com";

    return Container(
      // استخدام `EdgeInsets.only` و `SafeArea` لتجنب التداخل مع شريط الحالة
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        bottom: 16,
        right: 16,
        left: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[900]!, Colors.teal[700]!, Colors.teal[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.teal),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(Get.context!).padding.top + 16,
        bottom: 16,
        right: 16,
        left: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal[900]!, Colors.teal[700]!, Colors.teal[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.mosque_rounded, color: Colors.white, size: 50),
          const SizedBox(height: 12),
          Text(
            'أهلاً بك في ركن المسلم',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل دخولك للاستفادة من كامل الميزات',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Get.toNamed(AppRoute.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal.shade800,
                ),
                child: const Text('تسجيل الدخول'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Get.toNamed(AppRoute.signUp),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                ),
                child: const Text('إنشاء حساب'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.teal.withOpacity(0.3),
        highlightColor: Colors.teal.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: <Widget>[
              Icon(icon, color: Colors.white70, size: 24),
              const SizedBox(width: 20),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
