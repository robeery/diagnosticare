import 'dart:developer';

import 'package:diagnosticare/test_buttons/base_button.dart';
import 'package:diagnosticare/test_buttons/model/test_result_cases.dart';
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

  late List<TestData> testDataList;

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
    testDataList = List.filled(
      keys.length + 1,
      TestData(
        id: 0,
        name: "name_default",
        testResult: "test_result_default",
        additionalData: "additional_data_default",
      ),
    );

    // Check if data is already inserted (optional)
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM TestData'),
    );
    if (count != null && count > 0) return;

    int i = 1;
    // Populate the table
    for (var key in keys) {
      final state = key.currentState;
      if (state != null) {
        final testData = TestData(
          id: state.widget.testId, // or generate your own ID
          name: state.widget.buttonName,
          testResult: 'TestResultCases.testNotDone', // Replace as needed
          additionalData: '-',
        );
        testDataList[i++] = testData;
        await insertTestData(testData);
      }
    }
  }

  Future<void> initializeTestDataList(
    List<GlobalKey<BaseButtonState>> keys,
  ) async {
    final db = await database;

    // Check if the table is empty
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM TestData'),
    );

    if (count == null || count == 0) {
      // If empty, initialize with default values
      testDataList = List.filled(
        keys.length + 1,
        TestData(
          id: 0,
          name: "name_default",
          testResult: "test_result_default",
          additionalData: "additional_data_default",
        ),
      );
      print("⚠️ DB is empty. testDataList filled with default entries.");
      return;
    }

    // Otherwise, load data from DB
    final List<Map<String, dynamic>> maps = await db.query('TestData');

    testDataList = maps.map((map) => TestData.fromMap(map)).toList();
    testDataList.insert(
      0,
      TestData(
        id: 0,
        name: 'Placeholder',
        testResult: 'D',
        additionalData: '-',
      ), // Customize this default as needed
    );
    print('✅ testDataList initialized with ${testDataList.length} entries.');
  }

  void printTestDataList() {
    log("TestDataList: ");
    for (int i = 0; i < testDataList.length; i++) {
      print(
        "Id: ${testDataList[i].id}; Name: ${testDataList[i].name}; TestResult: ${testDataList[i].testResult}; AdditionalData: ${testDataList[i].additionalData};",
      );
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
    log("Database entries:");
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

  Future<void> updateTestResultById(int id, String newResult) async {
    final db = await database;
    final rowsUpdated = await db.update(
      'TestData',
      {'testResult': newResult},
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rowsUpdated == 0) {
      print('⚠️ No TestData found with id: $id');
    } else {
      print('✅ Updated testResult for id: $id to "$newResult"');
    }

    testDataList[id].testResult = newResult;
    log(testDataList[id].testResult);
  }

  Future<void> deleteAllTestData() async {
    final db = await database;
    await db.delete('TestData');
    for (int i = 1; i < testDataList.length; i++) {
      testDataList[i].additionalData = '-';
      testDataList[i].testResult = 'TestResultCases.testNotDone';
    }
    print('🗑️ All TestData entries deleted.');
  }
}
