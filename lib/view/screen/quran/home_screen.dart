import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/quran_controller.dart';
import 'package:rokenalmuslem/view/screen/quran/detail_screen.dart';

class SurahListPage extends StatelessWidget {
  final QuranController quranController = Get.put(QuranController());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'القرآن الكريم',
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
        if (controller.isLoading.value) {
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
            itemCount: controller.surahs.length,
            itemBuilder: (context, index) {
              final surah = controller.surahs[index];
              return InkWell(
                onTap: () {
                  Get.to(() => SurahDetailPage(surah: surah));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          surah.number.toString(),
                          style: TextStyle(
                            color: scheme.onPrimary,
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
                            fontFamily: 'Amiri',
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${surah.englishNameTranslation} • ${surah.numberOfAyahs} verses',
                      style: TextStyle(
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: scheme.onSurface.withOpacity(0.5),
                    ),
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
