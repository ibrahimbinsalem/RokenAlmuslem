// lib/controllers/quran_controller.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // For WidgetsBinding
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
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
  var isPrefetching = false.obs;
  var prefetchTotal = 0.obs;
  var prefetchDone = 0.obs;
  var isCacheComplete = false.obs;
  var prefetchError = ''.obs;
  var lastCachedSurahNumber = 0.obs;
  var reciters = <String, String>{}.obs;
  var selectedSurah = Rxn<SurahData>(); // SurahData?
  var lastReadPosition = 0.obs; // لآية رقم في السورة
  var lastReadSurahNumber = 0.obs; // لرقم السورة

  late Box quranDataBox; // لتخزين بيانات القرآن
  late Box quranSettingsBox; // لإعدادات المستخدم
  Map<String, Map<String, String>>? _recitersArabicCache;
  Map<String, Map<String, String>> _recitersMetaCache = {};

  @override
  void onInit() {
    super.onInit();
    debugPrint("QuranController onInit: Initializing boxes.");
    quranDataBox = Hive.box('quranData');
    quranSettingsBox = Hive.box('quranSettings');
    isCacheComplete.value = quranDataBox.get('quran_cache_complete') ?? false;
    prefetchDone.value = quranDataBox.get('quran_cache_count') ?? 0;
    lastCachedSurahNumber.value =
        quranDataBox.get('quran_cache_last_surah') ?? 0;

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
        Uri.parse("https://quranapi.pages.dev/api/surah.json"),
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Failed to load surahs: HTTP ${response.statusCode} - ${response.body}",
        );
      }

      var surahDatas = <SurahData>[];
      final data = jsonDecode(response.body) as List<dynamic>;
      for (var i = 0; i < data.length; i++) {
        final element = data[i] as Map<String, dynamic>;
        try {
          surahDatas.add(
            SurahData(
              number: i + 1,
              name: element['surahNameArabic'] as String? ?? '',
              englishName: element['surahName'] as String? ?? '',
              englishNameTranslation:
                  element['surahNameTranslation'] as String? ?? '',
              numberOfAyahs: element['totalAyah'] as int? ?? 0,
              revelationType: element['revelationPlace'] as String? ?? '',
            ),
          );
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
        debugPrint("loadInitialData: Surahs list is empty, fetching from API.");
        try {
          final fetchedSurahs = await getQuranOnline();
          surahs.value = fetchedSurahs;
          await quranDataBox.put(
            'allSurahs',
            jsonEncode(fetchedSurahs.map((s) => s.toJSON()).toList()),
          );
          debugPrint(
            "loadInitialData: Fetched and cached ${surahs.length} surahs from API.",
          );
        } catch (e, s) {
          debugPrint("API fetch failed, trying local data: $e\n$s");
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

      prefetchTotal.value = surahs.length;
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

  Future<void> prefetchAllSurahs({bool force = false}) async {
    if (isPrefetching.value) return;
    if (surahs.isEmpty) {
      await _loadInitialData();
    }
    if (surahs.isEmpty) return;

    final cachedCount = quranDataBox.get('quran_cache_count') ?? 0;
    if (!force && cachedCount >= surahs.length) {
      isCacheComplete.value = true;
      prefetchDone.value = cachedCount;
      prefetchTotal.value = surahs.length;
      return;
    }

    isPrefetching.value = true;
    prefetchError.value = '';
    prefetchTotal.value = surahs.length;
    var done = 0;

    for (final surah in surahs) {
      final surahKey = 'surah_${surah.number}_ayahs';
      if (!force && quranDataBox.containsKey(surahKey)) {
        done += 1;
        if (done == surahs.length || done % 3 == 0) {
          prefetchDone.value = done;
        }
        lastCachedSurahNumber.value = surah.number;
        await quranDataBox.put('quran_cache_last_surah', surah.number);
        continue;
      }

      try {
        final ayahs = await _fetchAyahsFromAPI(surah);
        if (ayahs.isNotEmpty) {
          await _cacheAyahs(surah.number, ayahs);
          done += 1;
          if (done == surahs.length || done % 3 == 0) {
            prefetchDone.value = done;
          }
          await quranDataBox.put('quran_cache_count', done);
          lastCachedSurahNumber.value = surah.number;
          await quranDataBox.put('quran_cache_last_surah', surah.number);
        }
      } catch (e, s) {
        debugPrint("Prefetch error for surah ${surah.number}: $e\n$s");
        prefetchError.value = 'تعذر تحميل بعض السور';
      }

      // Yield to the UI thread to avoid ANR on low-end devices.
      await Future.delayed(const Duration(milliseconds: 20));
    }

    if (done >= surahs.length) {
      isCacheComplete.value = true;
      await quranDataBox.put('quran_cache_complete', true);
    }

    isPrefetching.value = false;
  }

  Future<Map<String, String>> loadReciters({bool force = false}) async {
    try {
      final cached = quranSettingsBox.get('quran_reciters');
      if (!force && cached != null) {
        final arabicMap = await _loadRecitersArabicMap();
        final data = Map<String, dynamic>.from(jsonDecode(cached));
        reciters.value = data.map((key, value) {
          final name = value.toString();
          final translated =
              arabicMap[key]?['name'] ?? arabicMap[name]?['name'] ?? name;
          return MapEntry(key, translated);
        });
        _recitersMetaCache = _extractReciterMeta(arabicMap, data);
        return reciters;
      }

      if (force && cached != null) {
        await quranSettingsBox.delete('quran_reciters');
      }

      final arabicMap = await _loadRecitersArabicMap();
      final response = await http.get(
        Uri.parse("https://quranapi.pages.dev/api/reciters.json"),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to load reciters");
      }

      final data = Map<String, dynamic>.from(jsonDecode(response.body));
      reciters.value = data.map((key, value) {
        final name = value.toString();
        final translated =
            arabicMap[key]?['name'] ?? arabicMap[name]?['name'] ?? name;
        return MapEntry(key, translated);
      });
      _recitersMetaCache = _extractReciterMeta(arabicMap, data);
      await quranSettingsBox.put('quran_reciters', jsonEncode(reciters));
      return reciters;
    } catch (e, s) {
      debugPrint("Reciters load error: $e\n$s");
      return reciters;
    }
  }

  Map<String, String>? getReciterMeta(String reciterId) {
    return _recitersMetaCache[reciterId];
  }

  Future<Map<String, String>?> getReciterMetaAsync({
    required String reciterId,
    String? reciterName,
  }) async {
    final cached = _recitersMetaCache[reciterId];
    if (cached != null) return cached;
    final arabicMap = await _loadRecitersArabicMap();
    final meta = arabicMap[reciterId] ?? arabicMap[reciterName ?? ''];
    if (meta != null) {
      _recitersMetaCache[reciterId] = meta;
    }
    return meta;
  }

  Future<String?> getAudioUrl(int surahNumber, String reciterId) async {
    final cacheKey = 'audio_${surahNumber}_$reciterId';
    final cached = quranDataBox.get(cacheKey);
    if (cached != null) return cached.toString();

    try {
      final response = await http
          .get(Uri.parse("https://quranapi.pages.dev/api/$surahNumber.json"))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final url = await compute(
        _extractAudioUrlFromJson,
        {'body': response.body, 'reciterId': reciterId},
      );
      if (url != null) {
        await quranDataBox.put(cacheKey, url);
      }
      return url;
    } catch (e, s) {
      debugPrint("Audio url fetch error: $e\n$s");
      return null;
    }
  }

  Future<String?> getDownloadedAudioPath(
    int surahNumber,
    String reciterId,
  ) async {
    final key = 'audio_file_${surahNumber}_$reciterId';
    final cachedPath = quranDataBox.get(key);
    if (cachedPath == null) return null;
    final file = File(cachedPath.toString());
    if (await file.exists()) return file.path;
    return null;
  }

  Future<String?> downloadAudio(
    int surahNumber,
    String reciterId, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final url = await getAudioUrl(surahNumber, reciterId);
      if (url == null || url.isEmpty) return null;

      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory(path.join(dir.path, 'quran_audio'));
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      final filePath =
          path.join(audioDir.path, 'surah_${surahNumber}_$reciterId.mp3');

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      await dio.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
      );

      await quranDataBox.put(
        'audio_file_${surahNumber}_$reciterId',
        filePath,
      );
      return filePath;
    } catch (e, s) {
      debugPrint("Audio download error: $e\n$s");
      return null;
    }
  }

  Future<String?> getTafsir(int surahNumber, int ayahNumber) async {
    final cacheKey = 'tafsir_${surahNumber}_$ayahNumber';
    final cached = quranDataBox.get(cacheKey);
    if (cached != null) return cached.toString();

    try {
      final response = await http.get(
        Uri.parse(
          "https://quranapi.pages.dev/api/tafsir/${surahNumber}_$ayahNumber.json",
        ),
      );
      if (response.statusCode != 200) return null;

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final tafsirs = payload['tafsirs'] as List<dynamic>? ?? [];
      if (tafsirs.isEmpty) return null;

      final buffer = StringBuffer();
      for (final item in tafsirs) {
        final data = item as Map<String, dynamic>;
        final author = data['author']?.toString() ?? 'تفسير';
        final content = data['content']?.toString() ?? '';
        if (content.trim().isEmpty) continue;
        buffer.writeln('$author:\n$content');
        buffer.writeln('\n');
      }

      final result = buffer.toString().trim();
      if (result.isNotEmpty) {
        await quranDataBox.put(cacheKey, result);
      }
      return result.isNotEmpty ? result : null;
    } catch (e, s) {
      debugPrint("Tafsir fetch error: $e\n$s");
      return null;
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

      // 2. جلب البيانات من API (Quran API)
      final fetchedAyahs = await _fetchAyahsFromAPI(surahData);
      if (fetchedAyahs.isNotEmpty) {
        currentAyahs.assignAll(fetchedAyahs);
        await _cacheAyahs(surahData.number, fetchedAyahs);
        debugPrint(
          "Successfully loaded ${fetchedAyahs.length} ayahs from API.",
        );
        return;
      }

      // 3. تحميل البيانات من الملف المحلي
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
          "https://quranapi.pages.dev/api/$surahNumber.json";

      debugPrint("Fetching Arabic text from: $arabicUrl");

      final arabicResponse = await http.get(Uri.parse(arabicUrl));
      if (arabicResponse.statusCode != 200) {
        throw Exception(
          "API request failed: HTTP ${arabicResponse.statusCode}",
        );
      }

      final payload = jsonDecode(arabicResponse.body) as Map<String, dynamic>;
      final arabicAyahs = payload['arabic1'] as List<dynamic>? ?? [];

      final baseNumber = _getGlobalAyahOffset(surahNumber);
      return List.generate(arabicAyahs.length, (index) {
        return AyahData(
          juz: 0,
          sajda: DataSajadah(
            id: 0,
            isSajda: false,
            isRecommended: false,
            isObligatory: false,
          ),
          number: baseNumber + index + 1,
          text: arabicAyahs[index] as String? ?? '',
          numberInSurah: index + 1,
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

  int _getGlobalAyahOffset(int surahNumber) {
    if (surahs.isEmpty) return 0;
    var offset = 0;
    for (var i = 0; i < surahs.length; i++) {
      if (surahs[i].number == surahNumber) {
        return offset;
      }
      offset += surahs[i].numberOfAyahs;
    }
    return offset;
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

  void saveLastAudioPlay(int surahNumber, String reciterId) {
    quranSettingsBox.put('last_audio_surah', surahNumber);
    quranSettingsBox.put('last_audio_reciter', reciterId);
  }

  void saveAudioDuration(
    int surahNumber,
    String reciterId,
    Duration duration,
  ) {
    if (duration.inSeconds <= 0) return;
    quranSettingsBox.put(
      'audio_duration_${surahNumber}_$reciterId',
      duration.inSeconds,
    );
  }

  Duration? getAudioDuration(int surahNumber, String reciterId) {
    final value = quranSettingsBox.get(
      'audio_duration_${surahNumber}_$reciterId',
    );
    if (value is int && value > 0) {
      return Duration(seconds: value);
    }
    if (value is num && value > 0) {
      return Duration(seconds: value.toInt());
    }
    return null;
  }

  int? getLastAudioSurah() {
    final value = quranSettingsBox.get('last_audio_surah');
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  String? getLastAudioReciter() {
    final value = quranSettingsBox.get('last_audio_reciter');
    return value?.toString();
  }

  Future<Map<String, Map<String, String>>> _loadRecitersArabicMap() async {
    if (_recitersArabicCache != null) return _recitersArabicCache!;
    try {
      final raw = await rootBundle.loadString('assets/json/reciters_ar.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _recitersArabicCache = data.map((key, value) {
        if (value is Map<String, dynamic>) {
          return MapEntry(
            key.toString(),
            value.map((k, v) => MapEntry(k.toString(), v.toString())),
          );
        }
        if (value is Map) {
          return MapEntry(
            key.toString(),
            value.map((k, v) => MapEntry(k.toString(), v.toString())),
          );
        }
        return MapEntry(key.toString(), {'name': value.toString()});
      });
      return _recitersArabicCache!;
    } catch (e, s) {
      debugPrint("Reciters arabic map load error: $e\n$s");
      return {};
    }
  }

  Map<String, Map<String, String>> _extractReciterMeta(
    Map<String, Map<String, String>> arabicMap,
    Map<String, dynamic> apiMap,
  ) {
    final meta = <String, Map<String, String>>{};
    for (final entry in apiMap.entries) {
      final key = entry.key;
      final name = entry.value.toString();
      final metaByKey = arabicMap[key];
      final metaByName = arabicMap[name];
      final selected = metaByKey ?? metaByName;
      if (selected != null) {
        meta[key] = selected;
      }
    }
    return meta;
  }
}

String? _extractAudioUrlFromJson(Map<String, String> args) {
  final payload = jsonDecode(args['body'] ?? '') as Map<String, dynamic>;
  final reciterId = args['reciterId'] ?? '';
  final audio = payload['audio'] as Map<String, dynamic>? ?? {};
  final entry = audio[reciterId] as Map<String, dynamic>? ?? {};
  return entry['url']?.toString() ?? entry['originalUrl']?.toString();
}
