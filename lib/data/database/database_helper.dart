// data/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'adkar_database.db';
  static const int dbVersion = 2; // **تم تحديث إصدار قاعدة البيانات إلى 2**

  // أسماء الجداول الثابتة لكل فئة أذكار
  static const String morningAdkarTableName = 'MorningAdkar';
  static const String eveningAdkarTableName = 'EveningAdkar';
  static const String adkarSalatTableName = 'AdkarSalat'; // **اسم الجدول الجديد لأذكار الصلاة**

  // Getter للوصول إلى قاعدة البيانات (Singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // تهيئة قاعدة البيانات وفتحها
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // سيتم استدعاؤها إذا قمنا بترقية الإصدار لاحقًا
    );
  }

  // إنشاء الجداول لأول مرة عند تهيئة قاعدة البيانات
  Future _onCreate(Database db, int version) async {
    // إنشاء جدول أذكار الصباح
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
    print('Database table "$morningAdkarTableName" created.');

    // إنشاء جدول أذكار المساء
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
    print('Database table "$eveningAdkarTableName" created.');

    // **إنشاء جدول أذكار الصلاة الجديد**
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
    print('Database table "$adkarSalatTableName" created.');
  }

  // ترقية قاعدة البيانات (إذا قمت بتغيير هيكل الجدول في المستقبل)
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Database upgrading from version $oldVersion to $newVersion');
    // إذا كان الإصدار القديم أقل من الإصدار الجديد، قم بتطبيق التغييرات.
    // في هذا السيناريو، نقوم بإسقاط جميع الجداول ثم إعادة إنشائها.
    // هذا مفيد في مرحلة التطوير لإعادة تعيين هيكل قاعدة البيانات بسهولة.
    // في بيئة الإنتاج، قد تحتاج إلى منطق ترحيل أكثر دقة (مثل ALTER TABLE).
    if (oldVersion < newVersion) {
      await db.execute("DROP TABLE IF EXISTS $morningAdkarTableName;");
      await db.execute("DROP TABLE IF EXISTS $eveningAdkarTableName;");
      await db.execute("DROP TABLE IF EXISTS $adkarSalatTableName;"); // **حذف جدول أذكار الصلاة عند الترقية**
      await _onCreate(db, newVersion); // ثم إعادة إنشاء الجداول بالهيكل الجديد
    }
  }

  // --- دوال عامة للاستخدام مع أي جدول أذكار ---

  // إدخال ذكر جديد في الجدول المحدد
  Future<int> insertDhikr(String tableName, Map<String, dynamic> dhikr) async {
    final db = await database;
    return await db.insert(
      tableName,
      dhikr,
      // إذا كان هناك تعارض في الـ ID، استبدل السجل القديم بالجديد
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // جلب جميع الأذكار من الجدول المحدد
  Future<List<Map<String, dynamic>>> getAllDhikr(String tableName) async {
    final db = await database;
    return await db.query(
      tableName,
      orderBy: 'id ASC', // لضمان ترتيب ثابت
    );
  }

  // تحديث عداد ذكر معين في الجدول المحدد
  Future<int> updateDhikrCount(
      String tableName, int id, int newCount) async {
    final db = await database;
    return await db.update(
      tableName,
      {'currentCount': newCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // إعادة تعيين عداد ذكر محدد إلى قيمته الأولية في الجدول المحدد
  Future<void> resetDhikrCountToInitial(String tableName, int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      tableName,
      columns: ['initialCount'], // نحتاج فقط القيمة الأولية
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
      print('Dhikr with ID $id count reset to its initial value in $tableName.');
    }
  }

  // إعادة تعيين جميع عدادات الأذكار إلى قيمها الأولية في الجدول المحدد
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
    print('All dhikr counts for table "$tableName" reset to initial counts in DB.');
  }

  // دالة لحذف ملف قاعدة البيانات بالكامل (لأغراض الاختبار أو إعادة الضبط)
  Future<void> deleteDatabaseFile() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);
    if (await databaseFactory.databaseExists(path)) {
      await deleteDatabase(path);
      _database = null; // إعادة تعيين الـ instance بعد الحذف
      print('Database file deleted.');
    }
  }
}