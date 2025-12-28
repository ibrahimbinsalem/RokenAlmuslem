// views/adkar/adkar_alnom_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// تأكد من المسار الصحيح للكنترولر
import 'package:rokenalmuslem/controller/adkar/sleepcontrller.dart';
// استيراد خدمة الإشعارات ومعرفات الإشعارات ووقت الإشعارات
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart'; // مسار AppSettingsController
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

// ويدجت FadeIn (يمكنك وضعها في ملف منفصل مثل utilities/widgets.dart لتجنب التكرار)
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeIn({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

class AdkarAlnomView extends StatelessWidget {
  // تهيئة الكنترولر وتخزينه في GetX
  final AdkarAlnomController _controller = Get.put(AdkarAlnomController());
  // الوصول إلى مثيل NotificationService
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  AdkarAlnomView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ModernScaffold(
      title: 'أذكار النوم',
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _controller.resetAllCounters,
          tooltip: 'إعادة تعيين جميع العدادات',
          color: Colors.white,
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          decoration: BoxDecoration(
            color: scheme.secondary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: scheme.secondary.withOpacity(0.35),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 22, minute: 0),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: Get.theme.copyWith(
                        colorScheme: Get.theme.colorScheme.copyWith(
                          primary: Get.theme.colorScheme.primary,
                          onPrimary: Get.theme.colorScheme.onPrimary,
                          surface: Get.theme.colorScheme.surface,
                          onSurface: Get.theme.colorScheme.onSurface,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Get.theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedTime != null) {
                  _notificationService.scheduleDailyReminder(
                    id: AppSettingsController.sleepAzkarId,
                    title: 'تذكير: أذكار النوم',
                    body: 'لا تنسَ أذكار النوم قبل أن تنام.',
                    time: TimeOfDay(
                      hour: pickedTime.hour,
                      minute: pickedTime.minute,
                    ),
                    payload: 'sleep_azkar_reminder',
                  );
                  Get.snackbar(
                    'تم تفعيل التذكير',
                    'ستتلقى تذكيرًا يوميًا لأذكار النوم في الساعة ${pickedTime.format(context)}.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: scheme.secondary,
                    colorText: scheme.onSecondary,
                    borderRadius: 10,
                    margin: const EdgeInsets.all(16),
                  );
                } else {
                  Get.snackbar(
                    'إلغاء التفعيل',
                    'لم يتم تحديد وقت لتذكير أذكار النوم.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: scheme.error,
                    colorText: scheme.onError,
                    borderRadius: 10,
                    margin: const EdgeInsets.all(16),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.nights_stay_outlined,
                      color: scheme.onSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'تذكير النوم',
                      style: TextStyle(
                        color: scheme.onSecondary,
                        fontFamily: 'Amiri',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      body: Stack(
        children: [
          // زخرفة الخلفية (مطابقة لصفحة أذكار الصباح)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/مسبحة.png', // تأكد من هذا المسار
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // قائمة الأذكار
          GetX<AdkarAlnomController>(
            builder: (_) => ListView.builder(
              padding: const EdgeInsets.only(
                top:
                    kToolbarHeight +
                    40, // تعديل الـ padding بسبب الـ AppBar الشفاف
                bottom: 20,
              ),
              itemCount: _controller.items.length,
              itemBuilder: (context, index) {
                final dhikrItem = _controller.items[index];

                // تخطي عرض العناصر الفارغة
                if (dhikrItem["name"].isEmpty &&
                    dhikrItem["start"].isEmpty &&
                    dhikrItem["ayah"].isEmpty &&
                    dhikrItem["mang"].isEmpty) {
                  return const SizedBox.shrink();
                }

                return FadeIn(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: index * 50), // تأثير ظهور متدرج
                  child: _buildDhikrCard(dhikrItem, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // دالة لبناء بطاقة الذكر الواحدة
  Widget _buildDhikrCard(Map<String, dynamic> dhikr, int index) {
    final theme = Get.theme;
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent, // لجعل InkWell يعمل بشكل صحيح
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDhikrDetails(dhikr), // عند النقر، عرض التفاصيل
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // نص البداية (إن وجد)
                if (dhikr['start'] != null &&
                    dhikr['start'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      dhikr['start'],
                      style: TextStyle(
                        fontSize: 18,
                        color: scheme.onSurface.withOpacity(0.7),
                        fontFamily: 'Amiri',
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                // نص الذكر الرئيسي
                Text(
                  dhikr['name'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                    fontFamily: 'Amiri',
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
                Divider(color: scheme.onSurface.withOpacity(0.15), thickness: 1),
                // نص الفضل/المعنى (إن وجد)
                if (dhikr['meaning'] != null &&
                    dhikr['meaning'].toString().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'معنى وفضل الذكر:',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: scheme.secondary,
                          fontFamily: 'Amiri',
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        dhikr['meaning'],
                        style: TextStyle(
                          fontSize: 17,
                          color: scheme.onSurface.withOpacity(0.85),
                          fontFamily: 'Amiri',
                          height: 1.6,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                // صف العداد والمصدر
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 0),
                        child: Text(
                          dhikr['ayah'], // مصدر الذكر
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurface.withOpacity(0.5),
                            fontFamily: 'Amiri',
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                    _buildCounter(
                      dhikr,
                      index,
                    ), // بناء العداد وزر إعادة التعيين الخاص به
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لبناء العداد
  Widget _buildCounter(Map<String, dynamic> dhikr, int index) {
    final theme = Get.theme;
    final scheme = theme.colorScheme;
    return GetX<AdkarAlnomController>(
      builder: (_) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر إعادة تعيين العداد الفردي
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 22),
            onPressed:
                () => _controller.resetCount(index), // استدعاء من الكنترولر
            color: scheme.onSurface.withOpacity(0.7),
            tooltip: 'إعادة تعيين هذا العداد',
          ),
          // زر العداد نفسه
          GestureDetector(
            onTap:
                () => _controller.decrementCount(index), // استدعاء من الكنترولر
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      dhikr['count'].value >
                              0 // لاحظ استخدام .value هنا
                          ? [
                            scheme.primary,
                            scheme.secondary,
                          ]
                          : [
                            scheme.onSurface.withOpacity(0.25),
                            scheme.onSurface.withOpacity(0.18),
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color:
                        dhikr['count'].value > 0
                            ? scheme.primary.withOpacity(0.4)
                            : Colors.black.withOpacity(0.25),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 200),
                  tween: Tween(begin: 0.8, end: 1.0), // تأثير "الانبثاق"
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Text(
                        '${dhikr['count'].value}', // لاحظ استخدام .value هنا
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة عرض التفاصيل في BottomSheet
  void _showDhikrDetails(Map<String, dynamic> dhikr) {
    final theme = Get.theme;
    final scheme = theme.colorScheme;
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/images/مسبحة.png', // نفس النمط الخلفي
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 25),
                        decoration: BoxDecoration(
                          color: scheme.onSurface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    if (dhikr['start'] != null &&
                        dhikr['start'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          dhikr['start'],
                          style: TextStyle(
                            fontSize: 19,
                            color: scheme.onSurface.withOpacity(0.75),
                            fontFamily: 'Amiri',
                            height: 1.5,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    Text(
                      dhikr['name'],
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                        fontFamily: 'Amiri',
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 25),
                    if (dhikr['mang'] != null &&
                        dhikr['mang'].toString().isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'فضل الذكر:',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: scheme.secondary,
                              fontFamily: 'Amiri',
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            dhikr['mang'],
                            style: TextStyle(
                              fontSize: 17,
                              color: scheme.onSurface.withOpacity(0.85),
                              fontFamily: 'Amiri',
                              height: 1.6,
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            dhikr['ayah'],
                            style: TextStyle(
                              fontSize: 15,
                              color: scheme.onSurface.withOpacity(0.6),
                              fontFamily: 'Amiri',
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'أذكار النوم', // نص ثابت لأن 'category' غير موجود
                            style: TextStyle(
                              fontSize: 14,
                              color: scheme.primary,
                              fontFamily: 'Amiri',
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true, // لتحديد ارتفاع الـ bottom sheet
    );
  }
}
