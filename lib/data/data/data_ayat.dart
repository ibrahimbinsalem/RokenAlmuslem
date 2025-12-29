// lib/data/data/data_ayat.dart
import 'dart:convert'; // Required for jsonEncode/jsonDecode if used within the model itself,
                      // though usually handled by controller, good to keep for completeness.
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:rokenalmuslem/data/data/data_translate.dart'; // Ensure this path is correct for QuranTranslate
import 'package:rokenalmuslem/data/data/data_sajadah.dart'; // New: Ensure this path is correct for DataSajadah

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
  // Removed manzil, page, ruku, hizbQuarter as per your last working model's constructor.
  // Add them back if they are actually used and required.
  // final int manzil;
  // final int page;
  // final int ruku;
  // final int hizbQuarter;

  final DataSajadah sajda; // Now explicitly DataSajadah type
  
  QuranTranslate? translate; // Optional field for translations of the ayah

  AyahData({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    // Add manzil, page, ruku, hizbQuarter back if they are part of your constructor logic
    // required this.manzil,
    // required this.page,
    // required this.ruku,
    // required this.hizbQuarter,
    required this.sajda,
    this.translate, // IMPORTANT: Add translate to the constructor
  });

  /// Factory constructor to create an `AyahData` instance from a JSON map.
  factory AyahData.fromJSON(Map<String, dynamic> json) {
    // Ensure 'sajda' exists and is a Map before parsing
    final DataSajadah sajdaValue = json.containsKey('sajda') && json['sajda'] != null
        ? DataSajadah.fromJSON(json['sajda'] as Map<String, dynamic>)
        : DataSajadah(isSajda: false, isRecommended: false, isObligatory: false, id: 0); // Provide a default/empty DataSajadah if null or missing

    QuranTranslate? loadedTranslate;

    if (json['translate'] != null && json['translate'] is Map) {
      Map<String, String> tempTranslates = {};
      try {
        (json['translate'] as Map<String, dynamic>).forEach((keyString, value) {
          if (value is String) {
            tempTranslates[keyString] = value;
          } else {
            debugPrint(
              'Translate value for "$keyString" is not a String. Type: ${value.runtimeType}. Skipping.',
            );
          }
        });
      } catch (e) {
        debugPrint('Error processing translations map: $e');
      }

      if (tempTranslates.isNotEmpty) {
        loadedTranslate = QuranTranslate(translates: tempTranslates);
      }
    }

    return AyahData(
      number: json['number'] as int,
      text: json['text'] as String,
      numberInSurah: json['numberInSurah'] as int,
      juz: json['juz'] as int,
      // manzil: json['manzil'] as int, // Uncomment if needed
      // page: json['page'] as int, // Uncomment if needed
      // ruku: json['ruku'] as int, // Uncomment if needed
      // hizbQuarter: json['hizbQuarter'] as int, // Uncomment if needed
      sajda: sajdaValue,
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
      // 'manzil': manzil, // Uncomment if needed
      // 'page': page, // Uncomment if needed
      // 'ruku': ruku, // Uncomment if needed
      // 'hizbQuarter': hizbQuarter, // Uncomment if needed
      'sajda': sajda.toJSON(),
      'translate': translate?.translates, // If no translation, store as null
    };
  }
}
