import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'feed_formulation.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE formulations(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, age TEXT, amount INTEGER, formulation TEXT)',
        );
      },
    );
  }

  Future<void> insertFormulation(String type, String age, int amount, String formulation) async {
    final db = await database;
    await db.insert(
      'formulations',
      {
        'type': type,
        'age': age,
        'amount': amount,
        'formulation': formulation,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFormulations() async {
    final db = await database;
    return await db.query('formulations');
  }

  Future<void> deleteFormulation(int id) async {
    final db = await database;
    await db.delete(
      'formulations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
