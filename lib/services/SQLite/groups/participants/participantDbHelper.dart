import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ParticipantDbHelper{
   ParticipantDbHelper._constructor();

   static const tableName = 'Participants';

   static const columnParticipantUserId = 'part_userId';
    static const columnParticipantAutoId = 'userId';
   static const columnParticipantGrpId = 'part_grpId';
   static const columnParticipantAddedBy = 'part_added_by_Id';
 factory ParticipantDbHelper() {
    return instance;
  }
  static final ParticipantDbHelper instance = ParticipantDbHelper._constructor();

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
    Database db = await instance.database;
     tableCreate(db);
    return db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
     tableCreate(db);
    return db.query(tableName);
  }
    Future<List<Map<String, dynamic>>> queryByGroup(String grpId) async {
    Database db = await instance.database;
     tableCreate(db);
    return db.query(tableName,where: "$columnParticipantGrpId=?",whereArgs: [grpId]);
  }
    Future<Map<String, dynamic>?> queryByParticipantAndGroup(String user,String grp) async {
    Database db = await instance.database;
     tableCreate(db);
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnParticipantUserId = ? AND $columnParticipantGrpId = ?', whereArgs: [user,grp]);
    return results.isEmpty ? null : results.single;
  }

  Future<Map<String, dynamic>> queryById(int id) async {
    Database db = await instance.database;
     tableCreate(db);
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnParticipantAutoId = ?', whereArgs: [id]);

    return results.single;
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    tableCreate(db);
    return db.update(
      tableName,
      row,
      where: '$columnParticipantAutoId = ?',
      whereArgs: [row[columnParticipantAutoId]],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return db.delete(tableName, where: '$columnParticipantAutoId = ?', whereArgs: [id]);
  }
  tableCreate(Database db)async{
       await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
      $columnParticipantAutoId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnParticipantGrpId  TEXT NOT NULL,
      $columnParticipantAddedBy  TEXT NOT NULL,
      $columnParticipantUserId TEXT  NOT NULL)
      ''');
  }
}