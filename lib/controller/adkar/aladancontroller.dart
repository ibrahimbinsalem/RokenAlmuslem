// controller/adkar/adkar_aladan_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart'; // نحتاجها للـ BottomSheet
import 'package:rokenalmuslem/data/database/database_helper.dart'; // تأكد من المسار الصحيح لقاعدة البيانات

class AdkarAladanController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // RxList لحفظ الأذكار التي سيتم عرضها، مع RxInt لـ 'count' لتمكين التفاعلية
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  // قائمة الأذكار الأولية الثابتة لأذكار الأذان
  final List<Map<String, dynamic>> _initialStaticAdkar = [
    {
      "id": 1,
      "start": "ما يقال عند سماع الأذان",
      "name":
          "يَقُولُ مِثْلَ مَا يَقُولُ الـمُؤَذِّنُ إلاَّ فِي حَيَّ عَلَى الصَّلاةِ وَحَيَّ عَلَى الفَلاَحِ فَيَقُولُ: لاَ حَوْلَ وَلا قُوَّةَ إلاَّ باللَّهِ. ",
      "ayah": "اذكار الآذان",
      "meaning": "مرة واحدة",
      "count": 1
    },
    {
      "id": 2,
      "start": "",
      "name":
          "عنْ سَعْدِ بْن أَبي وقَّاصٍ رضِيَ اللَّه عنْهُ عَن النبي صَلّى اللهُ عَلَيْهِ وسَلَّم أَنَّهُ قَالَ: مَنْ قَال حِينَ يسْمعُ المُؤذِّنَ : أَشْهَد أَنْ لا إِله إِلاَّ اللَّه وحْدهُ لا شَريك لهُ ، وَأَنَّ مُحمَّداً عبْدُهُ وَرسُولُهُ ، رضِيتُ بِاللَّهِ ربًّا ، وبمُحَمَّدٍ رَسُولاً ، وبالإِسْلامِ دِينًا ، غُفِر لَهُ ذَنْبُهُ.",
      "ayah": "اذكار الآذان",
      "meaning": "رواه مسلم .",
      "count": 1
    },
    {
      "id": 3,
      "start": "",
      "name":
          "عَنْ عبْدِ اللَّهِ بْنِ عَمرِو بْنِ العاصِ رضِيَ اللَّه عنْهُما أَنه سَمِع رسُولَ اللَّهِ صَلّى اللهُ عَلَيْهِ وسَلَّم يقُولُ : إِذا سمِعْتُمُ النِّداءَ فَقُولُوا مِثْلَ ما يَقُولُ ، ثُمَّ صَلُّوا علَيَّ ، فَإِنَّهُ مَنْ صَلَّى علَيَّ صَلاةً صَلَّى اللَّه عَلَيْهِ بِهَا عشْراً ، ثُمَّ سلُوا اللَّه لي الْوسِيلَةَ ، فَإِنَّهَا مَنزِلَةٌ في الجنَّةِ لا تَنْبَغِي إِلاَّ لعَبْدٍ منْ عِباد اللَّه وَأَرْجُو أَنْ أَكُونَ أَنَا هُو ، فَمنْ سَأَل ليَ الْوسِيلَة حَلَّتْ لَهُ الشَّفاعَةُ",
      "ayah": "اذكار الآذان",
      "meaning": "رواه مسلم .",
      "count": 1
    },
    {
      "id": 4,
      "start": "",
      "name":
          "عَنْ جابرٍ بن عبد الله رضَي اللَّه عنهما‏ أَنَّ رَسُولَ اللَّهِ صَلّى اللهُ عَلَيْهِ وسَلَّم قَالَ : من قَال حِين يسْمعُ النِّداءَ : اللَّهُمَّ رَبَّ هذِهِ الدَّعوةِ التَّامَّةِ ، والصَّلاةِ الْقَائِمةِ، آت مُحَمَّداً الْوسِيلَةَ ، والْفَضَيِلَة، وابْعثْهُ مقَامًا محْمُوداً الَّذي وعَدْتَه ، حلَّتْ لَهُ شَفَاعتي يوْم الْقِيامِة .",
      "ayah": "اذكار الآذان",
      "meaning": "رواه البخاري .",
      "count": 1
    },
    {
      "id": 5,
      "start": "ما يقال بعد سماع الأذان",
      "name":
          "اللَّهُمَّ صَلِّ وَسَلِّمْ وَبَارِكْ عَلَى سَيِّدِنَا مُحَمَّدٍ. اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، والصَّلاةِ القَائِمَةِ، آتِ مُـحَمَّداً الوَسِيْلَةَ والفَضِيْلَةَ، وابْعَثْهُ مَقَاماً مَـحْمُوداً الَّذِي وَعَدْتَهُ، إنَّكَ لا تُخْلِفُ الـمِيْعَادِ.",
      "ayah": "اذكار الآذان",
      "meaning": "مرة واحدة",
      "count": 1
    },
    {
      "id": 6,
      "start": "ما يقال بين الأذان والإقامة",
      "name":
          "ما بين الأذان والإقامة فالدعاء عندئذٍ مرغّب فيه ومستحب. قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: الدُّعَاءُ لَا يُرَدُّ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ. قَالَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: إِنَّ الدُّعَاءَ لَا يُرَدُّ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ فَادْعُوا.",
      "ayah": "اذكار الآذان",
      "meaning": "مرة واحدة",
      "count": 1
    },
    {
      "id": 7,
      "start": "نص صيغة الأذان",
      "name":
          "اللهُ أكْبَرُ ، اللهُ أكْبَرُ اللهُ أكْبَرُ ، اللهُ أكْبَرُ أشْهَدُ أنَّ لا إلَهَ إلاَّ اللهُ أشْهَدُ أنَّ لا إلَهَ إلاَّ اللهُ أشْهَدُ أنَّ مُحَمَّداً رَسُولُ اللهِ أشْهَدُ أنَّ مُحَمَّداً رَسُولُ اللهِ حَيَّ عَلَى الصَّلاةِ حَيَّ عَلَى الصَّلاةِ حَيَّ عَلَى الفَلاحِ حَيَّ عَلَى الفَلاحِ اللهُ أكْبَرُ ، اللهُ أكْبَرُ لاَ إلَهَ إلاَّ اللهُ",
      "ayah": "اذكار الآذان",
      "meaning": "نص للاطلاع",
      "count": 1
    },
    {
      "id": 8,
      "start": "نص صيغة أذان الفجر",
      "name":
          "اللهُ أكْبَرُ ، اللهُ أكْبَرُ اللهُ أكْبَرُ ، اللهُ أكْبَرُ أشْهَدُ أنَّ لا إلَهَ إلاَّ اللهُ أشْهَدُ أنَّ لا إلَهَ إلاَّ اللهُ أشْهَدُ أنَّ مُحَمَّداً رَسُولُ اللهِ أشْهَدُ أنَّ مُحَمَّداً رَسُولُ اللهِ حَيَّ عَلَى الصَّلاةِ حَيَّ عَلَى الصَّلاةِ حَيَّ عَلَى الفَلاحِ حَيَّ عَلَى الفَلاحِ الصلاةُ خيرٌ مِنَ النوم الصلاةُ خيرٌ من النوم اللهُ أكْبَرُ ، اللهُ أكْبَرُ لاَ إلَهَ إلاَّ اللهُ",
      "ayah": "اذكار الآذان",
      "meaning": "نص للاطلاع",
      "count": 1
    },
    {
      "id": 9,
      "start": "نص صيغة الإقامة",
      "name":
          "اللهُ أكْبَرُ ، اللهُ أكْبَرُ أشْهَدُ أنَّ لا إلَهَ إلاَّ اللهُ أشْهَدُ أنَّ مُحَمَّداً رَسُولُ اللهِ حَيَّ عَلَى الصَّلاةِ حَيَّ عَلَى الفَلاحِ قد قامت الصلاةُ قد قامت الصلاةُ اللهُ أكْبَرُ ، اللهُ أكْبَرُ لاَ إلَهَ إلاَّ اللهُ",
      "ayah": "اذكار الآذان",
      "meaning": "نص للاطلاع",
      "count": 1
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadAdkarFromDatabase();
  }

  Future<void> _loadAdkarFromDatabase() async {
    final List<Map<String, dynamic>> adkar = await _dbHelper.getAllDhikr(
      DatabaseHelper.adkarAladanTableName, // استخدام اسم الجدول الجديد
    );

    if (adkar.isEmpty) {
      print(
          "Database table '${DatabaseHelper.adkarAladanTableName}' is empty. Inserting initial data...");
      // قم بإدخال البيانات مع `initialCount` و `currentCount`
      for (var dhikrData in _initialStaticAdkar) {
        await _dbHelper.insertDhikr(
          DatabaseHelper.adkarAladanTableName, // إدخال البيانات في الجدول الصحيح
          {
            'id': dhikrData['id'],
            'start': dhikrData['start'],
            'name': dhikrData['name'],
            'ayah': dhikrData['ayah'],
            'meaning': dhikrData['meaning'],
            'initialCount': dhikrData['count'],
            'currentCount': dhikrData['count'],
          },
        );
      }
      // بعد الإدخال، قم بتحميل البيانات مرة أخرى لتحديث الـ items
      await _loadAdkarFromDatabase();
    } else {
      items.clear();
      for (var dbDhikr in adkar) {
        items.add({
          "id": dbDhikr['id'],
          "start": dbDhikr['start'],
          "name": dbDhikr['name'],
          "ayah": dbDhikr['ayah'],
          "meaning": dbDhikr['meaning'],
          "count": (dbDhikr['currentCount'] as int)
              .obs, // لتمكين التفاعلية مع GetX
        });
      }
      print(
          "Adkar loaded from database for '${DatabaseHelper.adkarAladanTableName}'.");
    }
  }

  void decrementCount(int index) async {
    if (index >= 0 && index < items.length) {
      if (items[index]["count"].value > 0) {
        items[index]["count"].value--;
        await _dbHelper.updateDhikrCount(
          DatabaseHelper.adkarAladanTableName, // التحديث في الجدول الصحيح
          items[index]["id"] as int,
          items[index]["count"].value,
        );
      } else {
        // يمكنك استخدام Get.snackbar أو Get.bottomSheet هنا لإظهار رسالة
        Get.bottomSheet(
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.close_outlined,
                        color: Colors.greenAccent[400],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Text(
                        "تم استكمال عدد مرات الذكر ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          isScrollControlled: true,
          enableDrag: true,
        );
      }
    }
  }

  void resetCount(int index) async {
    if (index >= 0 && index < items.length) {
      final int itemId = items[index]["id"] as int;
      await _dbHelper.resetDhikrCountToInitial(
        DatabaseHelper.adkarAladanTableName, // إعادة التعيين في الجدول الصحيح
        itemId,
      );
      await _loadAdkarFromDatabase(); // إعادة تحميل البيانات بعد التعيين
    }
  }

  void resetAllCounters() async {
    await _dbHelper.resetAllDhikrCountsToInitial(
      DatabaseHelper.adkarAladanTableName, // إعادة التعيين الكلي في الجدول الصحيح
    );
    await _loadAdkarFromDatabase(); // إعادة تحميل البيانات بعد التعيين الكلي
  }
}