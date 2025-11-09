import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/services/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  // State for update check
  bool _isCheckingForUpdate = false;
  bool _updateAvailable = false;
  String _latestVersion = '';
  String _updateUrl = '';

  Future<void> _checkForUpdate() async {
    if (!mounted) return;
    setState(() {
      _isCheckingForUpdate = true;
      _updateAvailable = false; // Reset state
    });

    try {
      // الإصدار الحالي للتطبيق (قيمة ثابتة كما طلبت سابقًا)
      const String currentVersion = '1.0.0';
      final String checkUrl =
          'https://tasks.arabwaredos.com/rouknalmuslam//setting/check_update.php';

      final dio = Dio();
      final response = await dio.get('$checkUrl?version=$currentVersion');

      if (response.statusCode == 200) {
        // **الإصلاح**: تحويل الاستجابة النصية إلى خريطة
        final Map<String, dynamic> data;
        if (response.data is String) {
          data = json.decode(response.data);
        } else {
          data = response.data;
        }

        final bool updateAvailable = data['update_available'] ?? false;
        final String? latestVersion = data['latest_version'] as String?;
        final String? updateUrl = data['update_url'] as String?;

        if (updateAvailable && updateUrl != null && latestVersion != null) {
          setState(() {
            _updateAvailable = true;
            _latestVersion = latestVersion;
            _updateUrl = updateUrl;
          });
        } else {
          // لا يوجد تحديث، أغلق القائمة وأظهر رسالة
          Get.back();
          Get.snackbar(
            'التحديثات',
            'أنت تستخدم أحدث إصدار بالفعل.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.teal,
            colorText: Colors.white,
          );
        }
      } else {
        throw Exception('Failed to parse update data');
      }
    } catch (e) {
      Get.back(); // أغلق القائمة عند حدوث خطأ
      Get.snackbar(
        'خطأ',
        'فشل التحقق من التحديثات. يرجى المحاولة مرة أخرى.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingForUpdate = false;
        });
      }
    }
  }

  void _launchUpdateUrl() async {
    if (_updateUrl.isEmpty) return;
    final uri = Uri.parse(_updateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح رابط التحديث.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    MyServices myServices = Get.find();
    bool isLoggedIn = myServices.sharedprf.getString("step") == "2";

    return Drawer(
      child: Container(
        color: const Color(0xFF1A1A1A),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  isLoggedIn
                      ? _buildUserHeader(theme)
                      : _buildGuestHeader(theme),
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
                  const Divider(
                    color: Colors.white24,
                    indent: 16,
                    endIndent: 16,
                  ),
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
                    const Divider(
                      color: Colors.white24,
                      indent: 16,
                      endIndent: 16,
                    ),
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
            // Version and update check at the bottom
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20.0,
                left: 16.0,
                right: 16.0,
              ),
              child: _buildUpdateSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateSection() {
    if (_isCheckingForUpdate) {
      return const Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.teal,
          ),
        ),
      );
    }

    if (_updateAvailable) {
      return _buildUpdateButton();
    }

    return _buildCheckForUpdateButton();
  }

  Widget _buildCheckForUpdateButton() {
    return Material(
      color: Colors.teal.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _checkForUpdate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.teal.withOpacity(0.5)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sync, color: Colors.white70, size: 16),
              SizedBox(width: 8),
              Text(
                'التحقق من وجود تحديث',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Material(
      color: Colors.green.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _launchUpdateUrl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.system_update_alt,
                color: Colors.greenAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'تحديث إلى $_latestVersion',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(ThemeData theme) {
    MyServices myServices2 = Get.find();

    // بيانات المستخدم - في التطبيق الفعلي، يجب أن تأتي هذه من متحكم المستخدم (User Controller)
    String userName = "${myServices2.sharedprf.getString("username")}";
    String userEmail = "${myServices2.sharedprf.getString("email")}";
    String userroul = "${myServices2.sharedprf.getString("role_name")}";

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    const SizedBox(width: 16),
                    Container(
                      height: 20,
                      width: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Center(
                        child: Text(
                          userroul,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ),
                  ],
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
