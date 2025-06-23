// lib/controllers/adaya_quraniya_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:rokenalmuslem/data/database/database_helper.dart';

class AdayaQuraniyaController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  final RxList<Map<String, dynamic>> adayaList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadAdayaQuraniya();
  }

  Future<void> _loadAdayaQuraniya() async {
    try {
      final data = await _dbHelper.getAllAdayaQuraniya();
      // Ensure all maps loaded into adayaList are mutable copies
      adayaList.assignAll(
        data.map((item) => Map<String, dynamic>.from(item)).toList(),
      );
      print('Adaya Quraniya loaded: ${adayaList.length}');
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الأدعية القرآنية: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
      print('Error loading Adaya Quraniya from DB: $e');
    }
  }

  Future<void> updateDuaaCount(int id, int newCount) async {
    await _dbHelper.updateAdayaQuraniyaCount(id, newCount);
    final index = adayaList.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      // Create a mutable copy of the map before modifying it
      Map<String, dynamic> updatedItem = Map<String, dynamic>.from(
        adayaList[index],
      );
      updatedItem['currentCount'] = newCount;
      adayaList[index] = updatedItem; // Replace the old map with the new one
      adayaList.refresh(); // Notify listeners that the list item has changed
    }
  }

  Future<void> resetDuaaCountToInitial(int id) async {
    await _dbHelper.resetAdayaQuraniyaCountToInitial(id);
    // Reloading all data implicitly handles the mutability by creating new maps
    await _loadAdayaQuraniya();

    Get.snackbar(
      'إعادة تعيين',
      'تم إعادة تعيين عداد الدعاء إلى قيمته الأولية.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent.withOpacity(0.7),
      colorText: Colors.white,
    );
  }

  Future<void> resetAllDuaaCounts() async {
    await _dbHelper.resetAdayaQuraniyaCountToInitial(listeners);
    await _loadAdayaQuraniya(); // Reload all data to refresh counts
    Get.snackbar(
      'إعادة تعيين العدادات',
      'تم إعادة تعيين جميع عدادات الأدعية القرآنية إلى قيمها الأولية.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
    );
  }
}
