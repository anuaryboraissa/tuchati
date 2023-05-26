import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserDBHelper {
  UserDBHelper._internal();

  static const tableName = 'Users';
  static const columnUserId = 'userId';
  static const columnFirstName = 'firstName';
  static const columLastName = 'lastName';
  static const columnPhone = 'phone';
  static const columnProfile = 'profile';
  static const columnAbout = 'about';
  static const columnCreated = 'created';


  static const tableName2 = 'Details';

   static const columnUserId2 = 'userId';
   static const columnId = 'Id';
  static const columnName = 'Name';
  static const columDate= 'date';
  static const columnTime = 'time';
  static const columnUnseen = 'unSeen';
  static const columnLastMsg = 'lastSms';

  factory UserDBHelper() {
    return _instance;
  }
  static final UserDBHelper _instance = UserDBHelper._internal();

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

  Future<List<Map<String, dynamic>>> queryUserDetails(String log) async {
    Database db = await _instance.database;
    return db.rawQuery(
        "SELECT * FROM $tableName AS u INNER JOIN Messages AS m ON u.$columnUserId=m.sender WHERE M.receiver=?",
        [log]);
  }
  Future<List<Map<String, dynamic>>> queryParticipants(int groupId) async {
    Database db = await _instance.database;
    return db.rawQuery(
        "SELECT * FROM $tableName AS u INNER JOIN Participants AS p ON u.userId=p.part_userId INNER JOIN Groups AS g ON g.grpId=p.part_grpId WHERE g.grpId=?",
        [groupId]);
  }

  // Future<List<Map<String, dynamic>>> queryActiveFriends(int days)async{
  //       Database db = await _instance.database;
  //       var format = DateFormat("yyyy-MM-dd HH:mm");
  //       var now = format.format(DateTime.now());
  //        return db.rawQuery(
  //       "SELECT * FROM $tableName AS u INNER JOIN $tableName2 AS a ON u.$columnUserId=a.$columnUserId2 WHERE ${DateTime.parse('a.$columDate').difference(DateTime.parse(now)).inDays} <= ?",[days]
  //       );
  // }

  Future<List<Map<String, dynamic>>> queryAdmins(int groupId) async {
    Database db = await _instance.database;
    return db.rawQuery(
        "SELECT * FROM $tableName AS u INNER JOIN Admins AS a ON u.userId=a.userId INNER JOIN Groups AS g ON g.grpId=a.grpId WHERE g.grpId=?",
        [groupId]);
  }
    Future<Map<String, dynamic>?> queryByFields(String firstName,String lastName,String phone) async {
    Database db = await _instance.database;
      List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnFirstName=? and $columLastName=? and $columnPhone=?', whereArgs: [firstName,lastName,phone]);
        print("result yake ni $phone $results...............................");
    return results.isEmpty ? null : results.single;

  }

  Future<Map<String, dynamic>?> queryById(String id) async {
    Database db = await _instance.database;
    tableCreate(db);
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnUserId = ?', whereArgs: [id]);
    return results.isEmpty ? null : results.single;
  }
    Future<Map<String, dynamic>?> queryByPhone(String phone) async {
    Database db = await _instance.database;
    tableCreate(db);
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnPhone = ?', whereArgs: [phone]);
    return results.isEmpty ? null : results.single;
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
    return db.delete(tableName, where: '$columnUserId = ?', whereArgs: [id]);
  }

  tableCreate(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
      $columnUserId TEXT PRIMARY KEY,
      $columLastName  TEXT NOT NULL,
      $columnFirstName TEXT  NOT NULL,
      $columnAbout  TEXT NOT NULL,
      $columnCreated TEXT  NOT NULL,
       $columnProfile  TEXT NOT NULL,
      $columnPhone TEXT  NOT NULL)
      ''');
       await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName2 (
      $columnUserId2 TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL,
      $columnTime TEXT  NOT NULL,
      $columDate TEXT NOT NULL,
      $columnLastMsg TEXT NOT NULL,
      $columnUnseen INTEGER NOT NULL)
      ''');
  }
}
