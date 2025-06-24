import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/praytime/prayer_times_controller.dart';
import 'package:intl/intl.dart';

class PrayerTimesView extends StatelessWidget {
  final PrayerTimesController controller = Get.put(PrayerTimesController());

  PrayerTimesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    // Using 'ar_EG' for more precise Arabic locale for Hijri date
    final hijriDate = DateFormat('dd MMMM yyyy', 'ar_EG').format(now);

    return Scaffold(
      // floatingActionButton: Obx(() {
      //   if (controller.isApproved.value) {
      //     return FloatingActionButton.extended(
      //       onPressed: () => controller.approvePrayerTimes(),
      //       icon: const Icon(Icons.check_circle),
      //       label: const Text('اعتماد الأوقات'),
      //       backgroundColor: Colors.teal,
      //       foregroundColor: Colors.white,
      //       elevation: 4,
      //     );
      //   }
      //   return const SizedBox();
      // }),
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
          Obx(() {
            if (controller.isLoading.value) {
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

                // Prayer Times Card with animation
                _buildPrayerTimesCard(theme, isDarkMode),

                const SizedBox(height: 20),

                // Location Info Card with map placeholder
                _buildLocationCard(theme, isDarkMode),

                const SizedBox(height: 20),

                // Settings cards in a grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildCountrySelectionCard(theme),
                      _buildCalculationMethodCard(theme),
                      _buildJuristicSchoolCard(theme),
                      _buildSettingsCard(theme),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Time adjustment slider for Yemen
                if (controller.selectedCountry.value.contains('اليمن'))
                  _buildTimeAdjustmentSlider(theme, isDarkMode),

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
          }),
        ],
      ),
    );
  }

  Widget _buildTimeAdjustmentSlider(ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color:
                        isDarkMode ? Colors.tealAccent : Colors.teal.shade700,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ضبط التوقيت لليمن',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: controller.timeAdjustment.value.toDouble(),
                      min: 0,
                      max: 120,
                      divisions: 24,
                      label: '${controller.timeAdjustment.value} دقيقة',
                      activeColor: Colors.teal,
                      inactiveColor: Colors.teal.withOpacity(0.3),
                      onChanged: (value) {
                        controller.updateTimeAdjustment(value.toInt());
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${controller.timeAdjustment.value} دقيقة',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'يمكنك ضبط الدقائق الإضافية لأوقات الصلاة في اليمن',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
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
                // Obx(() {
                //   if (controller.isApproved.value) {
                //     return Container(
                //       margin: const EdgeInsets.only(top: 10),
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 12,
                //         vertical: 6,
                //       ),
                //       decoration: BoxDecoration(
                //         color: Colors.white.withOpacity(0.2),
                //         borderRadius: BorderRadius.circular(20),
                //       ),
                //       child: const Text(
                //         'الأوقات معتمدة',
                //         style: TextStyle(
                //           color: Colors.white,
                //           fontSize: 14,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     );
                //   }
                //   return const SizedBox();
                // }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimesCard(ThemeData theme, bool isDarkMode) {
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
                  ...controller.prayerTimesData.entries.map((entry) {
                    final isCurrent = _isCurrentPrayerTime(
                      entry.key,
                      entry.value,
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
                        trailing: Text(
                          entry.value,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
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
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 6,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      controller.currentCountry.value.isNotEmpty
                          ? controller.currentCountry.value
                          : 'غير متوفر',
                      isDarkMode,
                    ),
                    const SizedBox(height: 8),
                    _buildLocationInfoRow(
                      Icons.location_city,
                      'المدينة',
                      controller.selectedCity.value.isNotEmpty
                          ? controller.selectedCity.value
                          : 'غير محددة',
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
    );
  }

  Widget _buildCountrySelectionCard(ThemeData theme) {
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
            colors: [Colors.blue.shade700, Colors.blue.shade500],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200.withOpacity(0.5),
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
                  const Icon(Icons.public, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'الدولة',
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
              Expanded(
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.blue.shade700,
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
                  value:
                      controller.selectedCountry.value.isEmpty ||
                              !controller.countries.contains(
                                controller.selectedCountry.value,
                              )
                          ? null
                          : controller.selectedCountry.value,
                  items:
                      controller.countries
                          .map(
                            (country) => DropdownMenuItem(
                              value: country,
                              child: Text(
                                country,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      controller.onCountryChanged(newValue);
                    }
                  },
                  hint: const Text(
                    'اختر دولة يدوياً',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
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
                  const Icon(Icons.calculate, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'طريقة الحساب',
                      style: theme.textTheme.titleSmall?.copyWith(
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
              Expanded(
                child: DropdownButtonFormField<int>(
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
                  value: controller.selectedCalculationMethod.value,
                  items:
                      controller.calculationMethods.entries
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
                      controller.updateTimeAdjustment(newValue);
                    }
                  },
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
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
                      style: theme.textTheme.bodyMedium?.copyWith(
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
              Expanded(
                child: DropdownButtonFormField<int>(
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
                  value: controller.selectedJuristicSchool.value,
                  items:
                      controller.juristicSchools.entries
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
                      controller.updateTimeAdjustment(newValue);
                    }
                  },
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
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
                  style: theme.textTheme.titleSmall?.copyWith(
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
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black54,
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

  bool _isCurrentPrayerTime(String prayerName, String prayerTime) {
    final now = DateTime.now();
    final timeParts = prayerTime.split(':');
    if (timeParts.length != 2) return false;

    try {
      final prayerHour = int.parse(timeParts[0]);
      final prayerMinute = int.parse(timeParts[1]);
      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayerHour,
        prayerMinute,
      );

      final startTimeWindow = prayerDateTime.subtract(
        const Duration(minutes: 30),
      );
      final endTimeWindow = prayerDateTime.add(const Duration(hours: 1));

      return now.isAfter(startTimeWindow) && now.isBefore(endTimeWindow);
    } catch (e) {
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
}
