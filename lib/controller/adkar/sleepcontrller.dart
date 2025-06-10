// controller/adkar/adkar_alnom_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart'; // نحتاجها للـ BottomSheet
import 'package:rokenalmuslem/data/database/database_helper.dart'; // تأكد من المسار الصحيح لقاعدة البيانات

class AdkarAlnomController extends GetxController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // RxList لحفظ الأذكار التي سيتم عرضها، مع RxInt لـ 'count' لتمكين التفاعلية
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  // قائمة الأذكار الأولية الثابتة لأذكار النوم
  final List<Map<String, dynamic>> _initialStaticAdkar = [
    {
      "id": 1,
      "start": "",
      "name":
          "بِاسْمِكَ رَبِّـي وَضَعْـتُ جَنْـبي ، وَبِكَ أَرْفَعُـه، فَإِن أَمْسَـكْتَ نَفْسـي فارْحَـمْها ، وَإِنْ أَرْسَلْتَـها فاحْفَظْـها بِمـا تَحْفَـظُ بِه عِبـادَكَ الصّـالِحـين. ",
      "ayah": "اذكار النوم",
      "meaning": "",
      "count": 1
    },
    {
      "id": 2,
      "start": "",
      "name":
          "اللّهُـمَّ إِنَّـكَ خَلَـقْتَ نَفْسـي وَأَنْـتَ تَوَفّـاهـا لَكَ ممَـاتـها وَمَحْـياها ، إِنْ أَحْيَيْـتَها فاحْفَظْـها ، وَإِنْ أَمَتَّـها فَاغْفِـرْ لَـها . اللّهُـمَّ إِنَّـي أَسْـأَلُـكَ العـافِـيَة. ",
      "ayah": "اذكار النوم",
      "meaning": "",
      "count": 1
    },
    {
      "id": 3,
      "start": "",
      "name": "اللّهُـمَّ قِنـي عَذابَـكَ يَـوْمَ تَبْـعَثُ عِبـادَك. ",
      "ayah": "اذكار النوم",
      "meaning": "ثلاث مرات",
      "count": 3
    },
    {
      "id": 4,
      "start": "",
      "name": "بِاسْـمِكَ اللّهُـمَّ أَمـوتُ وَأَحْـيا. ",
      "ayah": "اذكار النوم",
      "meaning": "مرة واحدة",
      "count": 1
    },
    {
      "id": 5,
      "start": "",
      "name":
          "الـحَمْدُ للهِ الَّذي أَطْـعَمَنا وَسَقـانا، وَكَفـانا، وَآوانا، فَكَـمْ مِمَّـنْ لا كـافِيَ لَـهُ وَلا مُـؤْوي.",
      "ayah": "اذكار النوم",
      "meaning": "مرة واحدة",
      "count": 1
    },
    {
      "id": 6,
      "start": "",
      "name":
          "اللّهُـمَّ عالِـمَ الغَـيبِ وَالشّـهادةِ فاطِـرَ السّماواتِ وَالأرْضِ رَبَّ كُـلِّ شَـيءٍ وَمَليـكَه، أَشْهـدُ أَنْ لا إِلـهَ إِلاّ أَنْت، أَعـوذُ بِكَ مِن شَـرِّ نَفْسـي، وَمِن شَـرِّ الشَّيْـطانِ وَشِـرْكِه، وَأَنْ أَقْتَـرِفَ عَلـى نَفْسـي سوءاً أَوْ أَجُـرَّهُ إِلـى مُسْـلِم .",
      "ayah": "اذكار النوم",
      "meaning": "مرة واحدة",
      "count": 1
    },
    {
      "id": 7,
      "start": "",
      "name":
          "اللّهُـمَّ أَسْـلَمْتُ نَفْـسي إِلَـيْكَ، وَفَوَّضْـتُ أَمْـري إِلَـيْكَ، وَوَجَّـهْتُ وَجْـهي إِلَـيْكَ، وَأَلْـجَـاْتُ ظَهـري إِلَـيْكَ، رَغْبَـةً وَرَهْـبَةً إِلَـيْكَ، لا مَلْجَـأَ وَلا مَنْـجـا مِنْـكَ إِلاّ إِلَـيْكَ، آمَنْـتُ بِكِتـابِكَ الّـذي أَنْزَلْـتَ وَبِنَبِـيِّـكَ الّـذي أَرْسَلْـت.",
      "ayah": "اذكار النوم",
      "meaning": "مرة واحدة",
      "count": 1
    },
    {
      "id": 8,
      "start": "",
      "name": "سُبْحَانَ اللَّهِ. ",
      "ayah": "اذكار النوم",
      "meaning": "ثلاث وثلاثين مرة",
      "count": 33
    },
    {
      "id": 9,
      "start": "",
      "name": "الْحَمْدُ لِلَّهِ.",
      "ayah": "اذكار النوم",
      "meaning": "ثلاث وثلاثين مرة",
      "count": 33
    },
    {
      "id": 10,
      "start": "",
      "name": "اللَّهُ أَكْبَرُ.",
      "ayah": "اذكار النوم",
      "meaning": "ثلاث وثلاثين مرة",
      "count": 34
    }, // هنا يجب أن يكون 34 لتكملة المئة
    {
      "id": 11,
      "start": "",
      "name":
          "يجمع كفيه ثم ينفث فيهما والقراءة فيهما‏:‏ ‏{‏قل هو الله أحد‏}‏ و‏{‏قل أعوذ برب الفلق‏}‏ و‏{‏قل أعوذ برب الناس‏}‏ ومسح ما استطاع من الجسد يبدأ بهما على رأسه ووجه وما أقبل من جسده. ",
      "ayah": "اذكار النوم",
      "meaning": "ثلاث مرات",
      "count": 3
    },
    {
      "id": 12,
      "start": "سورة البقرة: أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ",
      "name":
          "آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ ۚ كُلٌّ آمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِنْ رُسُلِهِ ۚ وَقَالُوا سَمِعْنَا وَأَطَعْنَا ۖ غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ. لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ.",
      "ayah": " [البقرة 285 - 286]",
      "meaning": "من قرأ آيتين من آخر سورة البقرة في ليلة كفتاه.",
      "count": 1
    },
    {
      "id": 13,
      "start": "آية الكرسى: أَعُوذُ بِاللهِ مِنْ الشَّيْطَانِ الرَّجِيمِ",
      "name":
          "اللّهُ لاَ إِلَـهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاء وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ.",
      "ayah": " [البقرة 255] ",
      "meaning": "أجير من الجن حتى يصبح.",
      "count": 1
    },
    {
      "id": 14,
      "start": "أذكار من قلق في فراشه ولم ينم",
      "name":
          "عن بريدة رضي الله عنه، قال‏:‏ شكا خالد بن الوليد رضي الله عنه إلى النبي صلى الله عليه وسلم فقال‏:‏ يا رسول الله‏!‏ ما أنام الليل من الأرق، فقال النبي صلى الله عليه وسلم‏:‏ ‏‏إذا أويت إلى فراشك فقل‏:‏ اللهم رب السموات السبع وما أظلت، ورب الأرضين وما أقلت، ورب الشياطين وما أضلت، كن لي جارا من خلقك كلهم جميعا أن يفرط علي أحد منهم أو أن يبغي علي، عز جارك، وجل ثناؤك ولا إله غيرك، ولا إله إلا أنت‏ عن عمرو بن شعيب، عن أبيه، عن جده: أن رسول الله صلى الله عليه وسلم كان يعلمهم من الفزع كلمات‏:‏ ‏‏أعوذ بكلمات الله التامة من غضبه وشر عباده، ومن همزات الشياطين وأن يحضرون‏",
      "ayah": "اذكار النوم",
      "meaning": "مرة واحدة",
      "count": 1
    },
    {
      "id": 15,
      "start": "أذكار الأحلام",
      "name":
          "عن أبي قتادة رضي الله عنه قال‏:‏ قال رسول الله صلى الله عليه وسلم‏:‏ ‏‏الرؤيا الصالحة‏‏ وفي رواية ‏‏الرؤيا الحسنة من الله، والحلم من الشيطان، فمن رأى شيئا يكرهه فلينفث عن شماله ثلاثا وليتعوذ من الشيطان، فإنها لا تضره‏.",
      "ayah": "اذكار النوم",
      "meaning": "مرة واحدة",
      "count": 1
    },
    // {
    //   "id": 16, // إذا كان هذا الذكر فارغًا، فكر في حذفه أو ملء بياناته.
    //   "start": "",
    //   "name": "",
    //   "ayah": "اذكار النوم",
    //   "meaning": "",
    //   "count": 1
    // },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadAdkarFromDatabase();
  }

  Future<void> _loadAdkarFromDatabase() async {
    final List<Map<String, dynamic>> adkar = await _dbHelper.getAllDhikr(
      DatabaseHelper.adkarAlnomTableName, // استخدام اسم الجدول الجديد
    );

    if (adkar.isEmpty) {
      print(
          "Database table '${DatabaseHelper.adkarAlnomTableName}' is empty. Inserting initial data...");
      // قم بإدخال البيانات مع `initialCount` و `currentCount`
      for (var dhikrData in _initialStaticAdkar) {
        await _dbHelper.insertDhikr(
          DatabaseHelper.adkarAlnomTableName, // إدخال البيانات في الجدول الصحيح
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
      print("Adkar loaded from database for '${DatabaseHelper.adkarAlnomTableName}'.");
    }
  }

  void decrementCount(int index) async {
    if (index >= 0 && index < items.length) {
      if (items[index]["count"].value > 0) {
        items[index]["count"].value--;
        await _dbHelper.updateDhikrCount(
          DatabaseHelper.adkarAlnomTableName, // التحديث في الجدول الصحيح
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
        DatabaseHelper.adkarAlnomTableName, // إعادة التعيين في الجدول الصحيح
        itemId,
      );
      await _loadAdkarFromDatabase(); // إعادة تحميل البيانات بعد التعيين
    }
  }

  void resetAllCounters() async {
    await _dbHelper.resetAllDhikrCountsToInitial(
      DatabaseHelper.adkarAlnomTableName, // إعادة التعيين الكلي في الجدول الصحيح
    );
    await _loadAdkarFromDatabase(); // إعادة تحميل البيانات بعد التعيين الكلي
  }
}