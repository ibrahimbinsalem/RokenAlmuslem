import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/quran_controller.dart';
import 'package:rokenalmuslem/data/data/data_surat.dart';
import 'package:rokenalmuslem/view/screen/quran/detail_screen.dart';

class LastReadPage extends StatelessWidget {
  final QuranController quranController = Get.find<QuranController>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'آخر قراءة',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 24,
            color: scheme.onPrimary,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: GetX<QuranController>(builder: (controller) {
        if (controller.lastReadSurahNumber.value == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book,
                  size: 64,
                  color: scheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد سجل للقراءة الأخيرة',
                  style: TextStyle(
                    fontSize: 18,
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        final surah = controller.surahs.firstWhere(
          (s) => s.number == controller.lastReadSurahNumber.value,
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
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () async {
                      await controller.loadAyahsForSurah(surah);
                      Get.to(() => SurahDetailPage(surah: surah));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        children: [
                          Text(
                            surah.name,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 28,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            surah.englishName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'آية رقم ${controller.lastReadPosition.value}',
                            style: TextStyle(
                              fontSize: 16,
                              color: scheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Icon(Icons.arrow_forward, color: scheme.primary),
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
