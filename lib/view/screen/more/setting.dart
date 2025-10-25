import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/view/screen/more/aboutbage.dart';
import 'package:url_launcher/url_launcher.dart'; // تأكد من المسار الصحيح

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppSettingsController appSettings = Get.put(AppSettingsController());
    final NotificationService notificationService = Get.put(
      NotificationService(),
    );

    final ThemeData currentTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: currentTheme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: currentTheme.appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
        elevation: currentTheme.appBarTheme.elevation,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[900]!, Colors.teal[700]!, Colors.teal[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: currentTheme.appBarTheme.foregroundColor,
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, 'الإعدادات العامة', currentTheme),
            _buildToggleSetting(
              context,
              title: 'الوضع الليلي',
              value: appSettings.darkModeEnabled.value,
              onChanged: (newValue) async {
                await appSettings.setDarkModeEnabled(newValue);
              },
              theme: currentTheme,
            ),
            _buildSliderSetting(
              context,
              title: 'حجم الخط',
              value: appSettings.fontSizeMultiplier.value,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: '${(appSettings.fontSizeMultiplier.value * 100).round()}%',
              onChanged: (newValue) async {
                await appSettings.setFontSizeMultiplier(newValue);
              },
              theme: currentTheme,
            ),
            _buildDropdownSetting(
              context,
              title: 'اللغة',
              value: appSettings.selectedLanguage.value,
              items: const ['العربية', 'English'],
              onChanged: (newValue) async {
                if (newValue != null) {
                  await appSettings.setSelectedLanguage(newValue);
                }
              },
              theme: currentTheme,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(context, 'إعدادات التنبيهات', currentTheme),
            _buildToggleSetting(
              context,
              title: 'تفعيل كل التنبيهات', // مفتاح رئيسي لجميع التنبيهات
              value: appSettings.notificationsEnabled.value,
              onChanged: (newValue) async {
                await appSettings.setNotificationsEnabled(newValue);
              },
              theme: currentTheme,
            ),
            // مفاتيح التفعيل الفردية للتنبيهات (تظهر فقط إذا كان المفتاح الرئيسي مفعل)
            if (appSettings.notificationsEnabled.value) ...[
              // **جديد: مفتاح التحكم بإشعارات أوقات الصلاة**
              _buildToggleSetting(
                context,
                title: 'تنبيهات أوقات الصلاة',
                value: appSettings.prayerTimesNotificationsEnabled.value,
                onChanged: (newValue) async {
                  await appSettings.setPrayerTimesNotificationsEnabled(
                    newValue,
                  );
                },
                theme: currentTheme,
              ),
              _buildToggleSetting(
                context,
                title: 'تذكير أذكار عامة (8:00 صباحًا)',
                value: appSettings.generalDailyAzkarEnabled.value,
                onChanged: (newValue) async {
                  await appSettings.setGeneralDailyAzkarEnabled(newValue);
                },
                theme: currentTheme,
              ),
              _buildToggleSetting(
                context,
                title: 'تذكير أذكار الصباح (6:00 صباحًا)',
                value: appSettings.morningAzkarReminderEnabled.value,
                onChanged: (newValue) async {
                  await appSettings.setMorningAzkarReminderEnabled(newValue);
                },
                theme: currentTheme,
              ),
              _buildToggleSetting(
                context,
                title: 'تذكير أذكار المساء (6:00 مساءً)',
                value: appSettings.eveningAzkarReminderEnabled.value,
                onChanged: (newValue) async {
                  await appSettings.setEveningAzkarReminderEnabled(newValue);
                },
                theme: currentTheme,
              ),
              _buildToggleSetting(
                context,
                title: 'تذكير أذكار النوم (10:00 مساءً)',
                value: appSettings.sleepAzkarReminderEnabled.value,
                onChanged: (newValue) async {
                  await appSettings.setSleepAzkarReminderEnabled(newValue);
                },
                theme: currentTheme,
              ),
              _buildToggleSetting(
                context,
                title: 'تذكير التسبيح (12:00 ظهرًا)',
                value: appSettings.tasbeehReminderEnabled.value,
                onChanged: (newValue) async {
                  await appSettings.setTasbeehReminderEnabled(newValue);
                },
                theme: currentTheme,
              ),
              _buildToggleSetting(
                context,
                title: 'تذكير الجمعة (10:00 صباحًا)',
                value: appSettings.weeklyFridayReminderEnabled.value,
                onChanged: (newValue) async {
                  await appSettings.setWeeklyFridayReminderEnabled(newValue);
                },
                theme: currentTheme,
              ),
            ],
            const SizedBox(height: 24),

            _buildSectionTitle(context, 'محتوى الأذكار', currentTheme),
            _buildToggleSetting(
              context,
              title: 'ترتيب عشوائي للأذكار',
              value: appSettings.randomAzkarOrder.value,
              onChanged: (newValue) async {
                await appSettings.setRandomAzkarOrder(newValue);
              },
              theme: currentTheme,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(context, 'إضافي', currentTheme),
            _buildListTile(
              context,
              title: 'إدارة التنبيهات المجدولة',
              icon: Icons.notifications_none_outlined,
              onTap:
                  () =>
                      _showScheduledNotificationsDialog(context, currentTheme),
              theme: currentTheme,
            ),
            _buildListTile(
              context,
              title: 'مشاركة التطبيق',
              icon: Icons.share_outlined,
              onTap: () {
                _showSnackBar(
                  context,
                  'ميزة المشاركة قيد التطوير!',
                  currentTheme,
                );
              },
              theme: currentTheme,
            ),
            _buildListTile(
              context,
              title: 'تقييم التطبيق',
              icon: Icons.star_rate_outlined,
              onTap: () {
                _showSnackBar(
                  context,
                  'ميزة التقييم قيد التطوير!',
                  currentTheme,
                );
              },
              theme: currentTheme,
            ),
            _buildListTile(
              context,
              title: 'سياسة الخصوصية',
              icon: Icons.policy_outlined,
              onTap: () {
                launchUrl(
                  Uri.parse(
                    "https://newbalignearab.arabwaredos.com/baligneback/rokenalmuslam.html",
                  ),
                );
              },
              theme: currentTheme,
            ),
            _buildListTile(
              context,
              title: 'حول التطبيق والمطورين',
              icon: Icons.info_outline,
              onTap: () {
                Get.to(() => const AboutUsPage());
              },
              theme: currentTheme,
            ),
            _buildListTile(
              context,
              title: 'إعادة تعيين الإعدادات',
              icon: Icons.refresh_outlined,
              onTap: () {
                _showConfirmResetDialog(context, currentTheme);
              },
              theme: currentTheme,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineLarge!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 2,
            width: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
  }) {
    return Card(
      color: theme.cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting(
    BuildContext context, {
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
    required ThemeData theme,
  }) {
    return Card(
      color: theme.cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Slider.adaptive(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
              thumbColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSetting(
    BuildContext context, {
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required ThemeData theme,
  }) {
    return Card(
      color: theme.cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              dropdownColor: theme.cardColor,
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              items:
                  items.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
              underline: const SizedBox.shrink(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Card(
      color: theme.cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.titleMedium!.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, ThemeData theme) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: theme.colorScheme.primary,
      colorText: theme.colorScheme.onPrimary,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      messageText: Text(
        message,
        style: theme.textTheme.bodyMedium!.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
        textAlign: TextAlign.center,
      ),
      titleText: const SizedBox.shrink(),
      icon: Icon(
        Icons.check_circle_outline,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }

  void _showConfirmResetDialog(BuildContext context, ThemeData theme) {
    final AppSettingsController appSettings = Get.find<AppSettingsController>();
    Get.dialog(
      AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'إعادة تعيين الإعدادات',
          style: theme.textTheme.headlineSmall!.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        content: Text(
          'هل أنت متأكد أنك تريد إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟',
          style: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            child: Text('إلغاء', style: theme.textTheme.labelLarge),
          ),
          ElevatedButton(
            onPressed: () async {
              await appSettings.resetSettings();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'تأكيد',
              style: theme.textTheme.labelLarge!.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showScheduledNotificationsDialog(
    BuildContext context,
    ThemeData theme,
  ) async {
    final NotificationService notificationService =
        Get.find<NotificationService>();

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'التنبيهات المجدولة',
          style: theme.textTheme.headlineSmall!.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FutureBuilder<List<PendingNotificationRequest>>(
              future: notificationService.getPendingNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'حدث خطأ: ${snapshot.error}',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد تنبيهات مجدولة حالياً.',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  );
                } else {
                  final notifications = snapshot.data!;
                  return Container(
                    width: double.maxFinite,
                    height: Get.height * 0.5,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Card(
                          color: theme.colorScheme.surface,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 2.0,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              notification.title ?? 'بدون عنوان',
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            subtitle: Text(
                              notification.body ?? 'بدون محتوى',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.error,
                              ),
                              onPressed: () async {
                                await notificationService.cancelNotification(
                                  notification.id,
                                );
                                _showSnackBar(
                                  context,
                                  'تم حذف التنبيه: ${notification.title}',
                                  theme,
                                );
                                setState(() {});
                              },
                              tooltip: 'حذف التنبيه',
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            child: Text('إغلاق', style: theme.textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}
