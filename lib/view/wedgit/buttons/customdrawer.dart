import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/services/api_service.dart';
import 'package:rokenalmuslem/core/services/services.dart';
import 'package:rokenalmuslem/linkapi.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _CustomDrawerState extends State<CustomDrawer> {
  // State for update check
  bool _isCheckingForUpdate = false;
  bool _updateAvailable = false;
  String _latestVersion = '';
  String _updateUrl = '';
  String _currentVersion = '';
  bool _supportHasNewReply = false;
  String _supportStatus = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadSupportStatus();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _currentVersion = info.version);
    } catch (_) {
      if (!mounted) return;
      setState(() => _currentVersion = '');
    }
  }

  Future<void> _loadSupportStatus() async {
    final services = Get.find<MyServices>();
    final token = services.sharedprf.getString('token');
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _supportHasNewReply = false;
        _supportStatus = '';
      });
      return;
    }

    try {
      final data = await ApiService().fetchSupportThread(authToken: token);
      if (data == null) {
        if (!mounted) return;
        setState(() {
          _supportHasNewReply = false;
          _supportStatus = '';
        });
        return;
      }

      final status = data['status']?.toString() ?? '';
      final lastSender = data['last_sender_type']?.toString() ?? '';
      final lastMessageAtRaw = data['last_message_at']?.toString();
      DateTime? lastMessageAt;
      if (lastMessageAtRaw != null && lastMessageAtRaw.isNotEmpty) {
        lastMessageAt = DateTime.tryParse(lastMessageAtRaw);
      }

      final lastSeenRaw = services.sharedprf.getString('support_last_seen_at');
      final lastSeen = lastSeenRaw != null ? DateTime.tryParse(lastSeenRaw) : null;
      final hasNewReply = lastSender == 'admin' &&
          lastMessageAt != null &&
          (lastSeen == null || lastMessageAt.isAfter(lastSeen));

      if (!mounted) return;
      setState(() {
        _supportStatus = status;
        _supportHasNewReply = hasNewReply;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _supportHasNewReply = false;
        _supportStatus = '';
      });
    }
  }

  Future<void> _checkForUpdate() async {
    if (!mounted) return;
    setState(() {
      _isCheckingForUpdate = true;
      _updateAvailable = false; // Reset state
    });

    try {
      final info = await PackageInfo.fromPlatform();
      final String currentVersion = info.version;
      final String checkUrl = AppLink.appVersionCheck;

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
            backgroundColor: Get.theme.colorScheme.primary,
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
        backgroundColor: Get.theme.colorScheme.error,
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
    final scheme = theme.colorScheme;
    MyServices myServices = Get.find();
    bool isLoggedIn = myServices.sharedprf.getString("step") == "2";
    final supportSubtitle = _supportStatus.isEmpty
        ? 'أسئلة شائعة وحالة الدعم'
        : _supportStatus == 'closed'
            ? 'حالة الدعم: مغلقة'
            : 'حالة الدعم: مفتوحة';

    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width < 360 ? 12.0 : 16.0;
          final cardSpacing = width < 360 ? 12.0 : 16.0;

          return Container(
            color: scheme.background,
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  horizontalPadding,
                ),
                children: [
                  isLoggedIn
                      ? _buildUserHeader(context, theme, width)
                      : _buildGuestHeader(context, theme, width),
                  SizedBox(height: cardSpacing),
                  _buildQuickActions(context, theme, isLoggedIn),
                  SizedBox(height: cardSpacing),
                  _buildSectionTitle(context, 'التنقل'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.home_outlined,
                    text: 'الرئيسية',
                    subtitle: 'العودة للشاشة الرئيسية',
                    onTap: () => Get.offAllNamed(AppRoute.homePage),
                  ),
                  if (isLoggedIn)
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings_outlined,
                      text: 'الإعدادات',
                      subtitle: 'تخصيص التنبيهات والمظهر',
                      onTap: () => Get.toNamed(AppRoute.setting),
                    ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    text: 'مركز المساعدة',
                    subtitle: supportSubtitle,
                    trailing: _supportHasNewReply
                        ? _buildNotificationDot(scheme)
                        : null,
                    onTap: () => Get.toNamed(AppRoute.helpCenter),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.info_outline,
                    text: 'حول التطبيق',
                    subtitle: 'تعرف على فريق العمل',
                    onTap: () => Get.toNamed(AppRoute.about),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.share_outlined,
                    text: 'مشاركة التطبيق',
                    subtitle: 'شارك التطبيق مع من تحب',
                    onTap: () {
                      Share.share(
                        'تحقق من تطبيق ركن المسلم، رفيقك اليومي للعبادة والذكر. \n\n [رابط التطبيق على المتجر]',
                        subject: 'تطبيق ركن المسلم',
                      );
                    },
                  ),
                  SizedBox(height: cardSpacing),
                  _buildSectionTitle(context, 'الحساب'),
                  if (!isLoggedIn)
                    _buildDrawerItem(
                      context,
                      icon: Icons.login,
                      text: 'تسجيل الدخول',
                      subtitle: 'ادخل إلى حسابك للوصول للمزايا',
                      onTap: () => Get.toNamed(AppRoute.login),
                    ),
                  if (!isLoggedIn)
                    _buildDrawerItem(
                      context,
                      icon: Icons.person_add_alt_1,
                      text: 'إنشاء حساب',
                      subtitle: 'سجل حسابًا جديدًا',
                      onTap: () => Get.toNamed(AppRoute.signUp),
                    ),
                  if (isLoggedIn)
                    _buildDrawerItem(
                      context,
                      icon: Icons.logout,
                      text: 'تسجيل الخروج',
                      subtitle: 'إنهاء الجلسة الحالية',
                      onTap: () {
                        myServices.sharedprf.setString("step", "1");
                        Get.offAllNamed(AppRoute.homePage);
                      },
                    ),
                  SizedBox(height: cardSpacing),
                  _buildSectionTitle(context, 'التحديثات'),
                  _buildUpdateSection(theme),
                  if (_currentVersion.isNotEmpty) ...[
                    SizedBox(height: cardSpacing),
                    Center(
                      child: Text(
                        'الإصدار الحالي V$_currentVersion',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpdateSection(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _isCheckingForUpdate
            ? _buildUpdateLoading(theme)
            : _updateAvailable
                ? _buildUpdateButton(theme)
                : _buildCheckForUpdateButton(theme),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ThemeData theme,
    bool isLoggedIn,
  ) {
    final scheme = theme.colorScheme;
    final actions = [
      _QuickAction(
        icon: Icons.home_outlined,
        label: 'الرئيسية',
        onTap: () => Get.offAllNamed(AppRoute.homePage),
      ),
      _QuickAction(
        icon: Icons.help_outline,
        label: 'المساعدة',
        onTap: () => Get.toNamed(AppRoute.helpCenter),
      ),
      if (isLoggedIn)
        _QuickAction(
          icon: Icons.settings_outlined,
          label: 'الإعدادات',
          onTap: () => Get.toNamed(AppRoute.setting),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 12,
        runSpacing: 8,
        children: actions
            .map(
              (action) => InkWell(
                onTap: action.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          action.icon,
                          color: scheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        action.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCheckForUpdateButton(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Column(
      key: const ValueKey('update-check'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تحقق من التحديثات',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'تأكد من الحصول على آخر نسخة من التطبيق.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ElevatedButton.icon(
            onPressed: _checkForUpdate,
            icon: const Icon(Icons.sync, size: 18),
            label: const Text('فحص التحديث'),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Column(
      key: const ValueKey('update-available'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تحديث جديد متوفر',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _latestVersion.isEmpty
              ? 'يتوفر إصدار أحدث للتطبيق.'
              : 'الإصدار $_latestVersion متاح الآن.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ElevatedButton.icon(
            onPressed: _launchUpdateUrl,
            icon: const Icon(Icons.system_update_alt, size: 18),
            label: const Text('تحديث الآن'),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateLoading(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Row(
      key: const ValueKey('update-loading'),
      children: [
        SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'جاري التحقق من التحديثات...',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildUserHeader(
    BuildContext context,
    ThemeData theme,
    double width,
  ) {
    final scheme = theme.colorScheme;
    MyServices myServices2 = Get.find();

    // بيانات المستخدم - في التطبيق الفعلي، يجب أن تأتي هذه من متحكم المستخدم (User Controller)
    final userName = myServices2.sharedprf.getString("username") ?? '';
    final userEmail = myServices2.sharedprf.getString("email") ?? '';
    final rawRole = myServices2.sharedprf.getString("role_name");
    final userroul =
        rawRole == null || rawRole.trim().isEmpty || rawRole == 'null'
            ? ''
            : rawRole;

    final avatarSize = width < 360 ? 54.0 : 64.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withOpacity(0.95),
            scheme.secondary.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: avatarSize,
            width: avatarSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: avatarSize * 0.55,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (userroul.trim().isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Text(
                      userroul,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHeader(
    BuildContext context,
    ThemeData theme,
    double width,
  ) {
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withOpacity(0.95),
            scheme.secondary.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.mosque_rounded,
            color: Colors.white,
            size: width < 360 ? 42 : 52,
          ),
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.toNamed(AppRoute.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: scheme.primary,
                  minimumSize: const Size(0, 44),
                ),
                child: const Text('تسجيل الدخول'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.toNamed(AppRoute.signUp);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                ),
                child: const Text('إنشاء حساب'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: scheme.primary.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    String? subtitle,
    Widget? trailing,
    required GestureTapCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
        splashColor: scheme.primary.withOpacity(0.2),
        highlightColor: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outline.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primary.withOpacity(0.12),
                child: Icon(icon, color: scheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null && subtitle.trim().isNotEmpty)
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    isRtl ? Icons.chevron_left : Icons.chevron_right,
                    color: scheme.onSurface.withOpacity(0.5),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationDot(ColorScheme scheme) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: scheme.error,
        shape: BoxShape.circle,
      ),
    );
  }
}
