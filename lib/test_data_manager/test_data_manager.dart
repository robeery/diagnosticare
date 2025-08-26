import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
}
