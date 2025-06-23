// lib/controllers/quran_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart'; // For WidgetsBinding
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
        Uri.parse("http://api.alquran.cloud/v1/surah"),
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
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل السور من API: $e',
        snackPosition: SnackPosition.BOTTOM,
      ); // Added snackbar for API error
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
        debugPrint("loadInitialData: Surahs list is empty, fetching from API.");
        final fetchedSurahs = await getQuranOnline();
        surahs.value = fetchedSurahs;
        await quranDataBox.put(
          'allSurahs',
          jsonEncode(fetchedSurahs.map((s) => s.toJSON()).toList()),
        );
        debugPrint(
          "loadInitialData: Fetched and cached ${surahs.length} surahs from API.",
        );
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

      // 1. جلب البيانات من API
      final fetchedAyahs = await _fetchAyahsFromAPI(surahData);

      // 2. التحقق من وجود بيانات
      if (fetchedAyahs.isEmpty) {
        throw Exception("API returned empty ayahs list");
      }

      // 3. تحديث القائمة
      currentAyahs.assignAll(fetchedAyahs);

      // 4. تخزين البيانات
      await _cacheAyahs(surahData.number, fetchedAyahs);

      debugPrint("Successfully loaded ${fetchedAyahs.length} ayahs");
    } catch (e, stack) {
      debugPrint("Error loading ayahs: $e\n$stack");
      currentAyahs.clear();
      Get.snackbar('خطأ', 'حدث خطأ في تحميل الآيات');
    } finally {
      isLoading(false);
    }
  }

  Future<List<AyahData>> _fetchAyahsFromAPI(SurahData surahData) async {
    try {
      final surahNumber = surahData.number;
      final arabicUrl =
          "http://api.alquran.cloud/v1/surah/$surahNumber/ar.alafasy";
      final translateUrl =
          "http://api.alquran.cloud/v1/surah/$surahNumber/id.indonesian";

      debugPrint("Fetching Arabic text from: $arabicUrl");
      debugPrint("Fetching translation from: $translateUrl");

      final [arabicResponse, translateResponse] = await Future.wait([
        http.get(Uri.parse(arabicUrl)),
        http.get(Uri.parse(translateUrl)),
      ]);

      if (arabicResponse.statusCode != 200 ||
          translateResponse.statusCode != 200) {
        throw Exception("API request failed");
      }

      final arabicJson =
          jsonDecode(arabicResponse.body)['data']['ayahs'] as List;
      final translateJson =
          jsonDecode(translateResponse.body)['data']['ayahs'] as List;

      return List.generate(arabicJson.length, (index) {
        final arabicAyah = arabicJson[index] as Map<String, dynamic>;
        final translatedAyah = translateJson[index] as Map<String, dynamic>;

        return AyahData(
          juz: surahData.number,
          sajda: DataSajadah(
            isSajda: false,
            isRecommended: false,
            isObligatory: false,
            id: 0,
          ),
          number: arabicAyah['number'] as int,
          text: arabicAyah['text'] as String, // النص العربي
          numberInSurah: arabicAyah['numberInSurah'] as int,
          translate: QuranTranslate(
            translates: {
              TranslateID.indonesia: translatedAyah['text'] as String,
            },
          ),
        );
      });
    } catch (e, stack) {
      debugPrint("API fetch error: $e\n$stack");
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
