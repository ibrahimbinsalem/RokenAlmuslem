
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AyahController extends GetxController {
  var ayahs = <Map<String, String>>[].obs;
  var currentAyah = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadQuran();
  }

  void loadQuran() async {
    try {
      String data = await rootBundle.loadString('assets/json/quran.json');
      List<dynamic> surahs = json.decode(data);
      List<Map<String, String>> allAyahs = [];
      for (var surah in surahs) {
        for (var ayah in surah['array']) {
          allAyahs.add({
            "ayah": ayah['ar'],
            "surah": surah['name'],
          });
        }
      }
      ayahs.value = allAyahs;
      setAyahOfDay();
    } catch (e) {
      print("Error loading Quran data: $e");
    }
  }

  void setAyahOfDay() {
    if (ayahs.isNotEmpty) {
      final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      currentAyah.value = ayahs[dayOfYear % ayahs.length];
    }
  }
}
