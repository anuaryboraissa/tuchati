import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DirectSmsDetailsDBHelper {
  DirectSmsDetailsDBHelper._internal();

  static const tableName = 'Details';

   static const columnUserId = 'userId';
   static const columnId = 'Id';
  static const columnName = 'Name';
  static const columDate= 'date';
  static const columnTime = 'time';
  static const columnUnseen = 'unSeen';
  static const columnLastMsg = 'lastSms';

 factory DirectSmsDetailsDBHelper() {
    return _instance;
  }
  static final DirectSmsDetailsDBHelper _instance = DirectSmsDetailsDBHelper._internal();

  static const _dbName = 'tuchati.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String directory = await getDatabasesPath();
    String path = join(directory, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future _onCreate(Database db, int version) async {
     tableCreate(db);
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await _instance.database;
    tableCreate(db);
    return db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await _instance.database;
    tableCreate(db);
    return db.query(tableName,orderBy: columDate);
  }

  Future<List<Map<String, dynamic>>> queryByField() async {
    Database db = await _instance.database;
    tableCreate(db);
    return db.rawQuery("SELECT * FROM $tableName WHERE $columnUnseen > ?",[0]);
  }
  Future<Map<String, dynamic>?> queryById(String id) async {
        Database db = await _instance.database;
        // dropTable(db);
        tableCreate(db);
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnUserId = ?', whereArgs: [id]);
    return results.isEmpty?null: results.single;
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await _instance.database;
    tableCreate(db);
    return db.update(
      tableName,
      row,
      where: '$columnUserId = ?',
      whereArgs: [row[columnUserId]],
    );
  }

  Future<int> delete(int id) async {
    Database db = await _instance.database;
    tableCreate(db);
    return db.delete(tableName, where: '$columnUserId = ?', whereArgs: [id]);
  }
  dropTable(Database db)async{
    await db.execute("DROP TABLE IF EXISTS $tableName");
    print("table dropped success *******************");
  }
  tableCreate(Database db)async{
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
      $columnUserId TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnTime TEXT  NOT NULL,
      $columDate TEXT NOT NULL,
      $columnLastMsg TEXT NOT NULL,
      $columnUnseen INTEGER NOT NULL)
      ''');
  }
}