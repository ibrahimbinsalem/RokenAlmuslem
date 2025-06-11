// data/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;
  static const String dbName = 'adkar_database.db';
  static const int dbVersion = 13; // **INCREMENTED DATABASE VERSION**

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
  static const String asmaAllahTableName = 'AsmaAllah'; // **NEW TABLE NAME**

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
    // Existing tables (unchanged for brevity, assume they are already here)
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
    print('Database table "$adkarAfterSalatTableName" created.');

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
    print('Database table "$adkarAlnomTableName" created.');

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
    print('Database table "$adkarAladanTableName" created.');

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
    print('Database table "$adkarAlmasjidTableName" created.');

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
    print('Database table "$adkarAlastygadTableName" created.');

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
    print('Database table "$adkarHomeTableName" created.');

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
    print('Database table "$adkarAlwswiTableName" created.');

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
    print('Database table "$adkarAlkhlaTableName" created.');

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
    print('Database table "$adkarEatTableName" created.');

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
    print('Database table "$adayahForDeadTableName" created.');

    // **NEW TABLE FOR ASMA ALLAH**
    await db.execute('''
      CREATE TABLE $asmaAllahTableName (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        dis TEXT NOT NULL
      )
    ''');
    print('Database table "$asmaAllahTableName" created.');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Database upgrading from version $oldVersion to $newVersion');
    if (oldVersion < newVersion) {
      // Drop all existing tables (for simplicity in development)
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
      await db.execute(
        "DROP TABLE IF EXISTS $asmaAllahTableName;",
      ); // **DROP NEW TABLE ON UPGRADE**
      await _onCreate(db, newVersion); // Recreate all tables
    }
  }

  // General functions for any dhikr table (unchanged)
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

  // **NEW: Insert Asma Allah functions**
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
}
