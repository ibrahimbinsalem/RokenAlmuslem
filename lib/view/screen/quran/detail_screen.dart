import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/quran_controller.dart';
import 'package:rokenalmuslem/data/data/data_ayat.dart';
import 'package:rokenalmuslem/data/data/data_surat.dart';
import 'package:rokenalmuslem/data/data/translate_terjemah_indo.dart';

class SurahDetailPage extends StatefulWidget {
  final SurahData surah;

  const SurahDetailPage({Key? key, required this.surah}) : super(key: key);

  @override
  _SurahDetailPageState createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final QuranController quranController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      quranController.loadAyahsForSurah(widget.surah);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.surah.englishName,
          style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF046A38), Color(0xFF028A0F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (quranController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (quranController.currentAyahs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, size: 48, color: Colors.amber),
                SizedBox(height: 16),
                Text('لا توجد آيات متاحة', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      () => quranController.loadAyahsForSurah(widget.surah),
                  child: Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/Gemini_Generated_Image_cijwhucijwhucijw.png',
              ),
              fit: BoxFit.cover,
              opacity: 0.05,
            ),
          ),
          child: ListView(
            children: [
              // Surah Header
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF8F1E6),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      widget.surah.name,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 32,
                        color: Color(0xFF046A38),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${widget.surah.englishNameTranslation} (${widget.surah.englishName})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${widget.surah.revelationType} • ${widget.surah.numberOfAyahs} verses',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Ayahs List
              ...quranController.currentAyahs
                  .map((ayah) => _buildAyahItem(ayah))
                  .toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAyahItem(AyahData ayah) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              ayah.text,
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Amiri', fontSize: 24),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xFF046A38),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                quranController.convertToArabicNumber(
                  ayah.numberInSurah.toString(),
                ),
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              ayah.translate?.translates[TranslateID.indonesia] ?? '',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
