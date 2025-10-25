import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart';
import 'package:intl/intl.dart';

import 'package:adhan/adhan.dart';

class PrayerTimesView extends StatefulWidget {
  const PrayerTimesView({super.key});

  @override
  State<PrayerTimesView> createState() => _PrayerTimesViewState();
}

class _PrayerTimesViewState extends State<PrayerTimesView> {
  final PrayerTimesController controller = Get.put(PrayerTimesController());
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    // Using 'ar_EG' for more precise Arabic locale for Hijri date
    final hijriDate = DateFormat('dd MMMM yyyy', 'ar_EG').format(now);

    return Scaffold(
      floatingActionButton: Obx(() {
        if (controller.isApproved.value && !controller.isLoading) {
          return FloatingActionButton.extended(
            onPressed: () => controller.saveAndApproveTimes(),
            icon: const Icon(Icons.check_circle),
            label: const Text('إعادة اعتماد الأوقات'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 4,
          );
        }
        return const SizedBox();
      }),
      body: CustomScrollView(
        slivers: [
          // AppBar with transparency effect
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'أوقات الصلاة',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
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
                    opacity: const AlwaysStoppedAnimation(0.2),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.teal.shade800,
                          isDarkMode
                              ? Colors.teal.shade900
                              : Colors.teal.shade400,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: isDarkMode ? Colors.teal[900] : Colors.teal,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => controller.manualRefresh(),
                tooltip: 'تحديث أوقات الصلاة',
              ),
              // IconButton(
              //   icon: const Icon(Icons.notifications, color: Colors.white),
              //   onPressed: () => _showNotificationSettings(context),
              //   tooltip: 'إعدادات الإشعارات',
              // ),
            ],
          ),

          // Page content
          GetBuilder<PrayerTimesController>(
            builder: (controller) {
              if (controller.isLoading) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(
                          'جاري تحميل أوقات الصلاة...',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.errorMessage.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            color: Colors.red.shade600,
                            size: 70,
                          ),
                          const SizedBox(height: 25),
                          Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 35),
                          ElevatedButton.icon(
                            onPressed: () => controller.determinePosition(),
                            icon: const Icon(Icons.location_on, size: 22),
                            label: const Text(
                              'تحديد الموقع تلقائيًا',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent.shade700,
                              foregroundColor: Colors.white,
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
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  // Date and Hijri Card
                  _buildDateCard(theme, isDarkMode, hijriDate),

                  const SizedBox(height: 20),

                  // Prayer Times Card with animation - Pass context here
                  _buildPrayerTimesCard(context, theme, isDarkMode),

                  const SizedBox(height: 20),

                  // Location Info Card with map placeholder
                  _buildLocationCard(theme, isDarkMode),

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
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(ThemeData theme, bool isDarkMode, String hijriDate) {
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
                isDarkMode ? Colors.teal.shade700 : Colors.teal.shade500,
                isDarkMode ? Colors.teal.shade900 : Colors.teal.shade400,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode
                        ? Colors.teal.shade900
                        : Colors.teal.shade200)
                    .withOpacity(0.5),
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  hijriDate,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white.withOpacity(0.95),
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
                          color: Colors.white.withOpacity(0.2),
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
    bool isDarkMode,
  ) {
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
                  isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
                  isDarkMode ? Colors.blueGrey.shade800 : Colors.grey.shade50,
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
                        color:
                            isDarkMode
                                ? Colors.tealAccent
                                : Colors.teal.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'أوقات الصلاة',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.teal[700] : Colors.teal[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'اليوم',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.teal[800],
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
                                  ? (isDarkMode
                                      ? Colors.teal.shade800.withOpacity(0.4)
                                      : Colors.teal.withOpacity(0.1))
                                  : null,
                          borderRadius: BorderRadius.circular(15),
                          border:
                              isCurrent
                                  ? Border.all(
                                    color:
                                        isDarkMode
                                            ? Colors.tealAccent
                                            : Colors.teal.shade600,
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
                                      ? Colors.teal.shade600
                                      : (isDarkMode
                                          ? Colors.blueGrey.shade700
                                          : Colors.grey.shade200),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getPrayerIcon(entry.key),
                              color:
                                  isCurrent
                                      ? Colors.white
                                      : (isDarkMode
                                          ? Colors.blueGrey.shade300
                                          : Colors.grey.shade700),
                              size: 28,
                            ),
                          ),
                          title: Text(
                            entry.key,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight:
                                  isCurrent ? FontWeight.bold : FontWeight.w600,
                              color:
                                  isCurrent
                                      ? (isDarkMode
                                          ? Colors.tealAccent
                                          : Colors.teal.shade700)
                                      : (isDarkMode
                                          ? Colors.white
                                          : Colors.black87),
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
                                          ? (isDarkMode
                                              ? Colors.tealAccent
                                              : Colors.teal.shade700)
                                          : (isDarkMode
                                              ? Colors.white70
                                              : Colors.black54),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.edit_note_rounded,
                                color:
                                    isDarkMode
                                        ? Colors.white.withOpacity(0.4)
                                        : Colors.black.withOpacity(0.4),
                                size: 22,
                              ),
                            ],
                          ),
                          onTap:
                              () => _showAdjustmentDialog(
                                context,

                                entry.key,
                                isDarkMode,
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
                        color:
                            isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
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
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
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

  Widget _buildLocationCard(ThemeData theme, bool isDarkMode) {
    return Obx(
      () => Padding(
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
              color: isDarkMode ? Colors.blueGrey.shade900 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? Colors.black45 : Colors.grey.shade200)
                      .withOpacity(0.5),
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
                            color:
                                isDarkMode
                                    ? Colors.tealAccent
                                    : Colors.teal.shade700,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'الموقع الحالي',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
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
                        isDarkMode,
                      ),
                      const SizedBox(height: 8),
                      _buildLocationInfoRow(
                        Icons.location_city,
                        'المدينة',
                        controller.currentAddress.value
                            .split(',')
                            .first, // Extract city
                        isDarkMode,
                      ),
                      const SizedBox(height: 8),
                      _buildLocationInfoRow(
                        Icons.gps_fixed,
                        'الإحداثيات',
                        '${controller.latitude.value.toStringAsFixed(4)}, ${controller.longitude.value.toStringAsFixed(4)}',
                        isDarkMode,
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
                            backgroundColor:
                                isDarkMode ? Colors.teal.shade700 : Colors.teal,
                            foregroundColor: Colors.white,
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
      ),
    );
  }

  Widget _buildCalculationMethodCard(ThemeData theme) {
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
            colors: [Colors.orange.shade700, Colors.orange.shade500],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade200.withOpacity(0.5),
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
                dropdownColor: Colors.orange.shade700,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  labelText: '',
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                value: controller.calculationMethod.value,
                items:
                    controller.calculationMethodNames.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              style: const TextStyle(color: Colors.white),
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
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJuristicSchoolCard(ThemeData theme) {
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
            colors: [Colors.purple.shade700, Colors.purple.shade500],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.shade200.withOpacity(0.5),
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
                dropdownColor: Colors.purple.shade700,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  labelText: '',
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                value: controller.madhab.value,
                items:
                    controller.madhabNames.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              style: const TextStyle(color: Colors.white),
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
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme) {
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
            colors: [Colors.green.shade700, Colors.green.shade500],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade200.withOpacity(0.5),
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
                  color: Colors.white.withOpacity(0.7),
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
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: isDarkMode ? Colors.tealAccent : Colors.teal.shade600,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              '$title: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
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
    bool isDarkMode,
  ) {
    final theme = Theme.of(context);
    // Temporary state for the dialog slider
    final RxInt currentAdjustment =
        (controller.prayerTimeAdjustments[prayerName] ?? 0).obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تعديل وقت ${prayerName}',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: isDarkMode ? Colors.tealAccent : Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Text(
                'التعديل الحالي: ${currentAdjustment.value} دقيقة',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),
            Obx(() {
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
                Duration(minutes: currentAdjustment.value),
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
            }),
            const SizedBox(height: 20),
            Obx(
              () => Slider(
                value: currentAdjustment.value.toDouble(),
                min: -60,
                max: 60,
                divisions: 120,
                activeColor: Colors.teal,
                inactiveColor: Colors.teal.withOpacity(0.3),
                label: '${currentAdjustment.value.round()} دقيقة',
                onChanged: (double value) {
                  currentAdjustment.value = value.round();
                },
              ),
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
                color: isDarkMode ? Colors.white70 : Colors.black54,
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
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
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
