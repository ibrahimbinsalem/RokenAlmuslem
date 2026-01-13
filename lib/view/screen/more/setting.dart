import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/view/screen/more/aboutbage.dart';
import 'package:url_launcher/url_launcher.dart'; // تأكد من المسار الصحيح
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppSettingsController appSettings = Get.find<AppSettingsController>();
    final NotificationService notificationService =
        Get.find<NotificationService>();
    final quranSettingsBox = Hive.box('quranSettings');

    final ThemeData currentTheme = Theme.of(context);
    final scheme = currentTheme.colorScheme;

    Future<File> _getBackupFile() async {
      final dir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${dir.path}/backup');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      return File('${backupDir.path}/rokn_backup.json');
    }

    Future<void> _createBackup() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final data = {
          'version': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'preferences': {
            'enabledShortcuts': prefs.getStringList('enabledShortcuts') ?? [],
            'selectedLanguage': prefs.getString('selectedLanguage'),
            'darkModeEnabled': prefs.getBool('darkModeEnabled'),
            'fontSizeMultiplier': prefs.getDouble('fontSizeMultiplier'),
            'lineHeightMultiplier': prefs.getDouble('lineHeightMultiplier'),
            'daily_plan_history': prefs.getString('daily_plan_history'),
            'hideNotificationContent':
                prefs.getBool('hideNotificationContent'),
            'smartMorningAzkarReminderEnabled':
                prefs.getBool('smartMorningAzkarReminderEnabled'),
            'generalDailyAzkarEnabled':
                prefs.getBool('generalDailyAzkarEnabled'),
            'morningAzkarReminderEnabled':
                prefs.getBool('morningAzkarReminderEnabled'),
            'eveningAzkarReminderEnabled':
                prefs.getBool('eveningAzkarReminderEnabled'),
            'sleepAzkarReminderEnabled':
                prefs.getBool('sleepAzkarReminderEnabled'),
            'tasbeehReminderEnabled':
                prefs.getBool('tasbeehReminderEnabled'),
            'weeklyFridayReminderEnabled':
                prefs.getBool('weeklyFridayReminderEnabled'),
            'prayerTimesNotificationsEnabled':
                prefs.getBool('prayerTimesNotificationsEnabled'),
          },
          'quranSettings': {
            'favorite_audio_surahs':
                quranSettingsBox.get('favorite_audio_surahs'),
            'favorite_audio_reciters':
                quranSettingsBox.get('favorite_audio_reciters'),
            'last_audio_surah': quranSettingsBox.get('last_audio_surah'),
            'last_audio_reciter': quranSettingsBox.get('last_audio_reciter'),
            'lastReadSurahNumber': quranSettingsBox.get('lastReadSurahNumber'),
            'lastReadPosition': quranSettingsBox.get('lastReadPosition'),
          },
        };

        final file = await _getBackupFile();
        await file.writeAsString(jsonEncode(data));
        Get.snackbar('نسخ احتياطي', 'تم إنشاء النسخة الاحتياطية بنجاح');
      } catch (e) {
        Get.snackbar('خطأ', 'تعذر إنشاء النسخة الاحتياطية');
      }
    }

    Future<void> _restoreBackup() async {
      try {
        final file = await _getBackupFile();
        if (!await file.exists()) {
          Get.snackbar('تنبيه', 'لا توجد نسخة احتياطية للمعالجة');
          return;
        }
        final raw = await file.readAsString();
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        final prefsData = Map<String, dynamic>.from(
          data['preferences'] as Map? ?? {},
        );
        final quranData = Map<String, dynamic>.from(
          data['quranSettings'] as Map? ?? {},
        );

        final enabledShortcuts =
            (prefsData['enabledShortcuts'] as List?)?.cast<String>();
        if (enabledShortcuts != null) {
          await prefs.setStringList('enabledShortcuts', enabledShortcuts);
        }

        Future<void> _setBool(String key) async {
          final value = prefsData[key];
          if (value is bool) {
            await prefs.setBool(key, value);
          }
        }

        Future<void> _setDouble(String key) async {
          final value = prefsData[key];
          if (value is num) {
            await prefs.setDouble(key, value.toDouble());
          }
        }

        Future<void> _setString(String key) async {
          final value = prefsData[key];
          if (value is String) {
            await prefs.setString(key, value);
          }
        }

        await _setString('selectedLanguage');
        await _setBool('darkModeEnabled');
        await _setDouble('fontSizeMultiplier');
        await _setDouble('lineHeightMultiplier');
        await _setString('daily_plan_history');
        await _setBool('hideNotificationContent');
        await _setBool('smartMorningAzkarReminderEnabled');
        await _setBool('generalDailyAzkarEnabled');
        await _setBool('morningAzkarReminderEnabled');
        await _setBool('eveningAzkarReminderEnabled');
        await _setBool('sleepAzkarReminderEnabled');
        await _setBool('tasbeehReminderEnabled');
        await _setBool('weeklyFridayReminderEnabled');
        await _setBool('prayerTimesNotificationsEnabled');

        for (final entry in quranData.entries) {
          if (entry.value != null) {
            quranSettingsBox.put(entry.key, entry.value);
          }
        }

        await appSettings.loadSettings();
        Get.snackbar('تم الاسترجاع', 'تم استعادة النسخة الاحتياطية');
      } catch (e) {
        Get.snackbar('خطأ', 'تعذر استعادة النسخة الاحتياطية');
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: GetX<AppSettingsController>(
          builder: (appSettings) {
            return CustomScrollView(
              slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  centerTitle: true,
                  title: Text(
                    'الإعدادات',
                    style: currentTheme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary.withOpacity(0.95),
                          scheme.secondary.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          'تخصيص تجربة ركن المسلم حسب تفضيلاتك',
                          style: currentTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionCard(
                      context,
                      title: 'الإعدادات العامة',
                      children: [
                        _buildSwitchRow(
                          context,
                          icon: Icons.dark_mode_outlined,
                          title: 'الوضع الداكن',
                          subtitle: 'تفعيل المظهر الليلي العصري',
                          value: appSettings.darkModeEnabled.value,
                          onChanged: (newValue) async {
                            await appSettings.setDarkModeEnabled(newValue);
                          },
                        ),
                        _buildSliderRow(
                          context,
                          icon: Icons.text_fields,
                          title: 'حجم الخط',
                          value: appSettings.fontSizeMultiplier.value,
                          min: 0.8,
                          max: 1.5,
                          divisions: 7,
                          label:
                              '${(appSettings.fontSizeMultiplier.value * 100).round()}%',
                          onChanged: (newValue) async {
                            await appSettings.setFontSizeMultiplier(newValue);
                          },
                        ),
                        _buildSliderRow(
                          context,
                          icon: Icons.format_line_spacing,
                          title: 'تباعد الأسطر',
                          value: appSettings.lineHeightMultiplier.value,
                          min: 1.2,
                          max: 2.4,
                          divisions: 6,
                          label:
                              '${appSettings.lineHeightMultiplier.value.toStringAsFixed(1)}x',
                          onChanged: (newValue) async {
                            await appSettings.setLineHeightMultiplier(newValue);
                          },
                        ),
                        _buildDropdownRow(
                          context,
                          icon: Icons.language,
                          title: 'اللغة',
                          value: appSettings.selectedLanguage.value,
                          items: const ['العربية', 'English'],
                          onChanged: (newValue) async {
                            if (newValue != null) {
                              await appSettings.setSelectedLanguage(newValue);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      context,
                      title: 'إعدادات التنبيهات',
                      children: [
                        _buildSwitchRow(
                          context,
                          icon: Icons.notifications_active_outlined,
                          title: 'تفعيل كل التنبيهات',
                          subtitle: 'تشغيل أو إيقاف جميع التنبيهات',
                          value: appSettings.notificationsEnabled.value,
                          onChanged: (newValue) async {
                            await appSettings.setNotificationsEnabled(newValue);
                          },
                        ),
                        if (appSettings.notificationsEnabled.value) ...[
                          _buildSwitchRow(
                            context,
                            icon: Icons.lock_outline,
                            title: 'إخفاء محتوى الإشعارات',
                            subtitle: 'إخفاء تفاصيل التنبيهات على شاشة القفل',
                            value: appSettings.hideNotificationContent.value,
                            onChanged: (newValue) async {
                              await appSettings
                                  .setHideNotificationContent(newValue);
                            },
                          ),
                          _buildSwitchRow(
                            context,
                            icon: Icons.access_time,
                            title: 'تنبيهات أوقات الصلاة',
                            subtitle: 'إشعار تلقائي لكل صلاة',
                            value: appSettings
                                .prayerTimesNotificationsEnabled
                                .value,
                            onChanged: (newValue) async {
                              await appSettings
                                  .setPrayerTimesNotificationsEnabled(newValue);
                            },
                          ),
                          _buildSwitchRow(
                            context,
                            icon: Icons.auto_awesome_motion,
                            title: 'تحديث ذكي لمواقيت الصلاة',
                            subtitle: 'تحديث تلقائي عند تغيّر الموقع',
                            value: appSettings.smartPrayerUpdatesEnabled.value,
                            onChanged: (newValue) async {
                              await appSettings
                                  .setSmartPrayerUpdatesEnabled(newValue);
                            },
                          ),
                          _buildSwitchRow(
                            context,
                            icon: Icons.travel_explore_outlined,
                            title: 'وضع السفر لمواقيت الصلاة',
                            subtitle: 'تحديث أدق وأسرع أثناء التنقل',
                            value: appSettings.travelModeEnabled.value,
                            onChanged: (newValue) async {
                              await appSettings.setTravelModeEnabled(newValue);
                            },
                          ),
                          _buildSwitchRow(
                            context,
                            icon: Icons.auto_awesome,
                            title: 'تذكير أذكار عامة',
                            subtitle: 'بعد الظهر',
                            value: appSettings.generalDailyAzkarEnabled.value,
                            onChanged: (newValue) async {
                              await appSettings
                                  .setGeneralDailyAzkarEnabled(newValue);
                            },
                          ),
                          _buildSwitchRow(
                            context,
                            icon: Icons.wb_sunny_outlined,
                            title: 'تذكير أذكار الصباح',
                            subtitle: 'بعد الفجر',
                            value: appSettings.morningAzkarReminderEnabled.value,
                            onChanged: (newValue) async {
                              await appSettings
                                  .setMorningAzkarReminderEnabled(newValue);
                            },
                          ),
                          if (appSettings.morningAzkarReminderEnabled.value)
                            _buildSwitchRow(
                              context,
                              icon: Icons.light_mode_outlined,
                              title: 'تنبيه ذكي لأذكار الصباح',
                              subtitle:
                                  'تنبيه لطيف بعد الظهر إذا لم تقرأ أذكار الصباح',
                              value: appSettings
                                  .smartMorningAzkarReminderEnabled
                                  .value,
                              onChanged: (newValue) async {
                                await appSettings
                                    .setSmartMorningAzkarReminderEnabled(
                                  newValue,
                                );
                              },
                            ),
                          _buildSwitchRow(
                            context,
                            icon: Icons.nights_stay_outlined,
                            title: 'تذكير أذكار المساء',
                            subtitle: 'بعد المغرب',
                            value: appSettings.eveningAzkarReminderEnabled.value,
                            onChanged: (newValue) async {
                              await appSettings
                                  .setEveningAzkarReminderEnabled(newValue);
                            },
                          ),
                          _buildSwitchRow(
                            context,
                            icon: Icons.bedtime_outlined,
                            title: 'تذكير أذكار النوم',
                            subtitle: 'بعد العشاء',
                            value: appSettings.sleepAzkarReminderEnabled.value,
                            onChanged: (newValue) async {
                              await appSettings
                                  .setSleepAzkarReminderEnabled(newValue);
                            },
                          ),
                          _buildSwitchRow(
                            context,
                            icon: Icons.refresh,
                            title: 'تذكير التسبيح',
                            subtitle: 'بعد العصر',
                            value: appSettings.tasbeehReminderEnabled.value,
                            onChanged: (newValue) async {
                              await appSettings
                                  .setTasbeehReminderEnabled(newValue);
                            },
                          ),
                          _buildSwitchRow(
                            context,
                            icon: Icons.calendar_today_outlined,
                            title: 'تذكير الجمعة',
                            subtitle: '10:00 صباحًا',
                            value: appSettings.weeklyFridayReminderEnabled.value,
                            onChanged: (newValue) async {
                              await appSettings
                                  .setWeeklyFridayReminderEnabled(newValue);
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      context,
                      title: 'محتوى الأذكار',
                      children: [
                        _buildSwitchRow(
                          context,
                          icon: Icons.shuffle,
                          title: 'ترتيب عشوائي للأذكار',
                          subtitle: 'يعرض الأذكار بترتيب متجدد',
                          value: appSettings.randomAzkarOrder.value,
                          onChanged: (newValue) async {
                            await appSettings.setRandomAzkarOrder(newValue);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      context,
                      title: 'النسخ الاحتياطي المحلي',
                      children: [
                        _buildActionRow(
                          context,
                          icon: Icons.cloud_upload_outlined,
                          title: 'إنشاء نسخة احتياطية',
                          subtitle: 'حفظ الإعدادات والاختصارات محليًا',
                          onTap: _createBackup,
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.cloud_download_outlined,
                          title: 'استعادة النسخة الاحتياطية',
                          subtitle: 'استرجاع آخر نسخة محفوظة',
                          onTap: _restoreBackup,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      context,
                      title: 'إجراءات إضافية',
                      children: [
                        _buildActionRow(
                          context,
                          icon: Icons.notifications_none_outlined,
                          title: 'إدارة التنبيهات المجدولة',
                          subtitle: 'عرض التنبيهات القادمة',
                          onTap: () => _showScheduledNotificationsDialog(
                            context,
                            currentTheme,
                          ),
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.share_outlined,
                          title: 'مشاركة التطبيق',
                          subtitle: 'أرسل التطبيق لمن تحب',
                          onTap: () => _showSnackBar(
                            context,
                            'ميزة المشاركة قيد التطوير!',
                            currentTheme,
                          ),
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.star_rate_outlined,
                          title: 'تقييم التطبيق',
                          subtitle: 'شارك رأيك لتطوير التطبيق',
                          onTap: () => Get.toNamed(AppRoute.appRating),
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.help_outline,
                          title: 'مركز المساعدة',
                          subtitle: 'أسئلة شائعة وحالة الدعم',
                          onTap: () => Get.toNamed(AppRoute.helpCenter),
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.support_agent_outlined,
                          title: 'تواصل مع الإدارة',
                          subtitle: 'محادثة مباشرة مع فريق الدعم',
                          onTap: () => Get.toNamed(AppRoute.supportChat),
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.lightbulb_outline,
                          title: 'الاقتراحات والأفكار',
                          subtitle: 'أضف اقتراحاً أو فكرة للتطوير',
                          onTap: () => Get.toNamed(AppRoute.suggestions),
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.policy_outlined,
                          title: 'سياسة الخصوصية',
                          subtitle: 'اطلع على سياسة البيانات',
                          onTap: () {
                            launchUrl(
                              Uri.parse(
                                "https://newbalignearab.arabwaredos.com/baligneback/rokenalmuslam.html",
                              ),
                            );
                          },
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.info_outline,
                          title: 'حول التطبيق والمطورين',
                          subtitle: 'تعرف على فريق العمل',
                          onTap: () {
                            Get.to(() => const AboutUsPage());
                          },
                        ),
                        _buildActionRow(
                          context,
                          icon: Icons.refresh_outlined,
                          title: 'إعادة تعيين الإعدادات',
                          subtitle: 'العودة للقيم الافتراضية',
                          onTap: () => _showConfirmResetDialog(
                            context,
                            currentTheme,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ..._withDividers(children, theme),
        ],
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> children, ThemeData theme) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: theme.dividerColor),
          ),
        );
      }
    }
    return items;
  }

  Widget _buildSwitchRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        _buildIconBadge(theme, icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: scheme.primary,
        ),
      ],
    );
  }

  Widget _buildSliderRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          children: [
            _buildIconBadge(theme, icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.primary,
              ),
            ),
          ],
        ),
        Slider.adaptive(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
          activeColor: scheme.primary,
          thumbColor: scheme.primary,
          inactiveColor: scheme.onSurface.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildDropdownRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        _buildIconBadge(theme, icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: scheme.surface,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface,
            ),
            items:
                items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            underline: const SizedBox.shrink(),
            icon: Icon(Icons.expand_more, color: scheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            _buildIconBadge(theme, icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: scheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBadge(ThemeData theme, IconData icon) {
    final scheme = theme.colorScheme;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: scheme.primary, size: 20),
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
