import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';
import 'package:intl/intl.dart';

import 'package:adhan/adhan.dart';

class PrayerTimesView extends StatefulWidget {
  const PrayerTimesView({super.key});

  @override
  State<PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends State<PrayerTimesView> {
  final PrayerTimesController controller = Get.find<PrayerTimesController>();
  final AppSettingsController appSettings = Get.find<AppSettingsController>();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    // Using 'ar_EG' for more precise Arabic locale for Hijri date
    final hijriDate = DateFormat('dd MMMM yyyy', 'ar_EG').format(now);

    return Scaffold(
      floatingActionButton: GetX<PrayerTimesController>(
        builder: (controller) {
          if (controller.isApproved.value && !controller.isLoading) {
            return FloatingActionButton.extended(
              onPressed: () => controller.saveAndApproveTimes(),
              icon: const Icon(Icons.check_circle),
              label: const Text('إعادة اعتماد الأوقات'),
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              elevation: 0,
            );
          }
          return const SizedBox();
        },
      ),
      body: AppBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240.0,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'أوقات الصلاة',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/Gemini_Generated_Image_cijwhucijwhucijw.png',
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.08),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            scheme.primary.withOpacity(0.95),
                            scheme.secondary.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: scheme.primary,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => controller.manualRefresh(),
                  tooltip: 'تحديث أوقات الصلاة',
                ),
              ],
            ),

          // Page content
          GetX<AppSettingsController>(
            builder: (settings) {
              final isEnabled =
                  settings.prayerTimesNotificationsEnabled.value;
              return GetBuilder<PrayerTimesController>(
                builder: (controller) {
                  final hasLocation =
                      controller.latitude.value != 0.0 &&
                      controller.longitude.value != 0.0;

                if (!isEnabled) {
                  return SliverFillRemaining(
                    child: _buildStateCard(
                      theme: theme,
                      icon: Icons.notifications_off_outlined,
                      title: 'أوقات الصلاة غير مفعّلة',
                      message:
                          'يرجى تفعيل مواقيت الصلاة من الإعدادات لعرض الأوقات.',
                      action: OutlinedButton.icon(
                        onPressed: () => Get.toNamed(AppRoute.setting),
                        icon: const Icon(Icons.settings),
                        label: const Text('فتح الإعدادات'),
                      ),
                    ),
                  );
                }

                if (!hasLocation) {
                  return SliverFillRemaining(
                    child: _buildStateCard(
                      theme: theme,
                      icon: Icons.my_location,
                      title: 'حدد موقعك',
                      message: 'يلزم تحديد المنطقة لعرض مواقيت الصلاة بدقة.',
                      action: ElevatedButton.icon(
                        onPressed: () => controller.determinePosition(),
                        icon: const Icon(Icons.location_on, size: 22),
                        label: const Text(
                          'تحديد الموقع تلقائيًا',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                  );
                }

                if (controller.isLoading) {
                  return SliverFillRemaining(
                    child: _buildStateCard(
                      theme: theme,
                      icon: Icons.access_time,
                      title: 'جاري تحميل أوقات الصلاة',
                      message: 'يتم حساب الأوقات الآن، يرجى الانتظار.',
                      action: const CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return SliverFillRemaining(
                    child: _buildStateCard(
                      theme: theme,
                      icon: Icons.wifi_off,
                      title: 'تعذر جلب الأوقات',
                      message: controller.errorMessage.value,
                      iconColor: scheme.error,
                      action: ElevatedButton.icon(
                        onPressed: () => controller.determinePosition(),
                        icon: const Icon(Icons.location_on, size: 22),
                        label: const Text(
                          'تحديد الموقع تلقائيًا',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ),
                  );
                }

                if (controller.prayerTimesData.isEmpty) {
                  return SliverFillRemaining(
                    child: _buildStateCard(
                      theme: theme,
                      icon: Icons.access_time_outlined,
                      title: 'لا توجد أوقات متاحة',
                      message: 'قم بتحديث الموقع لإظهار مواقيت الصلاة.',
                      action: OutlinedButton.icon(
                        onPressed: () => controller.determinePosition(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('تحديث الموقع'),
                      ),
                    ),
                  );
                }

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Date and Hijri Card
                      _buildDateCard(theme, hijriDate),

                    const SizedBox(height: 20),

                    // Prayer Times Card with animation - Pass context here
                    _buildPrayerTimesCard(context, theme),

                    const SizedBox(height: 20),

                    // Location Info Card with map placeholder
                    _buildLocationCard(theme),

                    const SizedBox(height: 20),

                    // Settings cards in a grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          // تم إزالة بطاقة اختيار الدولة لأنها تعتمد على الموقع التلقائي
                          // _buildCountrySelectionCard(theme),
                          _buildCalculationMethodCard(theme),
                          const SizedBox(height: 16),
                          _buildJuristicSchoolCard(theme),
                          // تم نقل بطاقة الإعدادات لتكون اختيارية أو في مكان آخر
                          // _buildSettingsCard(theme),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Additional information
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'يتم تحديث أوقات الصلاة تلقائيًا حسب موقعك الجغرافي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                      const SizedBox(height: 40),
                    ]),
                  );
                },
              );
            },
          ),
        ],
      ),
    ));
  }

  Widget _buildStateCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
    Color? iconColor,
  }) {
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor ?? scheme.primary,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (action != null) ...[
                  const SizedBox(height: 20),
                  action,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard(ThemeData theme, String hijriDate) {
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Card(
        elevation: 6,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withOpacity(0.9),
                scheme.secondary.withOpacity(0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE', 'ar_EG').format(DateTime.now()),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  hijriDate,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary.withOpacity(0.95),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                GetBuilder<PrayerTimesController>(
                  builder: (controller) {
                    if (controller.isApproved.value) {
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.onPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'الأوقات معتمدة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Accept context as a parameter
  Widget _buildPrayerTimesCard(
    BuildContext context,
    ThemeData theme,
  ) {
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 6,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surface,
                  scheme.surface.withOpacity(0.9),
                ],
              ),
              image: const DecorationImage(
                image: AssetImage('assets/images/patern.png'),
                fit: BoxFit.cover,
                opacity: 0.05,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        color: scheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'أوقات الصلاة',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'اليوم',
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),
                  if (controller.prayerTimesData.isNotEmpty) ...[
                    ...controller.prayerTimesData.entries.map((entry) {
                      final isCurrent = _isCurrentPrayerTime(
                        entry.key,
                        controller.prayerTimesData,
                      );
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color:
                              isCurrent
                                  ? scheme.primary.withOpacity(0.12)
                                  : null,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              isCurrent
                                  ? Border.all(
                                    color: scheme.primary,
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  isCurrent
                                      ? scheme.primary
                                      : scheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getPrayerIcon(entry.key),
                              color:
                                  isCurrent
                                      ? scheme.onPrimary
                                      : scheme.onSurface.withOpacity(0.6),
                              size: 28,
                            ),
                          ),
                          title: Text(
                            entry.key,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight:
                                  isCurrent ? FontWeight.bold : FontWeight.w600,
                              color:
                                  isCurrent ? scheme.primary : scheme.onSurface,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                entry.value,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color:
                                      isCurrent
                                          ? scheme.primary
                                          : scheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.edit_note_rounded,
                                color: scheme.onSurface.withOpacity(0.4),
                                size: 22,
                              ),
                            ],
                          ),
                          onTap:
                              () => _showAdjustmentDialog(
                                context,
                                entry.key,
                              ),
                        ),
                      );
                    }).toList(),
                  ],
                  const SizedBox(height: 15),
                  // تلميح للمستخدم
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '* انقر على وقت الصلاة لتعديله يدويًا.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // زر اعتماد التعديلات
                  ElevatedButton.icon(
                    onPressed:
                        () =>
                            controller.saveAndApproveTimes(), // This now exists
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('اعتماد هذه التوقيتات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLocationCard(ThemeData theme) {
    final scheme = theme.colorScheme;
    return GetX<PrayerTimesController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            elevation: 6,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: scheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/maping.png',
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                      opacity: const AlwaysStoppedAnimation(0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: scheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'الموقع الحالي',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30, thickness: 1),
                        _buildLocationInfoRow(
                          Icons.public,
                          'الدولة',
                          controller.currentAddress.value.isNotEmpty
                              ? controller.currentAddress.value
                              : 'غير متوفر',
                          scheme,
                        ),
                        const SizedBox(height: 8),
                        _buildLocationInfoRow(
                          Icons.location_city,
                          'المدينة',
                          controller.currentAddress.value.split(',').first,
                          scheme,
                        ),
                        const SizedBox(height: 8),
                        _buildLocationInfoRow(
                          Icons.gps_fixed,
                          'الإحداثيات',
                          '${controller.latitude.value.toStringAsFixed(4)}, ${controller.longitude.value.toStringAsFixed(4)}',
                          scheme,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => controller.determinePosition(),
                            icon: const Icon(Icons.my_location, size: 22),
                            label: const Text(
                              'تحديث الموقع',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: scheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalculationMethodCard(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.primary.withOpacity(0.85)],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calculate, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'طريقة الحساب',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<CalculationMethod>(
                dropdownColor: scheme.primary,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: scheme.onPrimary.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  labelText: '',
                  labelStyle: TextStyle(color: scheme.onPrimary.withOpacity(0.7)),
                ),
                value: controller.calculationMethod.value,
                items:
                    controller.calculationMethodNames.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              style: TextStyle(color: scheme.onPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    controller.onCalculationMethodChanged(newValue);
                  }
                },
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(Icons.arrow_drop_down, color: scheme.onPrimary),
                style: TextStyle(color: scheme.onPrimary, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJuristicSchoolCard(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.secondary, scheme.secondary.withOpacity(0.85)],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.secondary.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.school, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'المذهب الفقهي',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<Madhab>(
                dropdownColor: scheme.secondary,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: scheme.onSecondary.withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  labelText: '',
                  labelStyle: TextStyle(color: scheme.onSecondary.withOpacity(0.7)),
                ),
                value: controller.madhab.value,
                items:
                    controller.madhabNames.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              style: TextStyle(color: scheme.onSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    controller.onJuristicSchoolChanged(newValue);
                  }
                },
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(Icons.arrow_drop_down, color: scheme.onSecondary),
                style: TextStyle(color: scheme.onSecondary, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme) {
    final scheme = theme.colorScheme;
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.secondary.withOpacity(0.9)],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showSettingsDialog(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings, size: 36, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  'إعدادات إضافية',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Image.asset(
                  'assets/images/artup.png',
                  height: 10,
                  color: scheme.onPrimary.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfoRow(
    IconData icon,
    String title,
    String value,
    ColorScheme scheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: scheme.primary,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              '$title: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: scheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'الفجر':
        return Icons.wb_twilight;
      case 'الشروق':
        return Icons.wb_sunny_outlined;
      case 'الظهر':
        return Icons.sunny;
      case 'العصر':
        return Icons.brightness_5;
      case 'المغرب':
        return Icons.wb_cloudy;
      case 'العشاء':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }

  bool _isCurrentPrayerTime(String prayerName, Map<String, String> allTimes) {
    try {
      final now = DateTime.now();
      DateTime? nextPrayer;
      DateTime? currentPrayer;
      String? currentPrayerName;

      // Convert all prayer times to DateTime objects for today
      final sortedTimes =
          allTimes.entries.map((entry) {
            final time = controller.parseTimeOfDay(entry.value);
            return MapEntry(
              entry.key,
              DateTime(now.year, now.month, now.day, time.hour, time.minute),
            );
          }).toList();

      // Sort by time
      sortedTimes.sort((a, b) => a.value.compareTo(b.value));

      // Find the next prayer
      for (final prayer in sortedTimes) {
        if (prayer.value.isAfter(now)) {
          nextPrayer = prayer.value;
          break;
        }
      }

      // If no next prayer today, the current one is Isha (last prayer)
      if (nextPrayer == null) {
        currentPrayerName = 'العشاء';
      } else {
        // Find the prayer just before the next prayer
        final nextPrayerIndex = sortedTimes.indexWhere(
          (p) => p.value == nextPrayer,
        );
        if (nextPrayerIndex > 0) {
          currentPrayerName = sortedTimes[nextPrayerIndex - 1].key;
        } else {
          // If the next prayer is the first one (Fajr), then current is Isha from yesterday
          currentPrayerName = 'العشاء';
        }
      }

      return prayerName == currentPrayerName;
    } catch (e) {
      print("Error in _isCurrentPrayerTime: $e");
      return false;
    }
  }

  // void _showNotificationSettings(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('إعدادات الإشعارات'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Obx(
  //               () => SwitchListTile(
  //                 title: const Text('تفعيل الإشعارات'),
  //                 value: controller.areTimesApproved.value,
  //                 onChanged: (value) {
  //                   if (value) {
  //                     controller.approvePrayerTimes();
  //                   } else {
  //                     controller.areTimesApproved.value = false;
  //                     controller.flutterLocalNotificationsPlugin.cancelAll();
  //                   }
  //                 },
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             const Text(
  //               'سيتم إرسال إشعارات قبل كل صلاة بـ 10 دقائق',
  //               style: TextStyle(fontSize: 14),
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('تم'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showSettingsDialog() {
    Get.defaultDialog(
      title: 'الإعدادات الإضافية',
      content: Column(
        children: [
          // Obx(
          //   () => ListTile(
          //     leading: const Icon(Icons.notifications),
          //     title: const Text('حالة الإشعارات'),
          //     trailing: Text(
          //       controller.isApproved.value ? 'مفعلة' : 'غير مفعلة',
          //       style: TextStyle(
          //         color: controller.isApproved.value ? Colors.green : Colors.red,
          //       ),
          //     ),
          //   ),
          // ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('مساعدة'),
            onTap:
                () => Get.snackbar(
                  'مساعدة',
                  'سيتم إضافة المزيد من الخيارات في التحديثات القادمة',
                ),
          ),
        ],
      ),
      confirm: TextButton(onPressed: () => Get.back(), child: const Text('تم')),
    );
  }

  void _showAdjustmentDialog(
    BuildContext context,
    String prayerName,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Temporary state for the dialog slider
    final ValueNotifier<int> currentAdjustment = ValueNotifier<int>(
      controller.prayerTimeAdjustments[prayerName] ?? 0,
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تعديل وقت ${prayerName}',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: currentAdjustment,
              builder: (context, value, _) {
                return Text(
                  'التعديل الحالي: $value دقيقة',
                  style: theme.textTheme.titleMedium,
                );
              },
            ),
            const SizedBox(height: 10),
            ValueListenableBuilder<int>(
              valueListenable: currentAdjustment,
              builder: (context, value, _) {
                final originalTimeStr =
                    controller.originalPrayerTimes[prayerName] ?? "00:00";
                final time = controller.parseTimeOfDay(originalTimeStr);
                final originalDateTime = DateTime(
                  2023,
                  1,
                  1,
                  time.hour,
                  time.minute,
                );
                final adjustedDateTime = originalDateTime.add(
                  Duration(minutes: value),
                );
                final formattedTime = DateFormat(
                  'hh:mm a',
                  'ar',
                ).format(adjustedDateTime);

                return Text(
                  'الوقت الجديد: $formattedTime',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: currentAdjustment,
              builder: (context, value, _) {
                return Slider(
                  value: value.toDouble(),
                  min: -60,
                  max: 60,
                  divisions: 120,
                  activeColor: scheme.primary,
                  inactiveColor: scheme.primary.withOpacity(0.3),
                  label: '$value دقيقة',
                  onChanged: (double newValue) {
                    currentAdjustment.value = newValue.round();
                  },
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('-60 د'), Text('0'), Text('+60 د')],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Apply the final adjustment value to the main controller
              controller.setPrayerTimeAdjustment(
                prayerName,
                currentAdjustment.value,
              );
              currentAdjustment.dispose();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30),
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
