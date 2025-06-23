// lib/data/data/data_ayat.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:rokenalmuslem/data/data/data_translate.dart'; // Ensure this path is correct for QuranTranslate
// import 'package:rokenalmuslem/data/data/data_sajadah.dart'; // NO LONGER NEEDED for AyahData, this was for a different context

/// Represents a single Ayah (verse) from the Quran.
///
/// This class holds all relevant data for an Ayah, including its text,
/// numbering, and translation. It also provides methods for serialization
/// to and from JSON, which is crucial for local storage with Hive.
class AyahData {
  final int number; // Global ayah number
  final String text; // The Arabic text of the ayah
  final int numberInSurah; // Ayah number within its specific Surah
  final int juz; // Juz number
  // Manzil, page, ruku, hizbQuarter are common in this API.
  // I'm adding them back as they were in your initial AyahData model in the controller.
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;

  // IMPORTANT: Reverting sajda back to bool, as it is from the /v1/surah API.
  final bool sajda;
  
  QuranTranslate? translate; // Optional field for translations of the ayah

  AyahData({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.manzil, // Added back
    required this.page, // Added back
    required this.ruku, // Added back
    required this.hizbQuarter, // Added back
    required this.sajda, // Now bool
    this.translate, // Keep translate in constructor
  });

  /// Factory constructor to create an `AyahData` instance from a JSON map.
  factory AyahData.fromJSON(Map<String, dynamic> json) {
    debugPrint('AyahData.fromJSON: Starting deserialization for Ayah number ${json['number']}');
    
    // IMPORTANT: Handling 'sajda' as a boolean or a map with 'recommended' boolean
    final bool sajdaValue;
    if (json.containsKey('sajda') && json['sajda'] != null) {
      if (json['sajda'] is bool) {
        sajdaValue = json['sajda'] as bool;
        debugPrint('AyahData.fromJSON: Sajda is bool: $sajdaValue');
      } else if (json['sajda'] is Map) {
        // If it's a map, check for 'recommended' (common in alquran.cloud API for surah/ayahs)
        sajdaValue = json['sajda']['recommended'] ?? false;
        debugPrint('AyahData.fromJSON: Sajda is Map, recommended: $sajdaValue');
      } else {
        // Fallback for unexpected types
        sajdaValue = false;
        debugPrint('AyahData.fromJSON: Sajda has unexpected type (${json['sajda'].runtimeType}), defaulting to false.');
      }
    } else {
      sajdaValue = false; // Default to false if 'sajda' field is missing or null
      debugPrint('AyahData.fromJSON: Sajda field missing or null, defaulting to false.');
    }

    QuranTranslate? loadedTranslate;
    debugPrint('AyahData.fromJSON: Checking for "translate" field. Type: ${json['translate']?.runtimeType}');

    if (json['translate'] != null && json['translate'] is Map) {
      Map<String, String> tempTranslates = {};
      try {
        (json['translate'] as Map<String, dynamic>).forEach((keyString, value) {
          debugPrint('  Processing translate key: "$keyString", value: "$value", valueType: ${value.runtimeType}');
          if (value is String) {
            tempTranslates[keyString] = value;
            debugPrint('  Successfully added translation for key: "$keyString".');
          } else {
            debugPrint('  Warning: Translate value for "$keyString" is not a String. Type: ${value.runtimeType}. Skipping.');
          }
        });
      } catch (e) {
        debugPrint('Error processing translations map: $e');
      }

      if (tempTranslates.isNotEmpty) {
        loadedTranslate = QuranTranslate(translates: tempTranslates);
        debugPrint('AyahData.fromJSON: Successfully created QuranTranslate object with ${tempTranslates.length} translations.');
      } else {
        debugPrint('AyahData.fromJSON: No valid translations found for this Ayah.');
      }
    } else {
      debugPrint('AyahData.fromJSON: "translate" field is null or not a Map.');
    }

    debugPrint('AyahData.fromJSON: Deserialization complete for Ayah number ${json['number']}.');
    return AyahData(
      number: json['number'] as int,
      text: json['text'] as String,
      numberInSurah: json['numberInSurah'] as int,
      juz: json['juz'] as int,
      manzil: json['manzil'] as int, // Added back
      page: json['page'] as int, // Added back
      ruku: json['ruku'] as int, // Added back
      hizbQuarter: json['hizbQuarter'] as int, // Added back
      sajda: sajdaValue, // Now bool
      translate: loadedTranslate, // Assign the parsed translation object
    );
  }

  /// Converts the `AyahData` instance into a JSON-compatible map.
  Map<String, dynamic> toJSON() {
    return {
      'number': number,
      'text': text,
      'numberInSurah': numberInSurah,
      'juz': juz,
      'manzil': manzil, // Added back
      'page': page, // Added back
      'ruku': ruku, // Added back
      'hizbQuarter': hizbQuarter, // Added back
      'sajda': sajda, // Store as bool directly
      'translate': translate?.translates, // If no translation, store as null
    };
  }
}
