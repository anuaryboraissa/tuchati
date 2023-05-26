import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AdminDbHelper{
   AdminDbHelper._constructor();

  static const tableName = 'Admins';

   static const columnAdminId = 'userId';
   static const columnAdminAutoId = 'Id';
   static const columnAdminGrpId = 'grpId';
factory AdminDbHelper() {
    return instance;
  }
  static final AdminDbHelper instance = AdminDbHelper._constructor();

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
    Future<List<Map<String, dynamic>>> queryByGroup(String grpId) async {
    Database db = await instance.database;
     tableCreate(db);
    return db.query(tableName,where: "$columnAdminGrpId=?",whereArgs: [grpId]);
  }
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
     tableCreate(db);
    return db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
     tableCreate(db);
    return db.query(tableName);
  }

  Future<Map<String, dynamic>> queryById(int id) async {
    Database db = await instance.database;
     tableCreate(db);
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnAdminId = ?', whereArgs: [id]);

    return results.single;
  }
  Future<Map<String, dynamic>?> queryByAdminAndGroup(String user,String grp) async {
    Database db = await instance.database;
     tableCreate(db);
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnAdminId = ? AND $columnAdminGrpId = ?', whereArgs: [user,grp]);
    return results.isEmpty ? null : results.single;
  }
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    tableCreate(db);
    return db.update(
      tableName,
      row,
      where: '$columnAdminId = ?',
      whereArgs: [row[columnAdminId]],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return db.delete(tableName, where: '$columnAdminId = ?', whereArgs: [id]);
  }
  tableCreate(Database db)async{
     await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
      $columnAdminAutoId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnAdminGrpId  TEXT NOT NULL,
      $columnAdminId TEXT  NOT NULL)
      ''');
  }
}