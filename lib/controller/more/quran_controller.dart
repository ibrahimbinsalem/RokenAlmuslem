// lib/controllers/quran_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart'; // For WidgetsBinding
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rokenalmuslem/data/data/data_ayat.dart';
import 'package:rokenalmuslem/data/data/data_sajadah.dart';
import 'package:rokenalmuslem/data/data/data_surat.dart';
import 'package:rokenalmuslem/data/data/data_translate.dart';
import 'package:http/http.dart' as http;
import 'package:rokenalmuslem/data/data/translate_terjemah_indo.dart'; // Make sure http is imported

class QuranController extends GetxController {
  var surahs = <SurahData>[].obs;
  var currentAyahs = <AyahData>[].obs;
  var isLoading = true.obs;
  var selectedSurah = Rxn<SurahData>(); // SurahData?
  var lastReadPosition = 0.obs; // لآية رقم في السورة
  var lastReadSurahNumber = 0.obs; // لرقم السورة

  late Box quranDataBox; // لتخزين بيانات القرآن
  late Box quranSettingsBox; // لإعدادات المستخدم

  @override
  void onInit() {
    super.onInit();
    debugPrint("QuranController onInit: Initializing boxes.");
    quranDataBox = Hive.box('quranData');
    quranSettingsBox = Hive.box('quranSettings');

    // Crucial change: Schedule _loadInitialData to run AFTER the current frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  // --- وظائف جلب البيانات من API ---
  Future<List<AyahData>> gettingAyahs(SurahData surahData) async {
    debugPrint("API Call: fetching ayahs for Surah ${surahData.number}");
    try {
      var surahNum = surahData.number;
      String url = "http://api.alquran.cloud/v1/surah/$surahNum";
      String translateUrl = url + "/id.indonesian";

      debugPrint("Fetching Ayahs from: $url");
      final result = await http.get(Uri.parse(url));
      debugPrint("Fetching Translation from: $translateUrl");
      final resultTranslate = await http.get(Uri.parse(translateUrl));

      if (result.statusCode != 200) {
        throw Exception(
          "Failed to load ayahs: HTTP ${result.statusCode} - ${result.body}",
        );
      }
      if (resultTranslate.statusCode != 200) {
        throw Exception(
          "Failed to load translations: HTTP ${resultTranslate.statusCode} - ${resultTranslate.body}",
        );
      }

      final data = jsonDecode(result.body)['data'];
      final dataTranslate = jsonDecode(resultTranslate.body)['data'];

      if (data == null || data['ayahs'] == null) {
        throw Exception("Ayahs data is null or malformed from main API.");
      }
      if (dataTranslate == null || dataTranslate['ayahs'] == null) {
        throw Exception(
          "Translation data is null or malformed from translation API.",
        );
      }

      final ayahsData = data['ayahs'] as List<dynamic>;
      final ayahsTranslateData = dataTranslate['ayahs'] as List<dynamic>;

      List<AyahData> finalAyahs = [];
      for (var ayahI = 0; ayahI < ayahsData.length; ayahI++) {
        var ayahJson = ayahsData[ayahI] as Map<String, dynamic>;
        String translationText = '';
        if (ayahI < ayahsTranslateData.length &&
            ayahsTranslateData[ayahI] != null) {
          translationText = ayahsTranslateData[ayahI]['text'] ?? '';
        }

        final surahTranslates = QuranTranslate(
          translates: {TranslateID.indonesia: translationText},
        );

        try {
          final ayahData = AyahData.fromJSON(ayahJson);
          ayahData.translate = surahTranslates;
          finalAyahs.add(ayahData);
        } catch (e, s) {
          debugPrint(
            "Error parsing Ayah ${ayahJson['number'] ?? 'unknown'} in gettingAyahs: $e\n$s",
          );
          debugPrint("Problematic Ayah JSON: ${jsonEncode(ayahJson)}");
          // Continue loop even if one ayah fails, but log the error
        }
      }
      debugPrint(
        "API Call Success: Fetched and processed ${finalAyahs.length} ayahs for Surah ${surahData.number}",
      );
      return finalAyahs;
    } catch (e, s) {
      debugPrint("API Call Error in gettingAyahs (Outer Catch): $e\n$s");
      throw Exception("Failed to get ayahs from API: $e");
    }
  }

  Future<List<SurahData>> getQuranOnline() async {
    debugPrint("API Call: fetching all surahs.");
    try {
      final response = await http.get(
        Uri.parse("https://api.alquran.cloud/v1/surah"),
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Failed to load surahs: HTTP ${response.statusCode} - ${response.body}",
        );
      }

      var jsonBody = jsonDecode(response.body);
      var data = jsonBody['data'] as List<dynamic>;

      if (data == null) {
        throw Exception("Surahs data is null or malformed from API.");
      }

      var surahDatas = <SurahData>[];
      for (var element in data) {
        try {
          surahDatas.add(SurahData.fromJSON(element as Map<String, dynamic>));
        } catch (e, s) {
          debugPrint(
            "Error parsing Surah ${element['number'] ?? 'unknown'} in getQuranOnline: $e\n$s",
          );
          debugPrint("Problematic Surah JSON: ${jsonEncode(element)}");
        }
      }
      debugPrint("API Call Success: Fetched ${surahDatas.length} surahs.");
      return surahDatas;
    } catch (e, s) {
      debugPrint("API Call Error in getQuranOnline (Outer Catch): $e\n$s");
      throw Exception("Failed to get surahs from API: $e");
    }
  }
  // ---------------------------------------------

  // --- وظائف التخزين المحلي ---
  Future<void> _loadInitialData() async {
    isLoading(true);
    debugPrint("_loadInitialData: Attempting to load initial data.");
    try {
      if (quranDataBox.containsKey('allSurahs')) {
        var cachedSurahsJson = quranDataBox.get('allSurahs');
        if (cachedSurahsJson != null) {
          debugPrint(
            "loadInitialData: Found cached surahs in Hive. Length: ${cachedSurahsJson.length} chars.",
          );
          try {
            surahs.value =
                (jsonDecode(cachedSurahsJson) as List)
                    .map((e) => SurahData.fromJSON(e as Map<String, dynamic>))
                    .toList();
            debugPrint(
              "loadInitialData: Loaded ${surahs.length} surahs from cache.",
            );
          } catch (e, s) {
            debugPrint(
              "loadInitialData: Error parsing cached surahs: $e\n$s. Clearing cache and fetching from API.",
            );
            await quranDataBox.delete('allSurahs');
            surahs.clear();
          }
        }
      }

      if (surahs.isEmpty) {
        final localSurahs = await _loadSurahsFromLocal();
        if (localSurahs.isNotEmpty) {
          surahs.value = localSurahs;
          await quranDataBox.put(
            'allSurahs',
            jsonEncode(localSurahs.map((s) => s.toJSON()).toList()),
          );
          debugPrint(
            "loadInitialData: Loaded ${surahs.length} surahs from local assets.",
          );
        }
      }

      lastReadSurahNumber.value =
          quranSettingsBox.get('lastReadSurahNumber') ?? 0;
      lastReadPosition.value = quranSettingsBox.get('lastReadPosition') ?? 0;
      debugPrint(
        "_loadInitialData: Last read position loaded - Surah: ${lastReadSurahNumber.value}, Ayah: ${lastReadPosition.value}",
      );
    } catch (e, s) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل البيانات الأولية: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Error in _loadInitialData (Outer Catch): $e\n$s');
    } finally {
      isLoading(false);
      debugPrint("_loadInitialData: Loading finished.");
    }
  }

  Future<void> loadAyahsForSurah(SurahData surahData) async {
    try {
      isLoading(true);
      selectedSurah.value = surahData;
      currentAyahs.clear();

      debugPrint("Loading ayahs for Surah: ${surahData.number}");

      // 1. محاولة التحميل من الكاش أولاً
      final cachedAyahs = await _loadAyahsFromCache(surahData.number);
      if (cachedAyahs != null && cachedAyahs.isNotEmpty) {
        debugPrint("Loaded ${cachedAyahs.length} ayahs from cache.");
        currentAyahs.assignAll(cachedAyahs);
        return;
      }

      // 2. تحميل البيانات من الملف المحلي
      final localAyahs = await _loadAyahsFromLocal(surahData.number);
      if (localAyahs.isEmpty) {
        throw Exception("Local data returned empty ayahs list");
      }

      currentAyahs.assignAll(localAyahs);
      await _cacheAyahs(surahData.number, localAyahs);
      debugPrint("Successfully loaded ${localAyahs.length} ayahs from local.");
    } catch (e, stack) {
      debugPrint("Error loading ayahs: $e\n$stack");
      final fallbackAyahs = await _loadAyahsFromCache(surahData.number);
      if (fallbackAyahs != null && fallbackAyahs.isNotEmpty) {
        debugPrint("Falling back to cached ayahs after local failure.");
        currentAyahs.assignAll(fallbackAyahs);
      } else {
        currentAyahs.clear();
      }
      if (currentAyahs.isEmpty) {
        Get.snackbar('خطأ', 'حدث خطأ في تحميل الآيات');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<List<AyahData>> _fetchAyahsFromAPI(SurahData surahData) async {
    try {
      final surahNumber = surahData.number;
      final arabicUrl =
          "https://api.alquran.cloud/v1/surah/$surahNumber/quran-uthmani";

      debugPrint("Fetching Arabic text from: $arabicUrl");

      final arabicResponse = await http.get(Uri.parse(arabicUrl));
      if (arabicResponse.statusCode != 200) {
        throw Exception(
          "API request failed: HTTP ${arabicResponse.statusCode}",
        );
      }

      final arabicJson =
          jsonDecode(arabicResponse.body)['data']['ayahs'] as List;

      return List.generate(arabicJson.length, (index) {
        final arabicAyah = arabicJson[index] as Map<String, dynamic>;
        final sajdaValue = arabicAyah['sajda'];
        final sajda =
            DataSajadah.fromJSON(sajdaValue ?? false);

        return AyahData(
          juz: arabicAyah['juz'] as int,
          sajda: sajda,
          number: arabicAyah['number'] as int,
          text: arabicAyah['text'] as String,
          numberInSurah: arabicAyah['numberInSurah'] as int,
        );
      });
    } catch (e, stack) {
      debugPrint("API fetch error: $e\n$stack");
      return [];
    }
  }

  Future<List<AyahData>?> _loadAyahsFromCache(int surahNumber) async {
    try {
      final surahKey = 'surah_${surahNumber}_ayahs';
      final cachedAyahsJson = quranDataBox.get(surahKey);
      if (cachedAyahsJson == null) return null;

      final decoded = jsonDecode(cachedAyahsJson) as List<dynamic>;
      return decoded
          .map((e) => AyahData.fromJSON(e as Map<String, dynamic>))
          .toList();
    } catch (e, s) {
      debugPrint("Error loading cached ayahs: $e\n$s");
      return null;
    }
  }

  Future<List<SurahData>> _loadSurahsFromLocal() async {
    try {
      final raw = await rootBundle.loadString('assets/json/quran.json');
      final data = jsonDecode(raw) as List<dynamic>;
      return data.map((e) {
        final item = e as Map<String, dynamic>;
        final ayahs = item['array'] as List<dynamic>? ?? [];
        return SurahData(
          number: item['id'] as int,
          name: item['name'] as String? ?? '',
          englishName: item['name_en'] as String? ?? '',
          englishNameTranslation: item['name_translation'] as String? ?? '',
          numberOfAyahs: ayahs.length,
          revelationType: item['type'] as String? ?? '',
        );
      }).toList();
    } catch (e, s) {
      debugPrint("Error loading local surahs: $e\n$s");
      return [];
    }
  }

  Future<List<AyahData>> _loadAyahsFromLocal(int surahNumber) async {
    try {
      final raw = await rootBundle.loadString('assets/json/quran.json');
      final data = jsonDecode(raw) as List<dynamic>;
      final surah = data
          .cast<Map<String, dynamic>>()
          .firstWhere((item) => item['id'] == surahNumber, orElse: () => {});
      if (surah.isEmpty) return [];

      final ayahs = surah['array'] as List<dynamic>? ?? [];
      return List.generate(ayahs.length, (index) {
        final ayah = ayahs[index] as Map<String, dynamic>;
        return AyahData(
          number: ayah['id'] as int,
          text: ayah['ar'] as String? ?? '',
          numberInSurah: index + 1,
          juz: 0,
          sajda: DataSajadah(
            id: 0,
            isSajda: false,
            isRecommended: false,
            isObligatory: false,
          ),
        );
      });
    } catch (e, s) {
      debugPrint("Error loading local ayahs: $e\n$s");
      return [];
    }
  }

  Future<void> _cacheAyahs(int surahNumber, List<AyahData> ayahs) async {
    try {
      final surahKey = 'surah_${surahNumber}_ayahs';
      await quranDataBox.put(
        surahKey,
        jsonEncode(ayahs.map((a) => a.toJSON()).toList()),
      );
      debugPrint("Ayahs cached successfully");
    } catch (e) {
      debugPrint("Error caching ayahs: $e");
    }
  }

  Future<void> saveLastReadPosition(int surahNumber, int ayahNumber) async {
    debugPrint(
      "Saving last read position: Surah $surahNumber, Ayah $ayahNumber",
    );
    try {
      await quranSettingsBox.put('lastReadSurahNumber', surahNumber);
      await quranSettingsBox.put('lastReadPosition', ayahNumber);
      lastReadSurahNumber.value = surahNumber;
      lastReadPosition.value = ayahNumber;
      debugPrint("Saved last read position successfully.");
    } catch (e) {
      debugPrint("Error saving last read position: $e");
    }
  }

  // --- وظائف مساعدة ---
  String removeBasmallahAtStart(AyahData ayahData) {
    if (ayahData.number > 1 &&
        ayahData.numberInSurah == 1 &&
        ayahData.number != 1236) {
      return ayahData.text.substring(39);
    } else {
      return ayahData.text;
    }
  }

  String convertToArabicNumber(String number) {
    String res = '';
    final arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (var element in number.characters) {
      if (int.tryParse(element) != null) {
        res += arabicNumbers[int.parse(element)];
      } else {
        debugPrint(
          "Warning: Non-numeric character found in convertToArabicNumber: $element",
        );
        res += element;
      }
    }
    return res;
  }

  /// Helper to clear all Hive data for debugging purposes.
  Future<void> clearAllQuranCache() async {
    debugPrint("Clearing all Quran data from Hive boxes...");
    await quranDataBox.clear();
    await quranSettingsBox.clear();
    surahs.clear();
    currentAyahs.clear();
    lastReadPosition.value = 0;
    lastReadSurahNumber.value = 0;
    debugPrint("Quran cache cleared. Reloading initial data.");
    // After clearing, re-trigger initial data load via post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }
}
