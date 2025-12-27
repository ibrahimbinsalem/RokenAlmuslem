import 'dart:math';
import 'dart:ui'; // For BackdropFilter and ImageFilter
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/qiblahcontroller.dart'; // تأكد من أن هذا المسار صحيح

class QiblaView extends GetView<QiblaController> {
  @override
  Widget build(BuildContext context) {
    QiblaController controller = Get.put(QiblaController());
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'بوصلة القبلة',
          style: TextStyle(
            fontFamily: 'Amiri',
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F1F2C),
              Color(0xFF283A4A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
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
                        color: Color(0xFF8DFFCD)
                            .withOpacity(0.8 + 0.2 * sin(value * pi)),
                        size: 80,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'تحديد موقعك الدقيق...',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'يرجى التأكد من تشغيل خدمات الموقع.',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 17,
                      color: Colors.white.withOpacity(0.6),
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
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off_rounded,
                      color: Color(0xFFFF7043),
                      size: 80,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      controller.errorMessage.value,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 21,
                        color: Color(0xFFFF7043),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF34E89E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 45,
                          vertical: 18,
                        ),
                        elevation: 10,
                        shadowColor: Color(0xFF34E89E).withOpacity(0.5),
                        overlayColor: Colors.white.withOpacity(0.2),
                      ),
                      onPressed: () {
                        controller.isLoading.value = true;
                        controller.errorMessage.value = '';
                        controller
                            .getCurrentLocation(); // تم تعديل اسم الدالة هنا
                      },
                      icon: const Icon(
                        Icons.cached,
                        color: Color(0xFF0F3443),
                        size: 24,
                      ),
                      label: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 19,
                          color: Color(0xFF0F3443),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // مؤشر العثور على القبلة - هذا هو الجزء الذي سيتم تحسينه كإشعار مرئي
              Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  // Padding ديناميكي لجعلها تتوسع/تنقبض
                  padding: EdgeInsets.symmetric(
                    vertical: controller.isFacingQibla.value ? 25 : 20,
                    horizontal: controller.isFacingQibla.value ? 40 : 35,
                  ),
                  decoration: BoxDecoration(
                    gradient: controller.isFacingQibla.value
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF8DFFCD),
                              Color(0xFF34E89E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [
                              Color(0xFF4A6572),
                              Color(0xFF34495E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: controller.isFacingQibla.value
                            ? Color(0xFF8DFFCD)
                                .withOpacity(0.8) // توهج أقوى عند مواجهة القبلة
                            : Colors.black.withOpacity(0.4),
                        blurRadius: controller.isFacingQibla.value ? 30 : 15,
                        offset: const Offset(0, 10),
                        spreadRadius:
                            controller.isFacingQibla.value ? 5 : 0, // انتشار التوهج
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedOpacity(
                        opacity: controller.isFacingQibla.value ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 400),
                        child: const Icon(
                          Icons.done_all_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: controller.isFacingQibla.value ? 15 : 0),
                      Text(
                        controller.isFacingQibla.value
                            ? 'أنت الآن تتجه للقبلة!'
                            : 'قم بتحريك جهازك نحو القبلة',
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 8.0,
                              color: Colors.black45,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // بوصلة القبلة - قرص ثابت ومؤشر متحرك
              Stack(
                alignment: Alignment.center,
                children: [
                  // Deep space background for the compass
                  Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFF1A2A3A),
                          Color(0xFF0F1F2C),
                        ],
                        stops: [0.3, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 40,
                          spreadRadius: 8,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                  ),
                  // Glowing outer ring (border)
                  Container(
                    width: 330,
                    height: 330,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFF34E89E).withOpacity(0.7),
                        width: 5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF34E89E).withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: -10,
                        ),
                      ],
                    ),
                  ),

                  // Compass Dial: Fixed lines and text (DOES NOT ROTATE WITH HEADING)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Major Degree Markers
                      ...List.generate(12, (index) {
                        double angle = index * 30.0;
                        return Transform.rotate(
                          angle: angle * pi / 180,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                width: 3,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: Color(0xFF8DFFCD).withOpacity(0.9),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF8DFFCD).withOpacity(0.7),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      // Minor Degree Markers
                      ...List.generate(36, (index) {
                        double angle = index * 10.0;
                        if (angle % 30 != 0) {
                          return Transform.rotate(
                            angle: angle * pi / 180,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                  width: 1.5,
                                  height: 15,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      // Cardinal Directions
                      _buildCompassDirection(
                        'شمال',
                        0,
                        glowColor: Color(0xFF8DFFCD),
                        isNorth: true,
                      ),
                      _buildCompassDirection('شرق', 90),
                      _buildCompassDirection('جنوب', 180),
                      _buildCompassDirection('غرب', 270),
                    ],
                  ),

                  // Qibla Pointer: A dynamic, glowing arrow (ROTATES BASED ON QIBLA - HEADING)
                  Obx(
                    () => Transform.rotate(
                      angle: (controller.qiblaDirection.value -
                              controller.heading.value) *
                          pi /
                          180,
                      alignment: Alignment.center,
                      child: CustomPaint(
                        painter: RadiantQiblaPointerPainter(
                          isFacingQibla: controller.isFacingQibla.value,
                        ),
                        size: const Size(220, 220),
                      ),
                    ),
                  ),

                  // Central Hub
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    width: controller.isFacingQibla.value ? 55 : 45,
                    height: controller.isFacingQibla.value ? 55 : 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          controller.isFacingQibla.value
                              ? Color(0xFF8DFFCD)
                              : Color(0xFF4A6572),
                          controller.isFacingQibla.value
                              ? Color(0xFF34E89E)
                              : Color(0xFF2C3E50),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: controller.isFacingQibla.value
                              ? Color(0xFF8DFFCD).withOpacity(0.8)
                              : Colors.black.withOpacity(0.4),
                          blurRadius: controller.isFacingQibla.value ? 30 : 15,
                          spreadRadius:
                              controller.isFacingQibla.value ? 5 : 0,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: controller.isFacingQibla.value ? 1.0 : 0.7,
                        child: Icon(
                          controller.isFacingQibla.value
                              ? Icons.mosque_rounded
                              : Icons.vpn_key_rounded,
                          color: Colors.white,
                          size: controller.isFacingQibla.value ? 30 : 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Information Panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Icons.alt_route_rounded,
                      title: 'اتجاه القبلة',
                      value:
                          '${controller.qiblaDirection.value.toStringAsFixed(1)}°',
                      color: Color(0xFF8DFFCD),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.latitude,
                            title: 'خط العرض',
                            value: controller.latitude.value.toStringAsFixed(4),
                            isCompact: true,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.longitude,
                            title: 'خط الطول',
                            value: controller.longitude.value.toStringAsFixed(
                              4,
                            ),
                            isCompact: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Helper widget to build compass directions with glow
  Widget _buildCompassDirection(
    String text,
    double angle, {
    Color? glowColor,
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
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: isNorth ? 15.0 : 8.0,
                  color: glowColor ?? Colors.white.withOpacity(0.5),
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // A more versatile info card widget
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    Color color = Colors.white,
    bool isCompact = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 15 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: isCompact
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 32),
                    const SizedBox(width: 15),
                    Text(
                      '$title: ',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Radiant Qibla Pointer Painter
class RadiantQiblaPointerPainter extends CustomPainter {
  final bool isFacingQibla;

  RadiantQiblaPointerPainter({required this.isFacingQibla});

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor =
        isFacingQibla ? const Color(0xFF8DFFCD) : const Color(0xFFFF5252);
    final accentColor =
        isFacingQibla ? const Color(0xFF34E89E) : const Color(0xFFD32F2F);

    final arrowPaint = Paint()
      ..shader = LinearGradient(
        colors: [baseColor, accentColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Arrowhead
    final Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2 - 25, size.height * 0.20)
      ..lineTo(size.width / 2 + 25, size.height * 0.20)
      ..close();

    canvas.drawPath(path, arrowPaint);

    // Arrow body
    final bodyRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.6),
      width: 15,
      height: size.height * 0.7,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, Radius.circular(5)),
      arrowPaint,
    );

    // Glow effect
    if (isFacingQibla) {
      final glowPaint = Paint()
        ..color = baseColor.withOpacity(0.8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 25.0);
      canvas.drawPath(path, glowPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, Radius.circular(5)),
        glowPaint,
      );
    }

    // Small indicator at the tip
    final tipPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.05), 5, tipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Placeholder for missing icons if Material 3 is not fully implemented or custom icons are needed
class Icons {
  static const IconData latitude = IconData(
    0xe0b7,
    fontFamily: 'MaterialIcons',
  );
  static const IconData longitude = IconData(
    0xe0b8,
    fontFamily: 'MaterialIcons',
  );
  static const IconData mosque_rounded = IconData(
    0xe472,
    fontFamily: 'MaterialIcons',
  );
  static const IconData vpn_key_rounded = IconData(
    0xe66e,
    fontFamily: 'MaterialIcons',
  );
  static const IconData sync_rounded = IconData(
    0xe577,
    fontFamily: 'MaterialIcons',
  );
  static const IconData location_off_rounded = IconData(
    0xe360,
    fontFamily: 'MaterialIcons',
  );
  static const IconData done_all_rounded = IconData(
    0xe231,
    fontFamily: 'MaterialIcons',
  );
  static const IconData alt_route_rounded = IconData(
    0xe07f,
    fontFamily: 'MaterialIcons',
  );
  static const IconData cached = IconData(0xe0b8, fontFamily: 'MaterialIcons');
}