import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

import 'package:rokenalmuslem/controller/more/fadelaldekarcontroller.dart'; // For BackdropFilter

class FadelAlDkerView extends StatelessWidget {
  final FadelAlDkerController controller = Get.put(FadelAlDkerController());
  FadelAlDkerView({super.key});

  /// تبني عنوان القسم بخط مميز وأيقونة
  Widget _buildSectionTitle(
    String title, {
    IconData? icon,
    bool isCentered = false,
    Color color = const Color(0xFFFFD700), // Default golden color
    double fontSize = 24,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 25.0),
      child: Row(
        mainAxisAlignment:
            isCentered ? MainAxisAlignment.center : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              title,
              textAlign: isCentered ? TextAlign.center : TextAlign.right,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: color,
                shadows: [
                  BoxShadow(
                    color: color.withOpacity(0.7),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 15),
            Icon(
              icon,
              color: color,
              size: 32,
              shadows: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// يبني نصًا عامًا مع تنسيقات افتراضية
  Widget _buildGenericText(
    String text, {
    Color color = Colors.white,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.6,
  }) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: 'Amiri',
        fontWeight: fontWeight,
        height: height,
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  /// يبني فاصلًا
  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: Colors.white30, height: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FadelAlDkerController controller = Get.find();
    final double appBarHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'فضل الذكر',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Amiri',
            fontSize: 26,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10001C).withOpacity(0.7),
                    const Color(0xFF2A0040).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF10001C), Color(0xFF2A0040), Color(0xFF4D0060)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: appBarHeight + 10),
            _buildSectionTitle(
              "فضل الذكر في الإسلام",
              icon: Icons.lightbulb_outline, // أيقونة لمبة/فائدة
              isCentered: true,
            ),
            Expanded(
              child: Obx(() {
                if (controller.contentList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    left: 15,
                    right: 15,
                  ),
                  itemCount: controller.contentList.length,
                  itemBuilder: (context, index) {
                    final item = controller.contentList[index];
                    switch (item["type"]) {
                      case "intro_text":
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildGenericText(
                            item["content"]!,
                            fontSize: 18,
                          ),
                        );
                      case "subsection_title":
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: _buildGenericText(
                            item["content"]!,
                            color: Colors.amber[700]!,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      case "verse":
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: _buildGenericText(
                            "قال تعالى : ${item["content"]!}",
                            fontSize: 17,
                            height: 1.8,
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold, // لتبرز الآيات القرآنية
                          ),
                        );
                      case "hadith":
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: _buildGenericText(
                            item["content"]!,
                            fontSize: 17,
                            height: 1.8,
                            color: Colors.white,
                            fontWeight: FontWeight.bold, // لتبرز الأحاديث
                          ),
                        );
                      case "point_title":
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 20.0,
                            bottom: 10.0,
                          ),
                          child: _buildGenericText(
                            item["content"]!,
                            color: Colors.amber[700]!,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      case "point":
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: _buildGenericText(
                            "• ${item["content"]!}", // إضافة نقطة قبل كل فائدة
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        );
                      case "divider":
                        return _buildDivider();
                      default:
                        return const SizedBox.shrink(); // في حالة وجود نوع غير معروف
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
