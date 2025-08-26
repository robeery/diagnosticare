import 'package:diagnosticare/test_buttons/base_button.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TestData {
  int? id;
  String name;
  String testResult;
  String additionalData;

  TestData({
    this.id,
    required this.name,
    required this.testResult,
    required this.additionalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'testResult': testResult,
      'additionalData': additionalData,
    };
  }

  factory TestData.fromMap(Map<String, dynamic> map) {
    return TestData(
      id: map['id'],
      name: map['name'],
      testResult: map['testResult'],
      additionalData: map['additionalData'],
    );
  }
}

class TestDataManager {
  //singleton implementation
  static final TestDataManager _instance = TestDataManager._internal();
  factory TestDataManager() => _instance;
  TestDataManager._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'test_data.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE TestData (
            id INTEGER PRIMARY KEY,
            name TEXT,
            testResult TEXT,
            additionalData TEXT
          )
          ''');
      },
    );
  }

  Future<void> initializeWithButtonKeys(
    List<GlobalKey<BaseButtonState>> keys,
  ) async {
    final db = await database;

    // Check if data is already inserted (optional)
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM TestData'),
    );
    if (count != null && count > 0) return;

    // Populate the table
    for (var key in keys) {
      final state = key.currentState;
      if (state != null) {
        final testData = TestData(
          id: state.widget.testId, // or generate your own ID
          name: state.widget.buttonName,
          testResult: 'testNotDone', // Replace as needed
          additionalData: '-',
        );

        await insertTestData(testData);
      }
    }
  }

  // Insert a new TestData
  Future<int> insertTestData(TestData data) async {
    final db = await database;
    return await db.insert(
      'TestData',
      data.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all TestData entries
  Future<List<TestData>> getAllTestData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('TestData');
    return List.generate(maps.length, (i) => TestData.fromMap(maps[i]));
  }

  Future<void> printAllTestData() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('TestData');

    if (result.isEmpty) {
      print(' No test data found in the database.');
      return;
    }

    print(' TestData entries in the database:');
    for (var row in result) {
      final data = TestData.fromMap(row);
      print(
        ' ID: ${data.id}, Name: ${data.name}, Result: ${data.testResult}, Additional: ${data.additionalData}',
      );
    }
  }

  Future<void> deleteAllTestData() async {
    final db = await database;
    await db.delete('TestData');
    print('🗑️ All TestData entries deleted.');
  }
}
