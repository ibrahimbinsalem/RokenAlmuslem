import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:rokenalmuslem/data/data/data_juz.dart';
import 'package:rokenalmuslem/data/data/data_surat.dart';
import 'package:rokenalmuslem/data/data/data_ayat.dart';

class QuranAPI {
  Future<SurahData> getSurahList() async {
    String url = "http://api.alquran.cloud/v1/quran/quran-uthmani";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return SurahData.fromJSON(json.decode(response.body));
    } else {
      print("Failed to load");
      throw Exception("Failed  to Load Post");
    }
  }

  Future<AyahData> getSajda() async {
    String url = "http://api.alquran.cloud/v1/sajda/quran-uthmani";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return AyahData.fromJSON(json.decode(response.body));
    } else {
      print("Failed to load");
      throw Exception("Failed  to Load Post");
    }
  }

  Future<JuzModel> getJuzz(int index) async {
    String url = "http://api.alquran.cloud/v1/juz/$index/quran-uthmani";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return JuzModel.fromJSON(json.decode(response.body));
    } else {
      print("Failed to load");
      throw Exception("Failed  to Load Post");
    }
  }
}
