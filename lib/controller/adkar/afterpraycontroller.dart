// controller/adkar/adkar_after_salat_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart'; // نحتاجها للـ BottomSheet
import 'package:rokenalmuslem/data/database/database_helper.dart'; // تأكد من المسار الصحيح لقاعدة البيانات

class AdkarAfterSalatController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // RxList لحفظ الأذكار التي سيتم عرضها، مع RxInt لـ 'count' لتمكين التفاعلية
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  // قائمة الأذكار الأولية الثابتة لأذكار بعد الصلاة
  final List<Map<String, dynamic>> _initialStaticAdkar = [
    {
      "id": 1,
      "start": "أذكار بعد السلام من الصلاة المفروضة",
      "name": "أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله.",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "",
      "count": 1
    },
    {
      "id": 2,
      "start": "",
      "name":
          "اللّهُـمَّ أَنْـتَ السَّلامُ ، وَمِـنْكَ السَّلام ، تَبارَكْتَ يا ذا الجَـلالِ وَالإِكْـرام . ",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "",
      "count": 1
    },
    {
      "id": 3,
      "start": "",
      "name":
          "لا إلهَ إلاّ اللّهُ وحدَهُ لا شريكَ لهُ، لهُ المُـلْكُ ولهُ الحَمْد، وهوَ على كلّ شَيءٍ قَدير، اللّهُـمَّ لا مانِعَ لِما أَعْطَـيْت، وَلا مُعْطِـيَ لِما مَنَـعْت، وَلا يَنْفَـعُ ذا الجَـدِّ مِنْـكَ الجَـد. ",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "",
      "count": 1
    },
    {
      "id": 4,
      "start": "",
      "name":
          "لا إلهَ إلاّ اللّه, وحدَهُ لا شريكَ لهُ، لهُ الملكُ ولهُ الحَمد، وهوَ على كلّ شيءٍ قدير، لا حَـوْلَ وَلا قـوَّةَ إِلاّ بِاللهِ، لا إلهَ إلاّ اللّـه، وَلا نَعْـبُـدُ إِلاّ إيّـاه, لَهُ النِّعْـمَةُ وَلَهُ الفَضْل وَلَهُ الثَّـناءُ الحَـسَن، لا إلهَ إلاّ اللّهُ مخْلِصـينَ لَـهُ الدِّينَ وَلَوْ كَـرِهَ الكـافِرون.",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "",
      "count": 1
    },
    {
      "id": 5,
      "start": "",
      "name": "سُـبْحانَ اللهِ، والحَمْـدُ لله ، واللهُ أكْـبَر.",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "",
      "count": 33
    }, // تم تعديل العدد هنا كمثال (سبحان الله 33، الحمد لله 33، الله أكبر 33)
    {
      "id": 6,
      "start": "",
      "name": "لا إلهَ إلاّ اللّهُ وَحْـدَهُ لا شريكَ لهُ، لهُ الملكُ ولهُ الحَمْد، وهُوَ على كُلّ شَيءٍ قَـدير. ",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "تُقال مرة بعد الـ 33 تسبيحة إذا كانت التسبيحات 33",
      "count": 1
    },
    {
      "id": 7,
      "start": "بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم",
      "name": "قُلْ هُوَ ٱللَّهُ أَحَدٌ، ٱللَّهُ ٱلصَّمَدُ، لَمْ يَلِدْ وَلَمْ يُولَدْ، وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ.",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "ثلاث مرات بعد صلاتي الفجر والمغرب. ومرة بعد الصلوات الأخرى.",
      "count": 3
    },
    {
      "id": 8,
      "start": "بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم",
      "name": "قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ، مِن شَرِّ مَا خَلَقَ، وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ، وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِى ٱٱلْعُقَدِ، وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ.",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "ثلاث مرات بعد صلاتي الفجر والمغرب. ومرة بعد الصلوات الأخرى.",
      "count": 3
    },
    {
      "id": 9,
      "start": "بِسْمِ اللهِ الرَّحْمنِ الرَّحِيم",
      "name": "قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ، مَلِكِ ٱلنَّاسِ، إِلَٰهِ ٱلنَّاسِ، مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ، ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ، مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ.",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "ثلاث مرات بعد صلاتي الفجر والمغرب. ومرة بعد الصلوات الأخرى.",
      "count": 3
    },
    {
      "id": 10,
      "start": "أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ",
      "name":
          "اللّهُ لاَ إِلَـهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاء وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ.",
      "ayah": "[آية الكرسى - البقرة 255] ",
      "meaning": "",
      "count": 1
    },
    {
      "id": 11,
      "start": "",
      "name": "لا إلهَ إلاّ اللّهُ وحْـدَهُ لا شريكَ لهُ، لهُ المُلكُ ولهُ الحَمْد، يُحيـي وَيُمـيتُ وهُوَ على كُلّ شيءٍ قدير. ",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "عَشْر مَرّات بَعْدَ المَغْرِب وَالصّـبْح.",
      "count": 10
    },
    {
      "id": 12,
      "start": "",
      "name": "اللّهُـمَّ إِنِّـي أَسْأَلُـكَ عِلْمـاً نافِعـاً وَرِزْقـاً طَيِّـباً ، وَعَمَـلاً مُتَقَـبَّلاً. ",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "بَعْد السّلامِ من صَلاةِ الفَجْر.",
      "count": 1
    },
    {
      "id": 13,
      "start": "",
      "name": "اللَّهُمَّ أَجِرْنِي مِنْ النَّار. ",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "بعد صلاة الصبح والمغرب.",
      "count": 7
    },
    {
      "id": 14,
      "start": "",
      "name": "اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ. ",
      "ayah": "اذكار بعدالصلاة",
      "meaning": "",
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
      DatabaseHelper.adkarAfterSalatTableName, // استخدام اسم الجدول الجديد
    );

    if (adkar.isEmpty) {
      print(
          "Database table '${DatabaseHelper.adkarAfterSalatTableName}' is empty. Inserting initial data...");
      for (var dhikrData in _initialStaticAdkar) {
        await _dbHelper.insertDhikr(
          DatabaseHelper.adkarAfterSalatTableName, // إدخال البيانات في الجدول الصحيح
          {
            'id': dhikrData['id'],
            'start': dhikrData['start'],
            'name': dhikrData['name'],
            'ayah': dhikrData['ayah'],
            'meaning': dhikrData['meaning'], // تأكد من استخدام "meaning" هنا
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
          "Adkar loaded from database for '${DatabaseHelper.adkarAfterSalatTableName}'.");
    }
  }

  void decrementCount(int index) async {
    if (index >= 0 && index < items.length) {
      if (items[index]["count"].value > 0) {
        items[index]["count"].value--;
        await _dbHelper.updateDhikrCount(
          DatabaseHelper.adkarAfterSalatTableName, // التحديث في الجدول الصحيح
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
                        "تم استكمال عدد مرات الذكر",
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
        DatabaseHelper.adkarAfterSalatTableName, // إعادة التعيين في الجدول الصحيح
        itemId,
      );
      await _loadAdkarFromDatabase(); // إعادة تحميل البيانات بعد التعيين
    }
  }

  void resetAllCounters() async {
    await _dbHelper.resetAllDhikrCountsToInitial(
      DatabaseHelper.adkarAfterSalatTableName, // إعادة التعيين الكلي في الجدول الصحيح
    );
    await _loadAdkarFromDatabase(); // إعادة تحميل البيانات بعد التعيين الكلي
  }
}