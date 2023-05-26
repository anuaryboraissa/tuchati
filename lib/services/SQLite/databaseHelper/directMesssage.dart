import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DirMsgsDBHelper {
  DirMsgsDBHelper._internal();

  static const tableName = 'Messages';

  static const columnId = 'id';
  static const columnMsg = 'msg';
  static const columnSender = 'sender';
  static const columnReceiver = 'receiver';
  static const columnTime = 'time';
  static const columnDate = 'date';
  static const columnFileName = 'fileName';
  static const columnSeen = 'seen';
  static const columnMsgFile = 'msgFile';
   static const columnFileSize = 'fileSize';
  static const columnReplied = 'replied';
  static const columnRepliedMdgId = 'repliedMdgId';


    static const tableName2 = 'Users';
   static const columnUserId = 'userId';
  static const columnFirstName = 'firstName';
  static const columLastName= 'lastName';
  static const columnPhone = 'phone';
  static const columnProfile = 'profile';
  static const columnAbout = 'about';
  static const columnCreated = 'created';
 factory DirMsgsDBHelper() {
    return _instance;
  }
  static final DirMsgsDBHelper _instance  = DirMsgsDBHelper._internal();

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
    return db.query(tableName);
  }
  Future<List<Map<String, dynamic>>> queryByField(String user,String looged) async {
    Database db = await _instance.database;
    tableCreate(db);
    return db.rawQuery("SELECT * FROM $tableName WHERE ($columnSender=? and $columnReceiver=?) or ($columnSender=? and $columnReceiver=?) ORDER BY $columnDate", [looged,user,user,looged]);
  }
  Future<List<Map<String, dynamic>>> queryMsgDetails(String user) async {
    Database db = await _instance.database;
    tableCreate(db);
    return db.rawQuery("SELECT * FROM $tableName as m INNER JOIN Users as u ON m.$columnSender=u.userId WHERE $columnSeen='0' and m.$columnSender=?",[user]);
  }
  Future<Map<String, dynamic>?> queryById(int id) async {
    Database db = await _instance.database;
    tableCreate(db);
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnId = ?', whereArgs: [id]);

    return results.isEmpty?null: results.single;
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await _instance.database;
    tableCreate(db);
    return db.update(
      tableName,
      row,
      where: '$columnId = ?',
      whereArgs: [row[columnId]],
    );
  }

  Future<int> delete(int id) async {
    Database db = await _instance.database;
    return db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }
  tableCreate(Database db)async{
           await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
      $columnId INTEGER PRIMARY KEY,
      $columnMsg  TEXT NOT NULL,
      $columnSender TEXT  NOT NULL,
      $columnReceiver TEXT  NOT NULL,
      $columnTime TEXT NOT NULL,
      $columnDate  TEXT NOT NULL,
      $columnSeen TEXT NOT NULL,
      $columnReplied  TEXT  NOT NULL,
      $columnRepliedMdgId  TEXT  NOT NULL,
      $columnMsgFile  TEXT  NOT NULL,
      $columnFileName  TEXT  NOT NULL,
      $columnFileSize TEXT  NOT NULL)
      ''');
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName2 (
      $columnUserId TEXT PRIMARY KEY,
      $columLastName  TEXT NOT NULL,
      $columnFirstName TEXT  NOT NULL,
      $columnAbout  TEXT NOT NULL,
      $columnCreated TEXT  NOT NULL,
       $columnProfile  TEXT NOT NULL,
      $columnPhone TEXT  NOT NULL)
      ''');
  }
}