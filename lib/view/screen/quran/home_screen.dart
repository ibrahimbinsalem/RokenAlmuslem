import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/quran_controller.dart';
import 'package:rokenalmuslem/view/screen/quran/detail_screen.dart';

class SurahListPage extends StatelessWidget {
  final QuranController quranController = Get.put(QuranController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'القرآن الكريم',
          style: TextStyle(fontFamily: 'Uthmanic', fontSize: 24),
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
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/Gemini_Generated_Image_cijwhucijwhucijw.png',
              ),
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),
          child: ListView.builder(
            itemCount: quranController.surahs.length,
            itemBuilder: (context, index) {
              final surah = quranController.surahs[index];
              return InkWell(
                onTap: () {
                  Get.to(() => SurahDetailPage(surah: surah));
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF046A38),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          surah.number.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          surah.englishName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Text(
                          surah.name,
                          style: TextStyle(
                            fontFamily: 'Uthmanic',
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${surah.englishNameTranslation} • ${surah.numberOfAyahs} verses',
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
