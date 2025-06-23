// lib/views/tasbeeh_view.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

// تأكد من المسار الصحيح لوحدة التحكم الخاصة بك
import 'package:rokenalmuslem/controller/more/masbahacontroller.dart';
// استيراد خدمة الإشعارات ومعرفات الإشعارات ووقت الإشعارات
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart'; // مسار AppSettingsController

class TasbeehView extends StatelessWidget {
  final TasbeehController controller = Get.put(TasbeehController());
  // الوصول إلى مثيل NotificationService
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  TasbeehView({Key? key}) : super(key: key);

  // دالة لحساب اللون بناءً على التقدم - ألوان متوهجة
  Color _getCounterColor(int current, int target) {
    if (target == 0) return Colors.white;
    double progress = current / target;

    Color startColor = Colors.blue.shade300; // أزرق فاتح متوهج
    Color endColor = Colors.deepPurple.shade300; // بنفسجي فاتح متوهج

    if (progress >= 1.0) {
      return Colors.limeAccent.shade200; // أخضر ليموني عند الاكتمال
    } else {
      return Color.lerp(startColor, endColor, progress)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: FadeInDown(
          delay: const Duration(milliseconds: 200),
          child: const Text(
            "المسبحة", // اسم جديد
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal', // أو أي خط عربي عصري
              fontSize: 28,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.blueAccent, // توهج أزرق نيون
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          FadeInRight(
            delay: const Duration(milliseconds: 400),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
              onPressed: controller.resetCounter,
              tooltip: 'إعادة تعيين',
            ),
          ),
          FadeInRight(
            delay: const Duration(milliseconds: 600),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 30),
              onPressed: () => controller.showTargetCountDialog(context),
              tooltip: 'تغيير الهدف',
            ),
          ),
          // زر "تذكير التسبيح" المحسّن مع اختيار الوقت
          FadeInRight(
            delay: const Duration(milliseconds: 800), // تأخير بسيط لظهور متدرج
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 4.0,
              ),
              decoration: BoxDecoration(
                color:
                    Get.theme.colorScheme.secondary, // لون خلفية الزر (الأخضر)
                borderRadius: BorderRadius.circular(12), // حواف مدورة
                boxShadow: [
                  BoxShadow(
                    color: Get.theme.colorScheme.secondary.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2), // ظل خفيف
                  ),
                ],
              ),
              child: Material(
                color:
                    Colors
                        .transparent, // لجعل Material transparent لعرض BoxDecoration
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    // جعل onTap async
                    // عرض منتقي الوقت للسماح للمستخدم باختيار وقت التنبيه
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(
                        hour: 21,
                        minute: 0,
                      ), // وقت افتراضي (9:00 مساءً)
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: Get.theme.copyWith(
                            colorScheme: Get.theme.colorScheme.copyWith(
                              primary:
                                  Get
                                      .theme
                                      .colorScheme
                                      .primary, // لون الثيم الأساسي
                              onPrimary:
                                  Get
                                      .theme
                                      .colorScheme
                                      .onPrimary, // لون النص على الأساسي
                              surface:
                                  Get
                                      .theme
                                      .colorScheme
                                      .surface, // لون الخلفية في منتقي الوقت
                              onSurface:
                                  Get
                                      .theme
                                      .colorScheme
                                      .onSurface, // لون النص على الخلفية
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Get
                                        .theme
                                        .colorScheme
                                        .primary, // لون أزرار النص
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedTime != null) {
                      // جدولة إشعار تذكير التسبيح بالوقت الذي اختاره المستخدم
                      _notificationService.scheduleDailyReminder(
                        id:
                            AppSettingsController
                                .tasbeehReminderId, // استخدام ID مخصص للتسبيح
                        title: 'تذكير: وقت التسبيح',
                        body: 'لا تنسَ التسبيح وذكر الله في هذا الوقت.',
                        time: TimeOfDay(
                          hour: pickedTime.hour,
                          minute: pickedTime.minute,
                        ), // استخدام الوقت المختار
                        payload: 'tasbeeh_reminder',
                      );
                      Get.snackbar(
                        'تم تفعيل التذكير',
                        'ستتلقى تذكيرًا يوميًا للتسبيح في الساعة ${pickedTime.format(context)}.', // عرض الوقت المختار
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor:
                            Get
                                .theme
                                .colorScheme
                                .secondary, // لون خلفية السناك بار (الأخضر)
                        colorText:
                            Get
                                .theme
                                .colorScheme
                                .onSecondary, // لون النص في السناك بار (الأبيض)
                        borderRadius: 10,
                        margin: const EdgeInsets.all(16),
                      );
                    } else {
                      // إذا لم يتم اختيار وقت (المستخدم ألغى)، يمكن إظهار رسالة أو عدم فعل شيء
                      Get.snackbar(
                        'إلغاء التفعيل',
                        'لم يتم تحديد وقت لتذكير التسبيح.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
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
                      mainAxisSize: MainAxisSize.min, // للحفاظ على الصف مدمجًا
                      children: [
                        Icon(
                          Icons
                              .touch_app_outlined, // أيقونة مناسبة لـ "تسبيح" أو "عداد"
                          color:
                              Get
                                  .theme
                                  .colorScheme
                                  .onSecondary, // لون الأيقونة (أبيض)
                          size: 20,
                        ),
                        const SizedBox(
                          width: 6,
                        ), // مسافة صغيرة بين الأيقونة والنص
                        Text(
                          'تذكير التسبيح', // نص واضح للزر
                          style: TextStyle(
                            color: Get.theme.colorScheme.onSecondary,
                            fontFamily: 'Tajawal',
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
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0F0F1A),
              const Color(0xFF1E1E30),
              const Color(0xFF0A0A10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // تأثيرات ضوئية متحركة خفيفة (ككرات طاقة أو نجوم بعيدة)
            Positioned(
              top: Get.height * 0.15,
              left: Get.width * 0.1,
              child: const Icon(
                    Icons.fiber_manual_record,
                    color: Colors.purpleAccent,
                    size: 40,
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fade(
                    duration: const Duration(seconds: 4),
                    begin: 0.2,
                    end: 0.8,
                  )
                  .scale(
                    delay: const Duration(seconds: 1),
                    duration: const Duration(seconds: 3),
                  )
                  .move(
                    begin: const Offset(-30, -30),
                    end: const Offset(30, 30),
                    duration: const Duration(seconds: 6),
                    curve: Curves.easeInOutSine,
                  ),
            ),
            Positioned(
              bottom: Get.height * 0.1,
              right: Get.width * 0.15,
              child: const Icon(
                    Icons.fiber_manual_record,
                    color: Colors.cyanAccent,
                    size: 35,
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fade(
                    delay: const Duration(seconds: 2),
                    duration: const Duration(seconds: 5),
                    begin: 0.3,
                    end: 0.9,
                  )
                  .move(
                    begin: const Offset(40, 40),
                    end: const Offset(-40, -40),
                    duration: const Duration(seconds: 7),
                    curve: Curves.easeInOutSine,
                  ),
            ),
            Positioned(
              top: Get.height * 0.4,
              right: Get.width * 0.05,
              child: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orangeAccent,
                    size: 25,
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fade(
                    duration: const Duration(seconds: 3),
                    begin: 0.1,
                    end: 0.6,
                  )
                  .move(
                    begin: const Offset(20, -20),
                    end: const Offset(-20, 20),
                    duration: const Duration(seconds: 5),
                    curve: Curves.easeInOut,
                  ),
            ),

            // قسم إحصائيات اليوم (تمت إضافته هنا)
            Positioned(
              top:
                  AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  10, // أسفل شريط التطبيق
              left: 20,
              right: 20,
              child: Obx(
                () => FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4), // خلفية شبه شفافة
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "تسبيحات اليوم:",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 18,
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${controller.dailyTasbeehCount.value}",
                          style: const TextStyle(
                            color: Colors.yellowAccent, // لون مميز للعدد
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                            shadows: [
                              Shadow(
                                blurRadius: 8.0,
                                color: Colors.yellowAccent,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // نص الذكر
                  FadeInDown(
                    delay: const Duration(milliseconds: 800),
                    child: Obx(
                      () => Text(
                            controller.currentDhikr.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Amiri', // أو خط عربي عصري
                              shadows: [
                                Shadow(
                                  blurRadius: 15.0,
                                  color: Colors.blueAccent, // توهج نيون أزرق
                                  offset: Offset(0, 0),
                                ),
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.white54,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: const Duration(seconds: 2),
                            color: Colors.white.withOpacity(0.5),
                          )
                          .scale(duration: const Duration(seconds: 1)),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // العداد
                  Obx(
                    () => GestureDetector(
                          onTap: controller.incrementCounter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _getCounterColor(
                                    controller.counter.value,
                                    controller.targetCount.value,
                                  ).withOpacity(0.9), // لون العداد المتوهج
                                  Colors.black.withOpacity(
                                    0.3,
                                  ), // لون داخلي داكن للعمق
                                ],
                                stops: const [0.0, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getCounterColor(
                                    controller.counter.value,
                                    controller.targetCount.value,
                                  ).withOpacity(0.8),
                                  blurRadius: 35.0, // زيادة التوهج
                                  spreadRadius: 8.0, // زيادة انتشار التوهج
                                  offset: Offset.zero,
                                ),
                                const BoxShadow(
                                  color: Colors.black45, // ظل سفلي لإعطاء عمق
                                  blurRadius: 10.0,
                                  spreadRadius: 2.0,
                                  offset: Offset(0, 10),
                                ),
                              ],
                              border: Border.all(
                                color: _getCounterColor(
                                  controller.counter.value,
                                  controller.targetCount.value,
                                ).withOpacity(0.6),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                        "${controller.counter.value}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 80,
                                          fontWeight:
                                              FontWeight.w900, // خط سميك جداً
                                          fontFamily:
                                              'Tajawal', // أو خط رقمي عصري
                                          shadows: [
                                            Shadow(
                                              blurRadius: 10.0,
                                              color: Colors.white54,
                                              offset: Offset(0, 0),
                                            ),
                                            Shadow(
                                              blurRadius: 20.0,
                                              color: Colors.blueAccent,
                                              offset: Offset(0, 0),
                                            ), // توهج أزرق
                                          ],
                                        ),
                                      )
                                      .animate(
                                        key: ValueKey(controller.counter.value),
                                      )
                                      .scale(
                                        duration: 200.ms,
                                        curve: Curves.easeOutCubic,
                                      )
                                      .then()
                                      .shake(
                                        duration: 500.ms,
                                        hz: 3,
                                        offset: const Offset(2, 0),
                                      ), // تأثير اهتزاز بسيط
                                  if (controller.targetCount.value != 0)
                                    Text(
                                      " / ${controller.targetCount.value}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 24,
                                        fontFamily: 'Tajawal',
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 5.0,
                                            color: Colors.black54,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate(delay: const Duration(milliseconds: 1000))
                        .fadeIn(duration: 800.ms)
                        .slide(begin: const Offset(0, 0.2), end: Offset.zero),
                  ),
                  const SizedBox(height: 80),
                  // زر تغيير الذكر
                  FadeInUp(
                    delay: const Duration(milliseconds: 1400),
                    child: ElevatedButton.icon(
                          onPressed:
                              () =>
                                  controller.showDhikrSelectionDialog(context),
                          icon: const Icon(
                            Icons.swap_horiz,
                            color: Colors.white,
                            size: 28,
                          ),
                          label: const Text(
                            "تغيير الذكر",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade700
                                .withOpacity(
                                  0.5,
                                ), // خلفية زر أغمق وأكثر تركيزاً
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: Colors.deepPurpleAccent.shade200,
                                width: 2,
                              ), // حدود متوهجة
                            ),
                            elevation: 10, // ظل بارز
                            shadowColor: Colors.deepPurpleAccent.withOpacity(
                              0.6,
                            ), // ظل يتناسب مع اللون
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: const Duration(seconds: 2),
                          color: Colors.white.withOpacity(0.3),
                        )
                        .scaleXY(
                          begin: 0.98,
                          end: 1.02,
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeInOutSine,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
