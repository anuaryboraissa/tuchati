import 'package:tuchati/services/SQLite/databaseHelper/directMesssage.dart';
import 'package:tuchati/services/SQLite/models/dirMessages.dart';

class DirMsgsHelper {
  final DirMsgsDBHelper _dbHelper = DirMsgsDBHelper();

  Future<int> insert(DirectMessage dirMsg) async {
    return _dbHelper.insert(toMap(dirMsg));
  }

  Future<DirectMessage?> queryById(int id) async {
    return fromMap(await _dbHelper.queryById(id));
  }

  Future<List<DirectMessage?>> queryAll() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryAll();
    return reportMapList.map((e) => fromMap(e)).toList();
  }
  Future<List<DirectMessage?>> queryByFields(String user,String logged) async {
    print("logged $logged and user is $user.............");
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryByField(user,logged);
    return reportMapList.map((e) => fromMap(e)).toList();
  }
    Future<List<DirectMessage?>> querySmsDetails(String user) async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryMsgDetails(user);
    return reportMapList.map((e) => fromMap(e)).toList();
  }


  Future<int> delete(int id) async {
    return _dbHelper.delete(id);
  }

  Future<int> update(DirectMessage dirMsg) async {
    return _dbHelper.update(toMap(dirMsg));
  }

  Map<String, dynamic> toMap(DirectMessage dirMsg) {
    return {
      DirMsgsDBHelper.columnId: dirMsg.msgId,
      DirMsgsDBHelper.columnReceiver: dirMsg.receiver,
      DirMsgsDBHelper.columnMsg: dirMsg.msg, // TODO get project id
      DirMsgsDBHelper.columnSender: dirMsg.sender,
      DirMsgsDBHelper.columnSeen: dirMsg.seen,
      DirMsgsDBHelper.columnDate: dirMsg.date, // TODO get project id
      DirMsgsDBHelper.columnReplied: dirMsg.replied,
      DirMsgsDBHelper.columnRepliedMdgId: dirMsg.repliedMsgId,
      DirMsgsDBHelper.columnTime: dirMsg.time, // TODO get project id
      DirMsgsDBHelper.columnMsgFile: dirMsg.msgFile,
      DirMsgsDBHelper.columnFileName: dirMsg.fileName,
      DirMsgsDBHelper.columnFileSize: dirMsg.fileSize, // TODO get project id
    };
  }

  DirectMessage? fromMap(Map<String, dynamic>? map) {
    return map==null?null:DirectMessage(
      msgId: map[DirMsgsDBHelper.columnId],
      msg: map[DirMsgsDBHelper.columnMsg],
      sender: map[DirMsgsDBHelper.columnSender],
      seen: map[DirMsgsDBHelper.columnSeen],
      date: map[DirMsgsDBHelper.columnDate],
      fileName: map[DirMsgsDBHelper.columnFileName],
      fileSize: map[DirMsgsDBHelper.columnFileSize],
      msgFile: map[DirMsgsDBHelper.columnMsgFile],
      replied: map[DirMsgsDBHelper.columnReplied],
      repliedMsgId: map[DirMsgsDBHelper.columnRepliedMdgId],
      time: map[DirMsgsDBHelper.columnTime],
      receiver: map[DirMsgsDBHelper.columnReceiver],
    );
  }
}
