import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDatabase {
  Future<String> initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "tuchati.db");
    return path;
  }

  Future<Database> createTable(String qry) async {
    String path = await initDb();
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(qry);
    });
  }

  Future<int> insertData(String qry) async {
    String path = await initDb();
    int res = 0;
    await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      res = await db.rawInsert(qry);
    });
    return res;
  }
  getClient(int id,String table) async {
     String path = await initDb();
      var res=[];
        await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      res = await db.query(table, where: "id = ?", whereArgs: [id]);
    });
    return res.isNotEmpty ? res.first : Null ;
  }
  
getAllClients(String table) async {
        String path = await initDb();
      var res=[];
        await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      res = await db.query(table);
    });
    // List list =
    //     res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return res;
  }
  
getBlockedClients(qry) async {
           String path = await initDb();
      var res=[];
        await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      res = await db.rawQuery(qry);
    });
    // var res = await db.rawQuery(qry);
    // List<Client> list =
    //     res.isNotEmpty ? res.toList().map((c) => Client.fromMap(c)) : null;
    return res;
  }
  // updateClient(String table,String id) async {
  //             String path = await initDb();
  //     var res=[];
  //       await openDatabase(path, version: 1, onOpen: (db) {},
  //       onCreate: (Database db, int version) async {
  //     res = await db.rawQuery(qry);
  //   });
  //   var res = await db.update(table, newClient.toMap(),
  //       where: "id = ?", whereArgs: [id]);
  //   return res;
  // }
}
