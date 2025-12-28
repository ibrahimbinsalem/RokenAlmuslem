// lib/views/tasbeeh_view.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import 'package:rokenalmuslem/controller/more/masbahacontroller.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class TasbeehView extends StatelessWidget {
  final TasbeehController controller = Get.put(TasbeehController());
  // الوصول إلى مثيل NotificationService
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  TasbeehView({Key? key}) : super(key: key);

  Color _getCounterColor(int current, int target) {
    final scheme = Get.theme.colorScheme;
    if (target == 0) return scheme.onSurface;
    double progress = current / target;

    Color startColor = scheme.primary.withOpacity(0.7);
    Color endColor = scheme.secondary.withOpacity(0.7);

    if (progress >= 1.0) {
      return scheme.secondary;
    }
    return Color.lerp(startColor, endColor, progress)!;
  }

  Future<void> _showReminderPicker(
    BuildContext context,
    ColorScheme scheme,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 21, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: scheme.copyWith(
              primary: scheme.primary,
              onPrimary: scheme.onPrimary,
              surface: scheme.surface,
              onSurface: scheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: scheme.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      _notificationService.scheduleDailyReminder(
        id: AppSettingsController.tasbeehReminderId,
        title: 'تذكير: وقت التسبيح',
        body: 'لا تنسَ التسبيح وذكر الله في هذا الوقت.',
        time: TimeOfDay(hour: pickedTime.hour, minute: pickedTime.minute),
        payload: 'tasbeeh_reminder',
      );
      Get.snackbar(
        'تم تفعيل التذكير',
        'ستتلقى تذكيرًا يوميًا للتسبيح في الساعة ${pickedTime.format(context)}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: scheme.primary.withOpacity(0.95),
        colorText: scheme.onPrimary,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } else {
      Get.snackbar(
        'إلغاء التفعيل',
        'لم يتم تحديد وقت لتذكير التسبيح.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: scheme.error.withOpacity(0.95),
        colorText: scheme.onError,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final double counterSize =
        math.min(MediaQuery.of(context).size.width * 0.7, 260).toDouble();

    return ModernScaffold(
      title: 'المسبحة',
      actions: [
        FadeInRight(
          delay: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.resetCounter,
            tooltip: 'إعادة تعيين',
          ),
        ),
        FadeInRight(
          delay: const Duration(milliseconds: 350),
          child: IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => controller.showTargetCountDialog(context),
            tooltip: 'تغيير الهدف',
          ),
        ),
      ],
      body: Stack(
        children: [
          Positioned(
            top: 80,
            left: 24,
            child: Icon(
                  Icons.auto_awesome,
                  color: scheme.secondary.withOpacity(0.12),
                  size: 46,
                )
                .animate(onPlay: (controller) => controller.repeat())
                .fade(duration: const Duration(seconds: 5))
                .scale(duration: const Duration(seconds: 4)),
          ),
          Positioned(
            bottom: 80,
            right: 24,
            child: Icon(
                  Icons.bubble_chart,
                  color: scheme.primary.withOpacity(0.12),
                  size: 54,
                )
                .animate(onPlay: (controller) => controller.repeat())
                .fade(
                  duration: const Duration(seconds: 6),
                  begin: 0.2,
                  end: 0.8,
                )
                .move(
                  begin: const Offset(10, 10),
                  end: const Offset(-10, -10),
                  duration: const Duration(seconds: 6),
                  curve: Curves.easeInOutSine,
                ),
          ),
          SafeArea(
            top: false,
            child: GetX<TasbeehController>(
              builder: (controller) {
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  children: [
                    FadeInDown(
                      delay: const Duration(milliseconds: 120),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: scheme.primary.withOpacity(0.18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "تسبيحات اليوم",
                              style: TextStyle(
                                color: scheme.onSurface.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "${controller.dailyTasbeehCount.value}",
                              style: TextStyle(
                                color: scheme.secondary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeInDown(
                      delay: const Duration(milliseconds: 220),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showReminderPicker(context, scheme),
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: const Text('تذكير التسبيح'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.secondary,
                            foregroundColor: scheme.onSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeInDown(
                      delay: const Duration(milliseconds: 500),
                      child: Text(
                            controller.currentDhikr.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: const Duration(seconds: 2),
                            color: scheme.secondary.withOpacity(0.35),
                          ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                            onTap: controller.incrementCounter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              width: counterSize,
                              height: counterSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _getCounterColor(
                                      controller.counter.value,
                                      controller.targetCount.value,
                                    ).withOpacity(0.95),
                                    scheme.surface.withOpacity(0.15),
                                  ],
                                  stops: const [0.0, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getCounterColor(
                                      controller.counter.value,
                                      controller.targetCount.value,
                                    ).withOpacity(0.35),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                                border: Border.all(
                                  color: _getCounterColor(
                                    controller.counter.value,
                                    controller.targetCount.value,
                                  ).withOpacity(0.5),
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                          "${controller.counter.value}",
                                          style: TextStyle(
                                            color: scheme.onSurface,
                                            fontSize: 64,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        )
                                        .animate(
                                          key: ValueKey(
                                            controller.counter.value,
                                          ),
                                        )
                                        .scale(
                                          duration: 200.ms,
                                          curve: Curves.easeOutCubic,
                                        ),
                                    if (controller.targetCount.value != 0)
                                      Text(
                                        " / ${controller.targetCount.value}",
                                        style: TextStyle(
                                          color: scheme.onSurface.withOpacity(
                                            0.6,
                                          ),
                                          fontSize: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .animate(delay: const Duration(milliseconds: 800))
                          .fadeIn(duration: 500.ms)
                          .slide(begin: const Offset(0, 0.1), end: Offset.zero),
                    ),
                    const SizedBox(height: 26),
                    FadeInUp(
                      delay: const Duration(milliseconds: 1000),
                      child: ElevatedButton.icon(
                            onPressed:
                                () =>
                                    controller.showDhikrSelectionDialog(
                                      context,
                                    ),
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('تغيير الذكر'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: const Duration(seconds: 2),
                            color: Colors.white.withOpacity(0.25),
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
