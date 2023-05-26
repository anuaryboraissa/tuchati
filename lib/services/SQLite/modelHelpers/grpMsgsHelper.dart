import '../databaseHelper/groupMessage.dart';
import '../models/groupMessages.dart';

class GrpMsgsHelper {
  final GroupMsgsDBHelper _dbHelper = GroupMsgsDBHelper.instance;

  Future<int> insert(GroupMessage grpMsg) async {
    return _dbHelper.insert(toMap(grpMsg));
  }

  Future<GroupMessage?> queryById(int id) async {
    return fromMap(await _dbHelper.queryById(id));
  }

  Future<List<GroupMessage?>> queryAll() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryAll();
    return reportMapList.map((e) => fromMap(e)).toList();
  }
 Future<List<GroupMessage?>> queryByGrp(String grpId) async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryByGroup(grpId);
    return reportMapList.map((e) => fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    return _dbHelper.delete(id);
  }

  Future<int> update(GroupMessage grpMsg) async {
    return _dbHelper.update(toMap(grpMsg));
  }

  Map<String, dynamic> toMap(GroupMessage grpMsg) {
    return {
      GroupMsgsDBHelper.columnId: grpMsg.msgId,
      GroupMsgsDBHelper.columnMsg: grpMsg.msg, // TODO get project id
      GroupMsgsDBHelper.columnSender: grpMsg.sender,
      GroupMsgsDBHelper.columnGrpId: grpMsg.grpId,
      GroupMsgsDBHelper.columnDate: grpMsg.date, // TODO get project id
      GroupMsgsDBHelper.columnReplied: grpMsg.replied,
      GroupMsgsDBHelper.columnRepliedMdgId: grpMsg.repliedMsgId,
      GroupMsgsDBHelper.columnRepliedMsgSender: grpMsg.repliedMsgSender, // TODO get project id
      GroupMsgsDBHelper.columnMsgFile: grpMsg.msgFile,
      GroupMsgsDBHelper.columnFileName: grpMsg.fileName,
      GroupMsgsDBHelper.columnFileSize: grpMsg.fileSize, // TODO get project id
    };
  }

  GroupMessage? fromMap(Map<String, dynamic>? map) {
    return map==null?null: GroupMessage(
      msgId: map[GroupMsgsDBHelper.columnId],
     msg: map[GroupMsgsDBHelper.columnMsg], 
    sender: map[GroupMsgsDBHelper.columnSender],
     grpId: map[GroupMsgsDBHelper.columnGrpId], 
     date: map[GroupMsgsDBHelper.columnDate], 
     fileName: map[GroupMsgsDBHelper.columnFileName], 
     fileSize: map[GroupMsgsDBHelper.columnFileSize],
     msgFile: map[GroupMsgsDBHelper.columnMsgFile],
      replied: map[GroupMsgsDBHelper.columnReplied], 
      repliedMsgId: map[GroupMsgsDBHelper.columnRepliedMdgId], 
      repliedMsgSender: map[GroupMsgsDBHelper.columnRepliedMsgSender],
       );
  }
}
