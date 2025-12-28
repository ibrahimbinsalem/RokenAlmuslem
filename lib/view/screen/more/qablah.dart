import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/qiblahcontroller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class QiblaView extends GetView<QiblaController> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QiblaController());
    final scheme = Theme.of(context).colorScheme;

    return ModernScaffold(
      title: 'بوصلة القبلة',
      body: GetX<QiblaController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 3),
                    curve: Curves.easeInOutSine,
                    builder: (context, value, child) => Transform.rotate(
                      angle: value * 4 * pi,
                      child: Icon(
                        Icons.sync_rounded,
                        color: scheme.primary
                            .withOpacity(0.7 + 0.2 * sin(value * pi)),
                        size: 70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'تحديد موقعك الدقيق...',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'يرجى التأكد من تشغيل خدمات الموقع.',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 15,
                      color: scheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      color: scheme.error,
                      size: 72,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      controller.errorMessage.value,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        color: scheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        controller.isLoading.value = true;
                        controller.errorMessage.value = '';
                        controller.getCurrentLocation();
                      },
                      icon: const Icon(Icons.cached, size: 22),
                      label: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildFacingIndicator(controller, scheme),
              const SizedBox(height: 24),
              Center(child: _buildCompass(controller, scheme)),
              const SizedBox(height: 24),
              _buildInfoCard(
                icon: Icons.explore,
                title: 'اتجاه القبلة',
                value: '${controller.qiblaDirection.value.toStringAsFixed(1)}°',
                scheme: scheme,
                highlight: scheme.secondary,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.public,
                      title: 'خط العرض',
                      value: controller.latitude.value.toStringAsFixed(4),
                      scheme: scheme,
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.place,
                      title: 'خط الطول',
                      value: controller.longitude.value.toStringAsFixed(4),
                      scheme: scheme,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFacingIndicator(
    QiblaController controller,
    ColorScheme scheme,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      padding: EdgeInsets.symmetric(
        vertical: controller.isFacingQibla.value ? 18 : 16,
        horizontal: controller.isFacingQibla.value ? 28 : 22,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: controller.isFacingQibla.value
              ? [scheme.primary, scheme.secondary]
              : [
                  scheme.surface.withOpacity(0.9),
                  scheme.surface.withOpacity(0.7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: controller.isFacingQibla.value
                ? scheme.primary.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            opacity: controller.isFacingQibla.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.done_all_rounded,
              color: scheme.onPrimary,
              size: 26,
            ),
          ),
          SizedBox(width: controller.isFacingQibla.value ? 10 : 0),
          Text(
            controller.isFacingQibla.value
                ? 'أنت الآن تتجه للقبلة!'
                : 'قم بتحريك جهازك نحو القبلة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: controller.isFacingQibla.value
                  ? scheme.onPrimary
                  : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass(QiblaController controller, ColorScheme scheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                scheme.surface.withOpacity(0.95),
                scheme.background.withOpacity(0.9),
              ],
              stops: const [0.3, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: scheme.primary.withOpacity(0.7),
              width: 4,
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(12, (index) {
              double angle = index * 30.0;
              return Transform.rotate(
                angle: angle * pi / 180,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Container(
                      width: 3,
                      height: 22,
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.7),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withOpacity(0.35),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            ...List.generate(36, (index) {
              double angle = index * 10.0;
              if (angle % 30 != 0) {
                return Transform.rotate(
                  angle: angle * pi / 180,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Container(
                        width: 1.5,
                        height: 14,
                        color: scheme.onSurface.withOpacity(0.35),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            _buildCompassDirection('شمال', 0, scheme: scheme, isNorth: true),
            _buildCompassDirection('شرق', 90, scheme: scheme),
            _buildCompassDirection('جنوب', 180, scheme: scheme),
            _buildCompassDirection('غرب', 270, scheme: scheme),
          ],
        ),
        Transform.rotate(
          angle:
              (controller.qiblaDirection.value - controller.heading.value) *
              pi /
              180,
          alignment: Alignment.center,
          child: CustomPaint(
            painter: RadiantQiblaPointerPainter(
              isFacingQibla: controller.isFacingQibla.value,
              scheme: scheme,
            ),
            size: const Size(210, 210),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          width: controller.isFacingQibla.value ? 52 : 44,
          height: controller.isFacingQibla.value ? 52 : 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: controller.isFacingQibla.value
                  ? [scheme.primary, scheme.secondary]
                  : [
                      scheme.surface.withOpacity(0.9),
                      scheme.surface.withOpacity(0.7),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(
                  controller.isFacingQibla.value ? 0.35 : 0.15,
                ),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: controller.isFacingQibla.value ? 1.0 : 0.7,
              child: Icon(
                controller.isFacingQibla.value
                    ? Icons.navigation
                    : Icons.explore,
                color: scheme.onPrimary,
                size: controller.isFacingQibla.value ? 26 : 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompassDirection(
    String text,
    double angle, {
    required ColorScheme scheme,
    bool isNorth = false,
  }) {
    return Transform.rotate(
      angle: angle * pi / 180,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: isNorth ? 20 : 18,
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
              shadows: [
                Shadow(
                  blurRadius: isNorth ? 15.0 : 8.0,
                  color: (isNorth ? scheme.secondary : scheme.primary)
                      .withOpacity(0.45),
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required ColorScheme scheme,
    Color? highlight,
    bool isCompact = false,
  }) {
    final accent = highlight ?? scheme.primary;
    return Container(
      padding: EdgeInsets.all(isCompact ? 14 : 18),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: isCompact
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: accent, size: 26),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: scheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: accent, size: 28),
                const SizedBox(width: 12),
                Text(
                  '$title: ',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    color: scheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
    );
  }
}

class RadiantQiblaPointerPainter extends CustomPainter {
  final bool isFacingQibla;
  final ColorScheme scheme;

  RadiantQiblaPointerPainter({
    required this.isFacingQibla,
    required this.scheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isFacingQibla ? scheme.primary : scheme.error;
    final accentColor = isFacingQibla ? scheme.secondary : scheme.error;

    final arrowPaint = Paint()
      ..shader = LinearGradient(
        colors: [baseColor, accentColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2 - 25, size.height * 0.20)
      ..lineTo(size.width / 2 + 25, size.height * 0.20)
      ..close();

    canvas.drawPath(path, arrowPaint);

    final bodyRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.6),
      width: 15,
      height: size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(5)),
      arrowPaint,
    );

    if (isFacingQibla) {
      final glowPaint = Paint()
        ..color = baseColor.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25.0);
      canvas.drawPath(path, glowPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(5)),
        glowPaint,
      );
    }

    final tipPaint = Paint()
      ..color = scheme.onSurface.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.05), 5, tipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
