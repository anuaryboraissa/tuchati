import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LogoutHelper {
  LogoutHelper._internal();
  factory LogoutHelper() {
    return _instance;
  }
  static final LogoutHelper _instance = LogoutHelper._internal();

  static const _dbName = 'tuchati.db';
  static const _dbVersion = 1;

  Database? _database;

  Future get database async {
   dropDatabase();
  }

  dropDatabase()async{
    String directory = await getDatabasesPath();
      String path = join(directory, _dbName);
      databaseFactory.deleteDatabase(path).then((value) {
        print("database $_dbName deleted successfully..............%%%%%%%%%%%%%%%%%%%%%%%##############");
      });
  }
}
