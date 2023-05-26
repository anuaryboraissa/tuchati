
import '../databaseHelper/dirsmsDetails.dart';
import '../models/msgDetails.dart';

class DirectSmsDetailsHelper {
  final DirectSmsDetailsDBHelper _dbHelper = DirectSmsDetailsDBHelper();

  Future<int> insert(DirMsgDetails user) async {
    return _dbHelper.insert(toMap(user));
  }

  Future<DirMsgDetails?> queryById(String id) async {
    return fromMap(await _dbHelper.queryById(id));
  }

  Future<List<DirMsgDetails?>> queryAll() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryAll();
    return reportMapList.map((e) => fromMap(e)).toList();
  }
    Future<List<DirMsgDetails?>> queryChats() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryByField();
    return reportMapList.map((e) => fromMap(e)).toList();
  }
  //   Future<List<DirMsgDetails>> queryUserToMe(String log) async {
  //   List<Map<String, dynamic>> reportMapList = await _dbHelper.queryUserDetails(log);
  //   return reportMapList.map((e) => fromMap(e)).toList();
  // }

  Future<int> delete(int id) async {
    return _dbHelper.delete(id);
  }

  Future<int> update(DirMsgDetails myUser) async {
    return _dbHelper.update(toMap(myUser));
  }

  Map<String, dynamic> toMap(DirMsgDetails user) {
    return {
      DirectSmsDetailsDBHelper.columnName: user.name, // TODO get project id
      DirectSmsDetailsDBHelper.columDate: user.date,
      DirectSmsDetailsDBHelper.columnLastMsg: user.lastMessage,
      DirectSmsDetailsDBHelper.columnTime: user.time, // TODO get project id
      DirectSmsDetailsDBHelper.columnUnseen: user.unSeen,
      DirectSmsDetailsDBHelper.columnUserId: user.userId
    };
  }

  DirMsgDetails? fromMap(Map<String, dynamic>? map) {
    return map==null?null: DirMsgDetails(
        name: map[DirectSmsDetailsDBHelper.columnName],
        date: map[DirectSmsDetailsDBHelper.columDate],
        lastMessage: map[DirectSmsDetailsDBHelper.columnLastMsg],
        time: map[DirectSmsDetailsDBHelper.columnTime],
        unSeen: map[DirectSmsDetailsDBHelper.columnUnseen],
        userId: map[DirectSmsDetailsDBHelper.columnUserId]);
  }
}
