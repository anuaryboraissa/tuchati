import 'package:tuchati/services/SQLite/databaseHelper/seenHelper.dart';
import 'package:tuchati/services/SQLite/models/seen.dart';

class SeenHelper {
  final SeenDBHelper _dbHelper = SeenDBHelper.instance;

  Future<int> insert(Seen report) async {
    return _dbHelper.insert(toMap(report));
  }

  Future<Seen> queryById(int id) async {
    return fromMap(await _dbHelper.queryById(id));
  }

  Future<List<Seen>> queryAll() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryAll();
    return reportMapList.map((e) => fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    return _dbHelper.delete(id);
  }

  Future<int> update(Seen seen) async {
    return _dbHelper.update(toMap(seen));
  }

  Map<String, dynamic> toMap(Seen seen) {
    return {
      SeenDBHelper.columnMsgId: seen.msgId, // TODO get project id
      SeenDBHelper.columnUserId: seen.userId
    };
  }

  Seen fromMap(Map<String, dynamic> map) {
    return Seen(msgId: map[SeenDBHelper.columnId],userId: map[SeenDBHelper.columnUserId]);
  }
}
