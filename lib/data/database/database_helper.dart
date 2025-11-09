// lib/data/database/database_helper.dart

import 'package:rokenalmuslem/controller/hadith_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const String dbName = 'adkar_database.db';
  static const int dbVersion = 18; // <--- **قم بزيادة هذا الرقم! مهم جدًا**

  // Existing table names
  static const String morningAdkarTableName = 'MorningAdkar';
  static const String eveningAdkarTableName = 'EveningAdkar';
  static const String adkarSalatTableName = 'AdkarSalat';
  static const String adkarAfterSalatTableName = 'AdkarAfterSalat';
  static const String adkarAlnomTableName = 'AdkarAlnom';
  static const String adkarAladanTableName = 'AdkarAladan';
  static const String adkarAlmasjidTableName = 'AdkarAlmasjid';
  static const String adkarAlastygadTableName = 'AdkarAlastygad';
  static const String adkarHomeTableName = 'AdkarHome';
  static const String adkarAlwswiTableName = 'AdkarAlwswi';
  static const String adkarAlkhlaTableName = 'AdkarAlkhla';
  static const String adkarEatTableName = 'AdkarEat';
  static const String adayahForDeadTableName = 'AdayahForDead';
  static const String asmaAllahTableName = 'AsmaAllah';
  static const String fadelAlDuaaTableName = 'FadelAlDuaa';
  static const String ruqyahsTableName = 'Ruqyahs';
  static const String adayaQuraniyaTableName = 'AdayaQuraniya';
  static const String adayahNabuiaTableName =
      'AdayahNabuia'; // <--- **الجدول الجديد للأدعية النبوية**
  static const String hadithOfTheDayTableName = 'hadith_of_the_day';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Existing tables creation
    await db.execute('''
      CREATE TABLE $morningAdkarTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $eveningAdkarTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adkarSalatTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adkarAfterSalatTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adkarAlnomTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adkarAladanTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adkarAlmasjidTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adkarAlastygadTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adkarHomeTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adkarAlwswiTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adkarAlkhlaTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adkarEatTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $adayahForDeadTableName (
        id INTEGER PRIMARY KEY,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $asmaAllahTableName (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        dis TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $fadelAlDuaaTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        iconName TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $ruqyahsTableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // إنشاء جدول AdayaQuraniya
    await db.execute('''
      CREATE TABLE $adayaQuraniyaTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        meaning TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    print('Database table "$adayaQuraniyaTableName" created.');

    // <--- **إنشاء جدول AdayahNabuia الجديد**
    await db.execute('''
      CREATE TABLE $adayahNabuiaTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start TEXT,
        name TEXT NOT NULL,
        ayah TEXT,
        mang TEXT,
        initialCount INTEGER NOT NULL,
        currentCount INTEGER NOT NULL
      )
    ''');
    print('Database table "$adayahNabuiaTableName" created.');
    // <--- **نهاية إضافة جدول AdayahNabuia**

    // إنشاء جدول حديث اليوم
    await db.execute('''
      CREATE TABLE $hadithOfTheDayTableName (
        id INTEGER PRIMARY KEY,
        text TEXT NOT NULL,
        source TEXT NOT NULL
      )
    ''');

    // Populate initial data for all tables including the new ones
    await _populateInitialData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Database upgrading from version $oldVersion to $newVersion');
    // Drop all existing tables (for simplicity in development)
    // في بيئة الإنتاج، يجب أن تكون هذه الترقية أكثر دقة (مثلاً، إضافة أعمدة بدلاً من حذف الجداول)
    await db.execute("DROP TABLE IF EXISTS $morningAdkarTableName;");
    await db.execute("DROP TABLE IF EXISTS $eveningAdkarTableName;");
    await db.execute("DROP TABLE IF EXISTS $adkarSalatTableName;");
    await db.execute("DROP TABLE IF EXISTS $adkarAfterSalatTableName;");
    await db.execute("DROP TABLE IF EXISTS $adkarAlnomTableName;");
    await db.execute("DROP TABLE IF EXISTS $adkarAladanTableName;");
    await db.execute("DROP TABLE IF EXISTS $adkarAlmasjidTableName;");
    await db.execute("DROP TABLE IF EXISTS $adkarAlastygadTableName;");
    await db.execute("DROP TABLE IF EXISTS $adkarHomeTableName;");
    await db.execute("DROP TABLE IF EXISTS $adkarAlwswiTableName;");
    await db.execute("DROP TABLE IF EXISTS $adkarAlkhlaTableName;");
    await db.execute("DROP TABLE IF EXISTS $adkarEatTableName;");
    await db.execute("DROP TABLE IF EXISTS $adayahForDeadTableName;");
    await db.execute("DROP TABLE IF EXISTS $asmaAllahTableName;");
    await db.execute("DROP TABLE IF EXISTS $fadelAlDuaaTableName;");
    await db.execute("DROP TABLE IF EXISTS $ruqyahsTableName;");
    await db.execute("DROP TABLE IF EXISTS $adayaQuraniyaTableName;");
    await db.execute(
      "DROP TABLE IF EXISTS $adayahNabuiaTableName;",
    ); // <--- **إزالة الجدول الجديد عند الترقية**
    await db.execute("DROP TABLE IF EXISTS $hadithOfTheDayTableName;");

    await _onCreate(db, newVersion); // إعادة إنشاء جميع الجداول بالبنية الجديدة
  }

  Future<void> _populateInitialData(Database db) async {
    // Fadel Al-Duaa data population
    final countFadel = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $fadelAlDuaaTableName'),
    );
    if (countFadel == 0) {
      print('FadelAlDuaa table is empty, populating...');
      final List<Map<String, dynamic>> initialFadelAlDuas = [
        {
          'title': "معنى الدعاء :",
          'content':
              "الدعاء هو أن يطلبَ الداعي ما ينفعُه وما يكشف ضُرَّه؛ وحقيقته إظهار الافتقار إلى الله، والتبرؤ من الحول والقوة، وهو سمةُ العبوديةِ، واستشعارُ الذلةِ البشرية، وفيه معنى الثناءِ على الله عز وجل، وإضافةِ الجود والكرم إليه.",
          'iconName': 'lightbulb_outline',
        },
        {
          'title': "الدعاءُ طاعةٌ لله، وامتثال لأمره : ",
          'content':
              "قال تعالى: ﴿وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ إِنَّ الَّذِينَ يَسْتَكْبِرُونَ عَنْ عِبَادَتِي سَيَدْخُلُونَ جَهَنَّمَ دَاخِرِينَ﴾. [سورة غافر: الآية 60]",
          'iconName': 'check_circle_outline',
        },
        {
          'title': "الدعاء عبادة :",
          'content':
              "قال صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ : الدُّعَاءُ هُوَ الْعِبَادَةُ. [رواه الترمذي وابن ماجه، وصححه الألباني]",
          'iconName': 'self_improvement',
        },
        {
          'title': "الدعاء أكرم شيء على الله تعالى :",
          'content':
              "قال صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ : لَيْسَ شَيْءٌ أَكْرَمَ عَلَى اللَّهِ تَعَالَى مِنْ الدُّعَاءِ. [رواه أحمد والبخاري، وابن ماجة، والترمذي والحاكم وصححه، ووافقه الذهبي]",
          'iconName': 'star_border',
        },
        {
          'title': "الدعاء سبب لدفع غضب الله :",
          'content':
              "قال صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: مَنْ لَمْ يَسْأَلْ اللَّهَ يَغْضَبْ عَلَيْهِ. [رواه الترمذيُّ، وابن ماجةَ، وصححه الحاكم، ووافقه الذهبي، وحسنه الألباني]",
          'iconName': 'gpp_good_outlined',
        },
        {
          'title': "الدعاء سلامة من العجز، ودليل على الكَياسة :",
          'content':
              "قال صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: أَعْجَزُ النَّاسِ مَنْ عَجَزَ عَنْ الدُّعَاءِ وَأَبْخَلُ النَّاسِ مَنْ بَخِلَ بِالسَّلَامِ. [رواه ابن حبان وصححه الألباني]",
          'iconName': 'fitness_center_outlined',
        },
        {
          'title': "الدعاء سبب لرفع البلاء :",
          'content':
              "قال صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: مَنْ فُتِحَ لَهُ مِنْكُمْ بَابُ الدُّعَاءِ فُتِحَتْ لَهُ أَبْوَابُ الرَّحْمَةِ وَمَا سُئِلَ اللَّهُ شَيْئًا يَعْنِي أَحَبَّ إِلَيْهِ مِنْ أَنْ يُسْأَلَ الْعَافِيَةَ وَقَالَ رَسُولُ اللَّهِ صَلَّى اللَّهم عَلَيْهِ وَسَلَّمَ إِنَّ الدُّعَاءَ يَنْفَعُ مِمَّا نَزَلَ وَمِمَّا لَمْ يَنْزِلْ فَعَلَيْكُمْ عِبَادَ اللَّهِ بِالدُّعَاءِ. [رواه الترمذي وحسنه الألباني ]",
          'iconName': 'shield_outlined',
        },
        {
          'title': "الداعي في معيةُ الله :",
          'content':
              "قال رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: يقول الله عز وجل: أَنَا عِنْدَ ظَنِّ عَبْدِي بِي وَأَنَا مَعَهُ إِذَا دَعَانِي . [رواه مسلم] .",
          'iconName': 'waving_hand',
        },
        {
          'title': "فضل الدعاء في السجود :",
          'content':
              "قال صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: أَقْرَبُ مَا يَكُونُ الْعَبْدُ مِنْ رَبِّهِ عَزَّ وَجَلَّ وَهُوَ سَاجِدٌ ، فَأَكْثِرُوا الدُّعَاءَ . [رواه مسلم] .",
          'iconName': 'mosque_rounded',
        },
        {
          'title': "فضل الدعاء بالليل :",
          'content':
              "قال صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: إِنَّ فِي اللَّيْلِ لَسَاعَةٌ لَا يُوَافِقُهَا رَجُلٌ مُسْلِمٌ يَسْأَلُ اللَّهَ تَعَالَى مِنْ أَمْرِ الدُّنْيَا وَالْآخِرَةِ إِلَّا أَعْطَاهُ إِيَّاهُ وَذَلِكَ كُلَّ لَيْلَةٍ . [رواه مسلم]",
          'iconName': 'nightlight_round',
        },
        {
          'title': "فضل الدعاء للمسلمين بظهر الغيب :",
          'content':
              "قال صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ: مَا مِنْ عَبْدٍ مُسْلِمٍ يَدْعُو لِأَخِيهِ بِظَهْرِ الْغَيْبِ إِلَّا قَالَ الْمَلَكُ : وَلَكَ بِمِثْلٍ . [رواه مسلم]",
          'iconName': 'people_outline',
        },
      ];
      for (var duaa in initialFadelAlDuas) {
        await db.insert(
          fadelAlDuaaTableName,
          duaa,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('Initial FadelAlDuaa populated successfully.');
    }

    // Ruqyah data population
    final countRuqyahs = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $ruqyahsTableName'),
    );
    if (countRuqyahs == 0) {
      print('Ruqyahs table is empty, populating...');
      final List<Map<String, dynamic>> initialRuqyahs = [
        {
          'text':
              "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ ﴿1﴾ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ﴿2﴾ الرَّحْمَنِ الرَّحِيمِ ﴿3﴾ مَالِكِ يَوْمِ الدِّينِ ﴿4﴾ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ﴿5﴾ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ﴿6﴾ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ ﴿7﴾. [الفاتحة: 1-7]",
          'type': 'quran',
        },
        {
          'text':
              "الم ﴿1﴾ ذَلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ هُدًى لِلْمُتَّقِينَ ﴿2﴾ الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنْفِقُونَ ﴿3﴾ وَالَّذِينَ يُؤْمِنُونَ بِمَا أُنْزِلَ إِلَيْكَ وَمَا أُنْزِلَ مِنْ قَبْلِكَ وَبِالْآَخِرَةِ هُمْ يُوقِنُونَ ﴿4﴾ أُولَئِكَ عَلَى هُدًى مِنْ رَبِّهِمْ وَأُولَئِكَ هُمُ الْمُفْلِحُونَ ﴿5﴾. [البقرة: 1-5]",
          'type': 'quran',
        },
        {
          'text':
              "اللّهُ لاَ إِلَـهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلاَّ بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلاَ يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلاَّ بِمَا شَاء وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالأَرْضَ وَلاَ يَؤُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ. [آية الكرسى - البقرة 255]",
          'type': 'quran',
        },
        {
          'text':
              "لِلَّهِ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ وَإِنْ تُبْدُوا مَا فِي أَنْفُسِكُمْ أَوْ تُخْفُوهُ يُحَاسِبْكُمْ بِهِ اللَّهُ فَيَغْفِرُ لِمَنْ يَشَاءُ وَيُعَذِّبُ مَنْ يَشَاءُ وَاللَّهُ عَلَى كُلِّ شَيْءٍ قَدِيرٌ ﴿284﴾ آَمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ وَالْمُؤْمِنُونَ كُلٌّ آَمَنَ بِاللَّهِ وَمَلَائِكَتِهِ وَكُتُبِهِ وَرُسُلِهِ لَا نُفَرِّقُ بَيْنَ أَحَدٍ مِنْ رُسُلِهِ وَقَالُوا سَمِعْنَا وَأَطَعْنَا غُفْرَانَكَ رَبَّنَا وَإِلَيْكَ الْمَصِيرُ ﴿285﴾ لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ ﴿286﴾. [البقرة: 284-286]",
          'type': 'quran',
        },
        {
          'text':
              "قُلْ يَا أَيُّهَا الْكَافِرُونَ ﴿1﴾ لَا أَعْبُدُ مَا تَعْبُدُونَ ﴿2﴾ وَلَا أَنْتُمْ عَابِدُونَ مَا أَعْبُدُ ﴿3﴾ وَلَا أَنَا عَابِدٌ مَا عَبَدْتُمْ ﴿4﴾ وَلَا أَنْتُمْ عَابِدُونَ مَا أَعْبُدُ ﴿5﴾ لَكُمْ دِينُكُمْ وَلِيَ دِينِ ﴿6﴾. [الكافرون]",
          'type': 'quran',
        },
        {
          'text':
              "قُلْ هُوَ اللَّهُ أَحَدٌ ﴿1﴾ اللَّهُ الصَّمَدُ ﴿2﴾ لَمْ يَلِدْ وَلَمْ يُولَدْ ﴿3﴾ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ ﴿4﴾. [الإخلاص]",
          'type': 'quran',
        },
        {
          'text':
              "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ﴿1﴾ مِنْ شَرِّ مَا خَلَقَ ﴿2﴾ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ﴿3﴾ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ﴿4﴾ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ ﴿5﴾. [الفلق]",
          'type': 'quran',
        },
        {
          'text':
              "قُلْ أَعُوذُ بِرَبِّ النَّاسِ ﴿1﴾ مَلِكِ النَّاسِ ﴿2﴾ إِلَهِ النَّاسِ ﴿3﴾ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ﴿4﴾ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ﴿5﴾ مِنَ الْجِنَّةِ وَالنَّاسِ ﴿6﴾. [الناس]",
          'type': 'quran',
        },
        {
          'text':
              "أَعُوذُ بِاللَّهِ الْعَظِيمِ، وَبِوَجْهِهِ الْكَرِيمِ، وَسُلْطَانِهِ الْقَدِيمِ، مِنَ الشَّيْطَانِ الرَّجِيمِ.",
          'type': 'sunnah',
        },
        {
          'text':
              "أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ، مِنْ هَمْزِهِ وَنَفْخِهِ وَنَفْثِهِ.",
          'type': 'sunnah',
        },
        {
          'text':
              "أعوذُ بكلماتِ اللهِ التامَّةِ ، مِن كُلِّ شيطانٍ وهامَّةٍ ، ومِن كُلِّ عَيْنٍ لامَّةٍ.",
          'type': 'sunnah',
        },
        {
          'text': "أعوذُ بكلماتِ اللهِ التامَّاتِ مِن شرِّ ما خَلق.",
          'type': 'sunnah',
        },
        {
          'text':
              "بِسْمِ اللَّهِ أَرْقِيكَ، مِنْ كُلِّ شَيْءٍ يُؤْذِيكَ، مِنْ شَرِّ كُلِّ نَفْسٍ أَوْ عَيْنِ حَاسِدٍ، اللَّهُ يَشْفِيكَ، بِسْمِ اللَّهِ أَرْقِيكَ.",
          'type': 'sunnah',
        },
        {
          'text':
              "بِسْمِ اللَّهِ (ثَلَاثًا)، أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ (سَبْعَ مَرَّاتٍ).",
          'type': 'sunnah',
        },
        {
          'text':
              "أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ، أَنْ يُعَافِيَكَ وَيَشْفِيَكَ.",
          'type': 'sunnah',
        },
        {
          'text':
              "اللَّهُمَّ ربَّ النَّاسِ، أَذْهِب الْبَأسَ، واشْفِ، أَنْتَ الشَّافي لا شِفَاءَ إِلاَّ شِفَاؤُكَ، شِفاءً لا يُغَادِرُ سقَماً.",
          'type': 'sunnah',
        },
        {
          'text': "اللَّهُمَّ اشْفِ عَبْدَكَ، وصَدِّقْ رَسُولَك.",
          'type': 'sunnah',
        },
        {
          'text':
              "اللهُمَّ بَارِكْ عَلَيْهِ، وَأَذْهِبْ عَنْهُ حَرَّ الْعَيْنِ وَبَرْدَهَا وَوَصَبَهَا.",
          'type': 'sunnah',
        },
        {
          'text':
              "اللَّهُمَّ إِنَّا نَسْأَلُكَ مِنْ خَيْرِ مَا سَأَلَكَ مِنْهُ نَبِيُّكَ مُحَمَّدٌ صلى الله عليه وسلم وَنَعُوذُ بِكَ مِنْ شَرِّ مَا اسْتَعَاذَ مِنْهُ نَبِيُّكَ مُحَمَّدٌ صلى الله عليه وسلم وَأَنْتَ الْمُسْتَعَانُ، وَعَلَيْكَ الْبَلَاغُ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ.",
          'type': 'sunnah',
        },
        {
          'text':
              "لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْكَرِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الْعَرْشِ الْعَظِيمِ.",
          'type': 'sunnah',
        },
        {
          'text':
              "رَبّنَا الَّلهُ الذِي فِي السَّمَاءِ، تَقَدَّسَ اسمُكَ، أَمرُكَ فِي السَّمَاءِ وَالأَرْضِ، كَمَا رَحمَتُكَ فِي السَّمَاءِ فَاجْعَلْ رَحْمَتَكَ فِي الأَرْضِ، اغفِر لَنَا حَوْبَنَا وَخَطَايَانَا، أَنتَ رَبُّ الطَّيِّبِينَ، أَنزِلْ رَحْمَةً مِن رَحمَتِكَ، وَشِفَاءً مِن شِفَائِكَ عَلَى هَذَا الوَجَعِ، فَيَبرَأ. (ثلاث مرات).",
          'type': 'sunnah',
        },
        {
          'text':
              "أَعُوذُ بِوَجْهِ اللَّهِ الْكَرِيمِ، وَبِكَلِمَاتِ اللَّهِ التَّامَّاتِ، اللَّاتِي لَا يُجَاوِزُهُنَّ بَرٌّ وَلَا فَاجِرٌ، مِنْ شَرِّ مَا يَنْزِلُ مِنَ السَّمَاءِ وَشَرِّ مَا يُعْرَجُ فِيهَا، وَشَرِّ مَا ذَرَأَ فِي الْأَرْضِ وَشَرِّ مَا يَخْرُجُ مِنْهَا، وَمِنْ فِتَنِ اللَّيْلِ وَالنَّهَارِ، وَمِنْ طَوَارِقِ اللَّيْلِ وَالنَّهَارِ، إِلَّا طَارِقًا يَطْرُقُ بِخَيْرٍ يَا رَحْمَنُ .",
          'type': 'sunnah',
        },
        {
          'text':
              "بِسـمِ اللهِ الذي لا يَضُـرُّ مَعَ اسمِـهِ شَيءٌ في الأرْضِ وَلا في السّمـاءِ وَهـوَ السّمـيعُ العَلـيم. (ثلاث مرات).",
          'type': 'sunnah',
        },
        {
          'text':
              "أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّةِ مِنْ غَضَبِهِ وَعِقَابِهِ ، وَشَرِّ عِبَادِهِ ، وَمَنْ هَمَزَاتِ الشَّيَاطِينِ ، وَأَنْ يَحْضُرُونِ.",
          'type': 'sunnah',
        },
        {
          'text':
              "بِسْمِ اللَّهِ الْعَظِيمِ ، أَعُوذُ بِاللَّهِ الْكَبِيرِ مِنْ شَرِّ كُلِّ عِرْقٍ نَعَّارٍ ، وَمِنْ شَرِّ حَرِّ النَّارِ.",
          'type': 'sunnah',
        },
        {
          'text':
              "بِسْمِ اللهِ تربَةُ أَرْضِنَا، بِرِيقةِ بَعْضِنَا، يُشْفَى سَقِيمُنَا، بإِذْنِ رَبِّنَا.",
          'type': 'sunnah',
        },
        {
          'text':
              "اللَّهُمَّ إِنِّي أَسْأَلُكَ بِأَنَّ لَكَ الْحَمْدَ لَا إِلَهَ إِلَّا أَنْتَ، الْمَنَّانُ يَا بَدِيعَ السَّمَاوَاتِ وَالْأَرْضِ، يَا ذَا الْجَلَالِ وَالْإِكْرَامِ، يَا حَيُّ يَا قَيُّومُ.",
          'type': 'sunnah',
        },
        {
          'text':
              "اللَّهُمَّ إِنِّي أَسْأَلُكَ بِأَنِّي أَشْهَدُ أَنَّكَ أَنْتَ اللَّه لاَ إِلَهَ إِلاَّ أَنْتَ، الأَحَدُ، الصَّمَدُ، الَّذِي لَمْ يَلِدْ، وَلَمْ يُولَدْ، وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ.",
          'type': 'sunnah',
        },
        {
          'text':
              "أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ، أَنْ يُعَافِيَكَ وَيَشْفِيَكَ. (سبع مرات).",
          'type': 'sunnah',
        },
        {
          'text':
              "اللَّهُمَّ بَرِّدْ قَلْبِي بِالثَّلْجِ وَالْبَرَدِ وَالْمَاءِ الْبَارِدِ ، اللَّهُمَّ نَقِّ قَلْبِي مِنَ الْخَطَايَا كَمَا نَقَّيْتَ الثَّوْبَ الْأَبْيَضَ مِنَ الدَّنَسِ.",
          'type': 'sunnah',
        },
        {
          'text':
              "اللَّهُمَّ إِنِّي أَعُوذُ بِوَجْهِكَ الْكَرِيمِ وَكَلِمَاتِكَ التَّامَّةِ مِنْ شَرِّ مَا أَنْتَ آخِذٌ بِنَاصِيَتِهِ، اللَّهُمَّ أَنْتَ تَكْشِفُ الْمَغْرَمَ وَالْمَأْثَمَ، اللَّهُمَّ لَا يُهْزَمُ جُنْدُكَ، وَلَا يُخْلَفُ وَعْدُكَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ، سُبْحَانَكَ وَبِحَمْدِكَ.",
          'type': 'sunnah',
        },
        {
          'text':
              "بِاسْمِ اللَّهِ يُبْرِيكَ، وَمِنْ كُلِّ دَاءٍ يَشْفِيكَ، وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ، وَشَرِّ كُلِّ ذِي عَيْنٍ.",
          'type': 'sunnah',
        },
        {
          'text':
              "اللَّهُمَّ اشْفِ عَبْدَكَ يَنْكَأُ لَكَ عَدُوًّا ، أَوْ يَمْشِي لَكَ إِلَى صَلاةٍ.",
          'type': 'sunnah',
        },
        {
          'text':
              "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ فِي الْعَالَمِينَ إِنَّكَ حَمِيدٌ مَجِيدٌ.",
          'type': 'sunnah',
        },
      ];
      for (var ruqyah in initialRuqyahs) {
        await db.insert(
          ruqyahsTableName,
          ruqyah,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('Initial Ruqyahs populated successfully.');
    }

    // Adaya Quraniya data population
    final countAdayaQuraniya = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $adayaQuraniyaTableName'),
    );
    if (countAdayaQuraniya == 0) {
      print('AdayaQuraniya table is empty, populating...');
      final List<Map<String, dynamic>> initialAdayaQuraniya = [
        {
          "start": "",
          "name":
              "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ .",
          "ayah": " [البقرة - 201].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ .",
          "ayah": "[البقرة - 250].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا لاَ تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا رَبَّنَا وَلاَ تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا رَبَّنَا وَلاَ تُحَمِّلْنَا مَا لاَ طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنتَ مَوْلاَنَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ",
          "ayah": " [البقرة - 286].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا لاَ تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً إِنَّكَ أَنتَ الْوَهَّابُ .",
          "ayah": "[آل عمران - 8].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا إِنَّنَا آمَنَّا فَاغْفِرْ لَنَا ذُنُوبَنَا وَقِنَا عَذَابَ النَّارِ .",
          "ayah": "[آل عمران - 16].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبِّ هَبْ لِي مِن لَّدُنْكَ ذُرِّيَّةً طَيِّبَةً إِنَّكَ سَمِيعُ الدُّعَاء",
          "ayah": "[آل عمران - 38].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا آمَنَّا بِمَا أَنزَلْتَ وَاتَّبَعْنَا الرَّسُولَ فَاكْتُبْنَا مَعَ الشَّاهِدِينَ",
          "ayah": "[آل عمران - 53].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "ربَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا وانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَِ",
          "ayah": "[آل عمران - 147].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا مَا خَلَقْتَ هَذا بَاطِلاً سُبْحَانَكَ فَقِنَا عَذَابَ النَّارِ رَبَّنَا إِنَّكَ مَن تُدْخِلِ النَّارَ فَقَدْ أَخْزَيْتَهُ وَمَا لِلظَّالِمِينَ مِنْ أَنصَارٍ رَّبَّنَا إِنَّنَا سَمِعْنَا مُنَادِيًا يُنَادِي لِلإِيمَانِ أَنْ آمِنُواْ بِرَبِّكُمْ فَآمَنَّا رَبَّنَا فَاغْفِرْ لَنَا ذُنُوبَنَا وَكَفِّرْ عَنَّا سَيِّئَاتِنَا وَتَوَفَّنَا مَعَ الأبْرَارِ رَبَّنَا وَآتِنَا مَا وَعَدتَّنَا عَلَى رُسُلِكَ وَلاَ تُخْزِنَا يَوْمَ الْقِيَامَةِ إِنَّكَ لاَ تُخْلِفُ الْمِيعَادَ",
          "ayah": "[آل عمران -  191-194].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ",
          "ayah": " [الأعراف - 23].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name": "رَبَّنَا لاَ تَجْعَلْنَا مَعَ الْقَوْمِ الظَّالِمِينَ",
          "ayah": "[الأعراف - 47].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَتَوَفَّنَا مُسْلِمِينَ",
          "ayah": " [الأعراف - 126].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "حَسْبِيَ اللّهُ لا إِلَـهَ إِلاَّ هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ",
          "ayah": " [التوبة - 129].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا لاَ تَجْعَلْنَا فِتْنَةً لِّلْقَوْمِ الظَّالِمِينَ وَنَجِّنَا بِرَحْمَتِكَ مِنَ الْقَوْمِ الْكَافِرِينَ",
          "ayah": " [يونس - 85-86].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبِّ إِنِّي أَعُوذُ بِكَ أَنْ أَسْأَلَكَ مَا لَيْسَ لِي بِهِ عِلْمٌ وَإِلاَّ تَغْفِرْ لِي وَتَرْحَمْنِي أَكُن مِّنَ الْخَاسِرِينَ",
          "ayah": "[هود - 47].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبِّ اجْعَلْنِي مُقِيمَ الصَّلاَةِ وَمِن ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاء",
          "ayah": "[إبرهيم - 40].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ",
          "ayah": "[إبرهيم - 41].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَّبِّ أَدْخِلْنِي مُدْخَلَ صِدْقٍ وَأَخْرِجْنِي مُخْرَجَ صِدْقٍ وَاجْعَل لِّي مِن لَّدُنكَ سُلْطَانًا نَّصِيرًا",
          "ayah": "[الإسراء - 80].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا",
          "ayah": "[الكهف - 10].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي",
          "ayah": "[طه - 25-28].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name": "رَّبِّ زِدْنِي عِلْمًا",
          "ayah": " [طه - 114].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "لا إِلَهَ إِلا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ",
          "ayah": "[الأنبياء - 87].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name": "رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنتَ خَيْرُ الْوَارِثِينَ",
          "ayah": " [الأنبياء - 89].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَّبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ وَأَعُوذُ بِكَ رَبِّ أَن يَحْضُرُونِ",
          "ayah": "[المؤمنون - 97-98].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name":
              "رَبَّنَا آمَنَّا فَاغْفِرْ لَنَا وَارْحَمْنَا وَأَنتَ خَيْرُ الرَّاحِمِينَ",
          "ayah": " [المؤمنون - 109].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
        {
          "start": "",
          "name": "رَّبِّ اغْفِرْ وَارْحَمْ وَأَنتَ خَيْرُ الرَّاحِمِينَ",
          "ayah": " [المؤمنون - 118].",
          "meaning": "الْأدْعِيَةُ القرآنية",
          "initialCount": 1,
          "currentCount": 1,
        },
      ];
      for (var duaa in initialAdayaQuraniya) {
        await db.insert(
          adayaQuraniyaTableName,
          duaa,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('Initial AdayaQuraniya populated successfully.');
    }

    // <--- **Adayah Nabuia data population - جديد**
    final countAdayahNabuia = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $adayahNabuiaTableName'),
    );
    if (countAdayahNabuia == 0) {
      print('AdayahNabuia table is empty, populating...');
      final List<Map<String, dynamic>> initialAdayahNabuia = [
        {
          "start": "",
          "name":
              "اللَّهُمَّ أنَْتَ رَبيِّ لَا إلِهََ إلَِّا أنَتَ، خَلَقْتنَيِ وَأنََا عَبدُْكَ، وَأنََا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.",
          "ayah": "رواه البخاري (6306)",
          "mang":
              " عن شداد بن أوس وقد وصف النبي هذا الدعاء بأنه سيد الاستغفار.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا.",
          "ayah": "أخرجه أبو داود برقم: (5072).",
          "mang":
              "قال رسول الله صلى الله عليه وسلم: «مَنْ قَالَ حِينَ يُصْبِحُ وَحِينَ يُمْسِي: رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ نَبِيًّا، كَانَ حَقًّا عَلَى اللَّهِ أَنْ يُرْضِيَهُ»",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ.",
          "ayah": "أخرجه الترمذي برقم: (3391).",
          "mang": "دعاء يُقال في الصباح والمساء.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ، وَعَلَى كَلِمَةِ الْإِخْلَاصِ، وَعَلَى دِينِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ، وَعَلَى مِلَّةِ أَبِينَا إِبْرَاهِيمَ حَنِيفًا مُسْلِمًا، وَمَا كَانَ مِنَ الْمُشْرِكِينَ.",
          "ayah": "صحيح الجامع (871)",
          "mang": "دعاء يُقال في الصباح والمساء.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ: عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ.",
          "ayah": "رواه مسلم (2726)",
          "mang": "تقال ثلاث مرات إذا أصبح.",
          "currentCount": 3,
          "initialCount": 3,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ: فِي دِينِي وَدُنْيَايَ، وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي، وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي.",
          "ayah": "أخرجه أبو داود برقم: (5074).",
          "mang": "دعاء شامل للحفظ والعافية.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ، فَاطِرَ السَّمَاوَاتِ وَالْأَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيكَهُ، أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ، أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهِ، وَأَنْ أَقْتَرِفَ عَلَى نَفْسِي سُوءًا، أَوْ أَجُرَّهُ إِلَى مُسْلِمٍ.",
          "ayah": "أخرجه الترمذي برقم: (3392).",
          "mang": "دعاء يقال عند النوم، وإذا أصبح، وإذا أمسى.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ، وَهُوَ السَّمِيعُ الْعَلِيمُ.",
          "ayah": "صحيح الترمذي (3388)",
          "mang": "تقال ثلاث مرات في الصباح والمساء، ومن قالها لم يضره شيء.",
          "currentCount": 3,
          "initialCount": 3,
        },
        {
          "start": "",
          "name":
              "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.",
          "ayah": "رواه مسلم (2709)",
          "mang": "تقال ثلاث مرات في المساء، ومن قالها لم يضره شيء.",
          "currentCount": 3,
          "initialCount": 3,
        },
        {
          "start": "",
          "name":
              "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ.",
          "ayah":
              "رواه الحاكم (1/545) وحسنه الألباني في صحيح الترغيب والترهيب (661)",
          "mang": "دعاء شامل لإصلاح الحال وعدم التخلي عن العبد.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ، اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ فِي الْعَالَمِينَ إِنَّكَ حَمِيدٌ مَجِيدٌ.",
          "ayah": "رواه البخاري ومسلم.",
          "mang": "تقال في الصلاة الإبراهيمية بعد التشهد الأخير.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي.",
          "ayah": "رواه الترمذي (3513)",
          "mang": "يقال في ليلة القدر.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى.",
          "ayah": "رواه مسلم (2721)",
          "mang": "دعاء لطلب الهداية والتقوى والعفاف والغنى.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ آتِ نَفْسِي تَقْوَاهَا، وَزَكِّهَا أَنْتَ خَيْرُ مَنْ زَكَّاهَا، أَنْتَ وَلِيُّهَا وَمَوْلَاهَا.",
          "ayah": "رواه مسلم (2722)",
          "mang": "دعاء لطلب تقوى النفس وتزكيتها.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ، وَمِنْ عَذَابِ الْقَبْرِ، وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ، وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ.",
          "ayah": "رواه مسلم (588)",
          "mang": "يقال بعد التشهد الأخير قبل السلام.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ.",
          "ayah": "رواه البخاري (6369)",
          "mang": "دعاء لطلب العون من الهم والحزن والعجز والكسل.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ.",
          "ayah": "رواه الترمذي (3563) وحسنه الألباني",
          "mang": "دعاء لطلب الرزق الحلال والاستغناء عن الخلق.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ رَبَّ السَّمَوَاتِ وَرَبَّ الْأَرْضِ وَرَبَّ الْعَرْشِ الْعَظِيمِ، رَبَّنَا وَرَبَّ كُلِّ شَيْءٍ، فَالِقَ الْحَبِّ وَالنَّوَى، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالْفُرْقَانِ، أَعُوذُ بِكَ مِنْ شَرِّ كُلِّ شَيْءٍ أَنْتَ آخِذٌ بِنَاصِيَتِهِ، اللَّهُمَّ أَنْتَ الْأَوَّلُ فَلَيْسَ قَبْلَكَ شَيْءٌ، وَأَنْتَ الْآخِرُ فَلَيْسَ بَعْدَكَ شَيْءٌ، وَأَنْتَ الظَّاهِرُ فَلَيْسَ فَوْقَكَ شَيْءٌ، وَأَنْتَ الْبَاطِنُ فَلَيْسَ دُونَكَ شَيْءٌ، اقْضِ عَنَّا الدَّيْنَ وَأَغْنِنَا مِنَ الْفَقْرِ.",
          "ayah": "رواه مسلم (2713)",
          "mang": "دعاء يقال عند النوم.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ.",
          "ayah": "رواه مسلم (2695)",
          "mang": "من الأذكار الجامعة التي يستحب الإكثار منها.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ إني أعوذ بك من العجز والكسل والجبن والبخل والهرم وعذاب القبر، اللَّهُمَّ آتِ نفسي تقواها وزكها أنت خير من زكاها، أنت وليها ومولاها، اللَّهُمَّ إني أعوذ بك من علم لا ينفع ومن قلب لا يخشع ومن نفس لا تشبع ومن دعوة لا يستجاب لها.",
          "ayah": "رواه مسلم (2722)",
          "mang": "دعاء جامع للتحصين وطلب الخير.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ اغْفِرْ لِي خَطِيئَتِي وَجَهْلِي وَإِسْرَافِي فِي أَمْرِي وَمَا أَنْتَ أَعْلَمُ بِهِ مِنِّي، اللَّهُمَّ اغْفِرْ لِي جِدِّي وَهَزْلِي وَخَطَئِي وَعَمْدِي وَكُلُّ ذَلِكَ عِنْدِي.",
          "ayah": "رواه البخاري (6399)",
          "mang": "دعاء لطلب المغفرة من جميع الذنوب.",
          "currentCount": 1,
          "initialCount": 1,
        },
        {
          "start": "",
          "name":
              "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، عَلَيْكَ تَوَكَّلْتُ وَأَنْتَ رَبُّ الْعَرْشِ الْعَظِيمِ، مَا شَاءَ اللَّهُ كَانَ وَمَا لَمْ يَشَأْ لَمْ يَكُنْ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ، أَعْلَمُ أَنَّ اللَّهَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، وَأَنَّ اللَّهَ قَدْ أَحَاطَ بِكُلِّ شَيْءٍ عِلْمًا، اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ شَرِّ نَفْسِي وَمِنْ شَرِّ كُلِّ دَابَّةٍ أَنْتَ آخِذٌ بِنَاصِيَتِهَا، إِنَّ رَبِّي عَلَى صِرَاطٍ مُسْتَقِيمٍ.",
          "ayah": "رواه أبو داود (5074) والنسائي",
          "mang": "دعاء التحصين من الشرور.",
          "currentCount": 1,
          "initialCount": 1,
        },
      ];
      for (var duaa in initialAdayahNabuia) {
        await db.insert(
          adayahNabuiaTableName,
          duaa,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('Initial AdayahNabuia populated successfully.');
    }
    // <--- **نهاية إضافة Adayah Nabuia data population**

    // You can add more initial data for other tables here if needed.
  }

  // General functions for any dhikr table (unchanged, but now supports AdayahNabuia)
  Future<int> insertDhikr(String tableName, Map<String, dynamic> dhikr) async {
    final db = await database;
    return await db.insert(
      tableName,
      dhikr,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllDhikr(String tableName) async {
    final db = await database;
    return await db.query(tableName, orderBy: 'id ASC');
  }

  Future<int> updateDhikrCount(String tableName, int id, int newCount) async {
    final db = await database;
    return await db.update(
      tableName,
      {'currentCount': newCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetDhikrCountToInitial(String tableName, int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      columns: ['initialCount'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      final int initialCount = result.first['initialCount'] as int;
      await db.update(
        tableName,
        {'currentCount': initialCount},
        where: 'id = ?',
        whereArgs: [id],
      );
      print(
        'Dhikr with ID $id count reset to its initial value in $tableName.',
      );
    }
  }

  Future<void> resetAllDhikrCountsToInitial(String tableName) async {
    final db = await database;
    final List<Map<String, dynamic>> adkarToReset = await db.query(tableName);

    await db.transaction((txn) async {
      for (var dhikr in adkarToReset) {
        final id = dhikr['id'] as int;
        final initialCount = dhikr['initialCount'] as int;
        await txn.update(
          tableName,
          {'currentCount': initialCount},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
    print(
      'All dhikr counts for table "$tableName" reset to initial counts in DB.',
    );
  }

  Future<void> deleteDatabaseFile() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    if (await databaseFactory.databaseExists(path)) {
      await deleteDatabase(path);
      _database = null;
      print('Database file deleted.');
    }
  }

  // Asma Allah functions (unchanged)
  Future<int> insertAsmaAllah(Map<String, dynamic> asmaAllah) async {
    final db = await database;
    return await db.insert(
      asmaAllahTableName,
      asmaAllah,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllAsmaAllah() async {
    final db = await database;
    return await db.query(asmaAllahTableName, orderBy: 'id ASC');
  }

  // Fadel Al-Duaa specific functions (unchanged)
  Future<int> insertFadelAlDuaa(Map<String, dynamic> duaaData) async {
    final db = await database;
    return await db.insert(
      fadelAlDuaaTableName,
      duaaData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllFadelAlDuas() async {
    final db = await database;
    return await db.query(fadelAlDuaaTableName, orderBy: 'id ASC');
  }

  // Ruqyah specific functions (unchanged)
  Future<int> insertRuqyah(Map<String, dynamic> ruqyahData) async {
    final db = await database;
    return await db.insert(
      ruqyahsTableName,
      ruqyahData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRuqyahsByType(String type) async {
    final db = await database;
    return await db.query(
      ruqyahsTableName,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'id ASC',
    );
  }

  // Adaya Quraniya specific functions
  Future<List<Map<String, dynamic>>> getAllAdayaQuraniya() async {
    final db = await database;
    return await db.query(adayaQuraniyaTableName, orderBy: 'id ASC');
  }

  Future<int> updateAdayaQuraniyaCount(int id, int newCount) async {
    final db = await database;
    return await db.update(
      adayaQuraniyaTableName,
      {'currentCount': newCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetAdayaQuraniyaCountToInitial(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      adayaQuraniyaTableName,
      columns: ['initialCount'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      final int initialCount = result.first['initialCount'] as int;
      await db.update(
        adayaQuraniyaTableName,
        {'currentCount': initialCount},
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Adaya Quraniya with ID $id count reset to its initial value.');
    }
  }

  Future<List<Map<String, dynamic>>> getAllAdayahNabuia() async {
    final db = await database;
    return await db.query(adayahNabuiaTableName, orderBy: 'id ASC');
  }

  Future<int> updateAdayahNabuiaCount(int id, int newCount) async {
    final db = await database;
    return await db.update(
      adayahNabuiaTableName,
      {'currentCount': newCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetAdayahNabuiaCountToInitial(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      adayahNabuiaTableName,
      columns: ['initialCount'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      final int initialCount = result.first['initialCount'] as int;
      await db.update(
        adayahNabuiaTableName,
        {'currentCount': initialCount},
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Adayah Nabuia with ID $id count reset to its initial value.');
    }
  }

  // دالة لإضافة أو تحديث الحديث
  Future<void> insertOrUpdateHadith(Hadith hadith) async {
    final db = await instance.database;
    await db.insert(
      hadithOfTheDayTableName,
      hadith.toJson(),
      conflictAlgorithm:
          ConflictAlgorithm
              .replace, // استبدال الحديث إذا كان موجودًا بنفس الـ ID
    );
    print("Hadith with ID ${hadith.id} inserted/updated in the database.");
  }

  // دالة لجلب الحديث
  Future<Hadith?> getHadith() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      hadithOfTheDayTableName,
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return Hadith(
        id: map['id'] as int,
        text: map['text'] as String,
        source: map['source'] as String,
      );
    }
    return null;
  }
}
