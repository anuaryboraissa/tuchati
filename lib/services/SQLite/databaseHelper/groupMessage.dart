import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GroupMsgsDBHelper {
  GroupMsgsDBHelper._constructor();

  static const tableName = 'GroupMessages';

  static const columnId = 'id';
  static const columnMsg = 'msg';
  static const columnSender = 'sender';
  static const columnRepliedMsgSender = 'repliedMsgSender';
  static const columnDate = 'date';
  static const columnFileName = 'fileName';
  static const columnGrpId = 'grpId';
  static const columnMsgFile = 'msgFile';
  static const columnFileSize = 'fileSize';
  static const columnReplied = 'replied';
  static const columnRepliedMdgId = 'repliedMdgId';
  

  static const tableName2 = 'seen';
  static const columnId2 = 'id';
  static const columnMsgId = 'msgId';
  static const columnUserId = 'userId';

  static final GroupMsgsDBHelper instance = GroupMsgsDBHelper._constructor();
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
    Future<List<Map<String, dynamic>>> queryByGroup(String groupId) async {
    Database db = await instance.database;
      tableCreate(db);
    return db.query(tableName,where: "$columnGrpId = ?",whereArgs: [groupId],orderBy: columnDate);
  }

  Future<Map<String, dynamic>?> queryById(int id) async {
    Database db = await instance.database;
   tableCreate(db);
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnId = ?', whereArgs: [id]);
      
    return results.isEmpty?null:results.single;
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    tableCreate(db);
    return db.update(
      tableName,
      row,
      where: '$columnId = ?',
      whereArgs: [row[columnId]],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }
  tableCreate(Database db)async{
        await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnMsg  TEXT NOT NULL,
      $columnSender TEXT  NOT NULL,
      $columnGrpId TEXT  NOT NULL,
      $columnRepliedMsgSender TEXT NOT NULL,
      $columnDate  TEXT NOT NULL,
      $columnReplied  TEXT  NOT NULL,
      $columnRepliedMdgId  TEXT  NOT NULL,
      $columnMsgFile  TEXT  NOT NULL,
      $columnFileName  TEXT  NOT NULL,
      $columnFileSize TEXT  NOT NULL)
      ''');
         await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName2 (
      $columnId2 INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnMsgId  TEXT NOT NULL,
      $columnUserId TEXT  NOT NULL)
      ''');
  }
}