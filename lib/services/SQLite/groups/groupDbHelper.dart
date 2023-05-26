import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GroupDbHelper{
    GroupDbHelper._internal();

//   groups;
  static const tableName = 'Groups';

  static const columnGrpId = 'grpId';
  static const columnCreated = 'created';
  static const columnGrpName = 'name';
  static const columnGrpDesc = 'description';
  static const columnGrpOwner = 'owner';


//admins
   static const tableAdmins = 'Admins';

   static const columnAdminId = 'userId';
   static const columnAdminAutoId = 'Id';
   static const columnAdminGrpId = 'grpId';
//participants
   static const tableParticipants = 'Participants';

   static const columnParticipantUserId = 'part_userId';
    static const columnParticipantAutoId = 'userId';
   static const columnParticipantGrpId = 'part_grpId';
   static const columnParticipantAddedBy = 'part_added_by_Id';

 factory GroupDbHelper() {
    return _instance;
  }
  static final GroupDbHelper _instance  = GroupDbHelper._internal();

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
  // Future<List<Map<String, dynamic>>> queryByField(String user,String looged) async {
  //   Database db = await _instance.database;
  //   tableCreate(db);
  //   return db.rawQuery("SELECT * FROM $tableName WHERE ($columnSender=? and $columnReceiver=?) or ($columnSender=? and $columnReceiver=?)", [looged,user,user,looged]);
  // }
  // Future<List<Map<String, dynamic>>> queryMsgDetails(String user) async {
  //   Database db = await _instance.database;
  //   tableCreate(db);
  //   return db.rawQuery("SELECT * FROM $tableName as m INNER JOIN Users as u ON m.$columnSender=u.userId WHERE $columnSeen='0' and m.$columnSender=?",[user]);
  // }
  Future<Map<String, dynamic>?> queryById(int id) async {
    Database db = await _instance.database;
    tableCreate(db);
    List<Map<String, dynamic>> results =
        await db.query(tableName, where: '$columnGrpId = ?', whereArgs: [id]);

    return results.isEmpty?null: results.single;
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await _instance.database;
    tableCreate(db);
    return db.update(
      tableName,
      row,
      where: '$columnGrpId = ?',
      whereArgs: [row[columnGrpId]],
    );
  }

  Future<int> delete(int id) async {
    Database db = await _instance.database;
    return db.delete(tableName, where: '$columnGrpId = ?', whereArgs: [id]);
  }
  dropTables(Database db)async{
    await db.execute("DROP TABLE IF EXISTS $tableName");
    await db.execute("DROP TABLE IF EXISTS $tableAdmins");
    await db.execute("DROP TABLE IF EXISTS $tableName");
  }
  tableCreate(Database db)async{
           await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
      $columnGrpId INTEGER PRIMARY KEY,
      $columnGrpName  TEXT NOT NULL,
      $columnGrpDesc TEXT  NOT NULL,
      $columnGrpOwner TEXT NOT NULL,
      $columnCreated  TEXT NOT NULL)
      ''');
      await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableAdmins (
      $columnAdminAutoId TEXT PRIMARY KEY,
      $columnAdminGrpId  TEXT NOT NULL,
      $columnAdminId TEXT  NOT NULL)
      ''');
        await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableParticipants (
      $columnParticipantAutoId TEXT PRIMARY KEY,
      $columnParticipantGrpId  TEXT NOT NULL,
      $columnParticipantAddedBy  TEXT NOT NULL,
      $columnParticipantUserId TEXT  NOT NULL)
      ''');
  }
}