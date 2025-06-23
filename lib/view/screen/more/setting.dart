import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppSettingsController appSettings = Get.put(AppSettingsController());
    final NotificationService notificationService = Get.put(NotificationService());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, 'الإعدادات العامة'),
            _buildToggleSetting(
              context,
              title: 'الوضع الليلي',
              value: appSettings.darkModeEnabled.value,
              onChanged: (newValue) async {
                await appSettings.setDarkModeEnabled(newValue);
                Get.changeThemeMode(
                  newValue ? ThemeMode.dark : ThemeMode.light,
                );
              },
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
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(context, 'إعدادات التنبيهات'),
            _buildToggleSetting(
              context,
              title: 'تفعيل التنبيهات',
              value: appSettings.notificationsEnabled.value,
              onChanged: (newValue) async {
                await appSettings.setNotificationsEnabled(newValue);
                if (newValue) {
                  notificationService.scheduleDailyReminder(
                    id: AppSettingsController.generalDailyAzkarId,
                    title: 'تذكير أذكار',
                    body: 'حان وقت أذكارك اليومية!',
                    time: TimeOfDay(hour: 8, minute: 0),
                  );
                  notificationService.scheduleDailyReminder(
                    id: AppSettingsController.morningAzkarId,
                    title: 'أذكار الصباح',
                    body: 'ابدأ يومك بذكر الله',
                    time: TimeOfDay(hour: 6, minute: 0),
                  );
                  notificationService.scheduleDailyReminder(
                    id: AppSettingsController.eveningAzkarId,
                    title: 'أذكار المساء',
                    body: 'حصّن نفسك بذكر الله',
                    time: TimeOfDay(hour: 18, minute: 0),
                  );
                  notificationService.scheduleWeeklyReminder(
                    id: AppSettingsController.weeklyFridayReminderId,
                    title: 'تذكير الجمعة',
                    body: 'لا تنسَ قراءة سورة الكهف والصلاة على النبي ﷺ',
                    time: TimeOfDay(hour: 10, minute: 0),
                    day: WeekDay.friday,
                  );
                  _showSnackBar(context, 'تم تفعيل التنبيهات وجدولتها');
                } else {
                  await notificationService.cancelAllNotifications();
                  _showSnackBar(context, 'تم تعطيل جميع التنبيهات');
                }
              },
            ),
            _buildSliderSetting(
              context,
              title: 'تكرار التنبيه (بالدقائق)',
              value: appSettings.notificationIntervalMinutes.value.toDouble(),
              min: 15,
              max: 120,
              divisions: (120 - 15) ~/ 15,
              label: '${appSettings.notificationIntervalMinutes.value} دقيقة',
              onChanged: (newValue) async {
                await appSettings.setNotificationIntervalMinutes(
                  newValue.round(),
                );
              },
            ),
            _buildToggleSetting(
              context,
              title: 'اهتزاز عند التنبيه',
              value: appSettings.vibrateOnNotification.value,
              onChanged: (newValue) async {
                await appSettings.setVibrateOnNotification(newValue);
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(context, 'محتوى الأذكار'),
            _buildToggleSetting(
              context,
              title: 'ترتيب عشوائي للأذكار',
              value: appSettings.randomAzkarOrder.value,
              onChanged: (newValue) async {
                await appSettings.setRandomAzkarOrder(newValue);
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(context, 'إضافي'),
            _buildListTile(
              context,
              title: 'إدارة التنبيهات المجدولة',
              icon: Icons.notifications_none_outlined,
              onTap: () => _showScheduledNotificationsDialog(context),
            ),
            _buildListTile(
              context,
              title: 'مشاركة التطبيق',
              icon: Icons.share_outlined,
              onTap: () {
                _showSnackBar(context, 'مشاركة التطبيق');
              },
            ),
            _buildListTile(
              context,
              title: 'تقييم التطبيق',
              icon: Icons.star_rate_outlined,
              onTap: () {
                _showSnackBar(context, 'تقييم التطبيق');
              },
            ),
            _buildListTile(
              context,
              title: 'عن التطبيق',
              icon: Icons.info_outline,
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: Text(
                      'عن تطبيق الأذكار',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                    content: const Text(
                      'تطبيق يساعدك على ذكر الله في كل وقت.\n\nالإصدار: 1.0.0\n© 2023 كل الحقوق محفوظة.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('إغلاق'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildListTile(
              context,
              title: 'إعادة تعيين الإعدادات',
              icon: Icons.refresh_outlined,
              onTap: () {
                _showConfirmResetDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildToggleSetting(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final appSettings = Get.find<AppSettingsController>();
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: appSettings.fontSizeMultiplier.value * 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Switch.adaptive(
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
  }) {
    final appSettings = Get.find<AppSettingsController>();
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: appSettings.fontSizeMultiplier.value * 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
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
              alignment: Alignment.centerRight,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: appSettings.fontSizeMultiplier.value * 14,
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
  }) {
    final appSettings = Get.find<AppSettingsController>();
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: appSettings.fontSizeMultiplier.value * 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: appSettings.fontSizeMultiplier.value * 16,
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
  }) {
    final appSettings = Get.find<AppSettingsController>();
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(
            fontSize: appSettings.fontSizeMultiplier.value * 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      colorText: Theme.of(context).colorScheme.onPrimary,
      borderRadius: 10,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      messageText: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
      titleText: const SizedBox.shrink(),
    );
  }

  void _showConfirmResetDialog(BuildContext context) {
    final AppSettingsController appSettings = Get.find<AppSettingsController>();
    final theme = Theme.of(context);

    Get.dialog(
      AlertDialog(
        title: Text(
          'إعادة تعيين الإعدادات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        content: Text(
          'هل أنت متأكد أنك تريد إعادة تعيين جميع الإعدادات إلى القيم الافتراضية؟',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await appSettings.resetSettings();
              Get.back();
              _showSnackBar(context, 'تم إعادة تعيين الإعدادات بنجاح!');
              Get.changeThemeMode(
                appSettings.darkModeEnabled.value
                    ? ThemeMode.dark
                    : ThemeMode.light,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  Future<void> _showScheduledNotificationsDialog(BuildContext context) async {
    final NotificationService notificationService = Get.find<NotificationService>();
    final theme = Theme.of(context);

    void refreshDialog(Function setState) async {
      final List<PendingNotificationRequest> pendingNotifications =
          await notificationService.getPendingNotifications();
      setState(() {});
    }

    Get.dialog(
      AlertDialog(
        title: Text(
          'التنبيهات المجدولة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FutureBuilder<List<PendingNotificationRequest>>(
              future: notificationService.getPendingNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('لا توجد تنبيهات مجدولة حالياً.'),
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
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            title: Text(
                              notification.title ?? 'بدون عنوان',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            subtitle: Text(
                              notification.body ?? 'بدون محتوى',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: theme.colorScheme.error,
                              ),
                              onPressed: () async {
                                await notificationService.cancelNotification(notification.id);
                                _showSnackBar(context, 'تم حذف التنبيه: ${notification.title}');
                                refreshDialog(setState);
                              },
                              tooltip: 'حذف التنبيه',
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
            child: Text(
              'إغلاق',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}