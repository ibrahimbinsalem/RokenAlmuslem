// lib/controllers/alrugi_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart'; // For IconData and UI elements in helper methods
import 'dart:ui';

import 'package:rokenalmuslem/data/database/database_helper.dart'; // For ImageFilter

class AlrugiController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Observable lists to hold the fetched ruqyahs
  final RxList<Map<String, dynamic>> quranicRuqyahs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> sunnahRuqyahs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadRuqyahs();
  }

  Future<void> _loadRuqyahs() async {
    try {
      final quranData = await _dbHelper.getRuqyahsByType('quran');
      final sunnahData = await _dbHelper.getRuqyahsByType('sunnah');
      quranicRuqyahs.assignAll(quranData);
      sunnahRuqyahs.assignAll(sunnahData);
      print('Quranic Ruqyahs loaded: ${quranicRuqyahs.length}');
      print('Sunnah Ruqyahs loaded: ${sunnahRuqyahs.length}');
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل الرقية: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
          colorText: Colors.white);
      print('Error loading Ruqyahs from DB: $e');
    }
  }

  // Method to show the modal bottom sheet
  void showRuqyahBottomSheet(BuildContext context, String title, List<Map<String, dynamic>> ruqyahList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            // Extract the 'text' string from each map
            final List<String> textsToShow = ruqyahList.map((r) => r['text'] as String).toList();
            return _buildBottomSheetContent(
              title: title,
              texts: textsToShow,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  // Helper widget for the modal bottom sheet content structure
  // هذه الدوال المساعدة (UI Helpers) موجودة هنا لأنها تستخدم context
  // ومن أجل التناسق مع بنية الكود السابق. في تطبيق أكبر، يمكن وضعها في ملف منفصل
  // أو كـ static methods في فئة مساعدة لـ UI.
  Widget _buildBottomSheetContent({
    required String title,
    required List<String> texts,
    ScrollController? scrollController,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10001C).withOpacity(0.9),
                const Color(0xFF2A0040).withOpacity(0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                _buildSectionTitle(title, isCentered: true),
                _buildElegantDivider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: texts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _buildContentCard(
                          texts[index],
                          fontSize: 18,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon, bool isCentered = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 25.0),
      child: Row(
        mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              title,
              textAlign: isCentered ? TextAlign.center : TextAlign.right,
              style: TextStyle(
                fontFamily: 'Tajawal',
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
          if (icon != null) ...[
            const SizedBox(width: 15),
            Icon(
              icon,
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

  Widget _buildContentCard(String content, {double fontSize = 18, bool isArabic = true}) {
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
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: fontSize,
              color: Colors.white.withOpacity(0.95),
              height: 1.7,
            ),
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
}