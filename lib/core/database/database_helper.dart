import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';

/// SQLite database helper. Creates three tables:
///  - medical_items : master item list
///  - requests      : request headers with status
///  - request_items : line items belonging to a request
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  /// Open (and lazily create) the database.
  Future<Database> database() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.databaseName);
    _db = await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMedicalItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemName TEXT NOT NULL,
        category TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_medical_items_name
        ON ${AppConstants.tableMedicalItems}(itemName)
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableRequests} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        date TEXT,
        department TEXT,
        requester TEXT,
        signature TEXT,
        status TEXT NOT NULL DEFAULT 'draft',
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableRequestItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        requestId INTEGER NOT NULL,
        itemId INTEGER,
        itemName TEXT NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        orderIndex INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (requestId) REFERENCES ${AppConstants.tableRequests}(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_request_items_request
        ON ${AppConstants.tableRequestItems}(requestId)
    ''');
  }

  /// Reset (drop & recreate) all tables — used by "replace" import mode.
  Future<void> clearMedicalItems() async {
    final db = await database();
    await db.delete(AppConstants.tableMedicalItems);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
