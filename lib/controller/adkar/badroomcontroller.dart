// controller/adkar/adkar_alkhla_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Needed for Get.bottomSheet
import 'package:rokenalmuslem/data/database/database_helper.dart'; // Adjust path as needed

class AdkarAlkhlaController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // RxList to hold the dhikr items, using RxInt for 'count' to make it reactive
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  // Initial static list of Adkar Alkhla
  final List<Map<String, dynamic>> _initialStaticAdkar = [
    {
      "id": 1,
      "start": "الذكر عند الخلاء",
      "name": "(بِسْمِ الله) اللّهُـمَّ إِنِّـي أَعـوذُ بِـكَ مِـنَ الْخُـبْثِ وَالْخَبائِث. ",
      "ayah": "اذكار الخلاء",
      "meaning": "مرة واحدة",
      "count": 1
    },
    {
      "id": 2,
      "start": "الذكر بعد الخروج من الخلاء",
      "name": "غُفْـرانَك. ",
      "ayah": "اذكار الخلاء",
      "meaning": "مرة واحدة",
      "count": 1
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadAdkarFromDatabase();
  }

  Future<void> _loadAdkarFromDatabase() async {
    final List<Map<String, dynamic>> adkar = await _dbHelper.getAllDhikr(
      DatabaseHelper.adkarAlkhlaTableName, // Use the new table name
    );

    if (adkar.isEmpty) {
      print(
          "Database table '${DatabaseHelper.adkarAlkhlaTableName}' is empty. Inserting initial data...");
      // Insert initial data with initialCount and currentCount
      for (var dhikrData in _initialStaticAdkar) {
        await _dbHelper.insertDhikr(
          DatabaseHelper.adkarAlkhlaTableName, // Insert into the correct table
          {
            'id': dhikrData['id'],
            'start': dhikrData['start'],
            'name': dhikrData['name'],
            'ayah': dhikrData['ayah'],
            'meaning': dhikrData['meaning'],
            'initialCount': dhikrData['count'],
            'currentCount': dhikrData['count'],
          },
        );
      }
      // Reload data after insertion
      await _loadAdkarFromDatabase();
    } else {
      items.clear();
      for (var dbDhikr in adkar) {
        items.add({
          "id": dbDhikr['id'],
          "start": dbDhikr['start'],
          "name": dbDhikr['name'],
          "ayah": dbDhikr['ayah'],
          "meaning": dbDhikr['meaning'],
          "count": (dbDhikr['currentCount'] as int)
              .obs, // Make count reactive using .obs
        });
      }
      print(
          "Adkar loaded from database for '${DatabaseHelper.adkarAlkhlaTableName}'.");
    }
  }

  void decrementCount(int index) async {
    if (index >= 0 && index < items.length) {
      if (items[index]["count"].value > 0) {
        items[index]["count"].value--;
        await _dbHelper.updateDhikrCount(
          DatabaseHelper.adkarAlkhlaTableName, // Update in the correct table
          items[index]["id"] as int,
          items[index]["count"].value,
        );
      } else {
        Get.bottomSheet(
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.close_outlined,
                        color: Colors.greenAccent[400],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        "تم استكمال عدد مرات الذكر ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          isScrollControlled: true,
          enableDrag: true,
        );
      }
    }
  }

  void resetCount(int index) async {
    if (index >= 0 && index < items.length) {
      final int itemId = items[index]["id"] as int;
      await _dbHelper.resetDhikrCountToInitial(
        DatabaseHelper.adkarAlkhlaTableName, // Reset in the correct table
        itemId,
      );
      await _loadAdkarFromDatabase(); // Reload data after reset
    }
  }

  void resetAllCounters() async {
    await _dbHelper.resetAllDhikrCountsToInitial(
      DatabaseHelper.adkarAlkhlaTableName, // Reset all in the correct table
    );
    await _loadAdkarFromDatabase(); // Reload data after global reset
  }
}