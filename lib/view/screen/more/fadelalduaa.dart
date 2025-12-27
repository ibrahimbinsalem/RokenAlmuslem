// lib/views/more/fadel_al_duaa_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/fadelaldekrcontroller.dart'; // استيراد GetX

class FadelAlDuaaPage extends StatelessWidget {
  const FadelAlDuaaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // تهيئة الكنترولر باستخدام Get.put
    final FadelAlDuaaGetXController controller = Get.put(FadelAlDuaaGetXController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "فضل الدعاء",
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: LinearGradient(
                colors: [
                  const Color(0xFF10001C).withOpacity(0.7),
                  const Color(0xFF2A0040).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).toBoxDecoration(),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF10001C),
              Color(0xFF2A0040),
              Color(0xFF4D0060),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadelAlDuaaContent(controller: controller), // تمرير الكنترولر
      ),
    );
  }
}

extension on LinearGradient {
  BoxDecoration toBoxDecoration() {
    return BoxDecoration(gradient: this);
  }
}

class FadelAlDuaaContent extends StatelessWidget {
  final FadelAlDuaaGetXController controller; // استلام الكنترولر

  const FadelAlDuaaContent({super.key, required this.controller});

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    switch (iconName) {
      case "lightbulb_outline": return Icons.lightbulb_outline;
      case "check_circle_outline": return Icons.check_circle_outline;
      case "self_improvement": return Icons.self_improvement;
      case "star_border": return Icons.star_border;
      case "gpp_good_outlined": return Icons.gpp_good_outlined;
      case "fitness_center_outlined": return Icons.fitness_center_outlined;
      case "shield_outlined": return Icons.shield_outlined;
      case "waving_hand": return Icons.waving_hand;
      case "mosque_rounded": return Icons.mosque_rounded;
      case "nightlight_round": return Icons.nightlight_round;
      case "people_outline": return Icons.people_outline;
      default: return null;
    }
  }

  Widget _buildSectionTitle(String title, {String? iconName}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFD700),
                shadows: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.7),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          if (iconName != null) ...[
            const SizedBox(width: 15),
            Icon(
              _getIconData(iconName),
              color: const Color(0xFFFFD700),
              size: 32,
              shadows: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.5),
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

  Widget _buildContentCard(String content) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            content,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: Colors.white.withOpacity(0.95),
              height: 1.7,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElegantDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        height: 3,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFFFD700).withOpacity(0.5),
              Colors.transparent,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;

    // استخدام Obx للاستماع إلى التغييرات في الكنترولر
    return Obx(() {
      if (controller.isLoading) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFFD700)),
          ),
        );
      }

      if (controller.duas.isEmpty) {
        return const Center(
          child: Text(
            "لا توجد بيانات لعرضها.",
            style: TextStyle(
              fontFamily: 'Amiri',
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        );
      }

      return ListView(
        padding: EdgeInsets.only(
          top: appBarHeight + 10,
          left: 25.0,
          right: 25.0,
          bottom: 25.0,
        ),
        children: [
          for (int i = 0; i < controller.duas.length; i++) ...[
            _buildSectionTitle(controller.duas[i]['title']!, iconName: controller.duas[i]['iconName']),
            _buildContentCard(controller.duas[i]['content']!),
            if (i < controller.duas.length - 1) _buildElegantDivider(),
          ],
          const SizedBox(height: 30),
        ],
      );
    });
  }
}