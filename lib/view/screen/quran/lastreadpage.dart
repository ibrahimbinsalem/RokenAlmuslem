import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/quran_controller.dart';
import 'package:rokenalmuslem/data/data/data_surat.dart';
import 'package:rokenalmuslem/view/screen/quran/detail_screen.dart';

class LastReadPage extends StatelessWidget {
  final QuranController quranController = Get.find<QuranController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'آخر قراءة',
          style: TextStyle(
            fontFamily: 'Uthmanic',
            fontSize: 24,
          ),
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
        if (quranController.lastReadSurahNumber.value == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لا يوجد سجل للقراءة الأخيرة',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final surah = quranController.surahs.firstWhere(
          (s) => s.number == quranController.lastReadSurahNumber.value,
          // orElse: () => SurahData.empty(),
        );

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/mosque_background.png'),
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'استمر من حيث توقفت',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await quranController.loadAyahsForSurah(surah);
                      Get.to(() => SurahDetailPage(surah: surah));
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        children: [
                          Text(
                            surah.name,
                            style: TextStyle(
                              fontFamily: 'Uthmanic',
                              fontSize: 28,
                              color: Color(0xFF046A38),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            surah.englishName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'آية رقم ${quranController.lastReadPosition.value}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          Icon(Icons.arrow_forward, color: Color(0xFF046A38)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}