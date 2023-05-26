

import '../databaseHelper/dirsmsDetails.dart';
import '../databaseHelper/grpSmsdetails.dart';
import '../models/grpDetails.dart';
import '../models/msgDetails.dart';

class GroupSmsDetailsHelper {
  final GroupSmsDetailsDBHelper _dbHelper = GroupSmsDetailsDBHelper();

  Future<int> insert(GroupMsgDetails user) async {
    return _dbHelper.insert(toMap(user));
  }

  Future<GroupMsgDetails?> queryById(String id) async {
    return fromMap(await _dbHelper.queryById(id));
  }

  Future<List<GroupMsgDetails?>> queryAll() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryAll();
    return reportMapList.map((e) => fromMap(e)).toList();
  }
    Future<List<GroupMsgDetails?>> queryChats() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryByField();
    return reportMapList.map((e) => fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    return _dbHelper.delete(id);
  }

  Future<int> update(GroupMsgDetails myUser) async {
    return _dbHelper.update(toMap(myUser));
  }

  Map<String, dynamic> toMap(GroupMsgDetails grp) {
    return {
      GroupSmsDetailsDBHelper.columnName: grp.name, 
      GroupSmsDetailsDBHelper.columDate: grp.date,
      GroupSmsDetailsDBHelper.columnLastMsg: grp.lastMessage,
      GroupSmsDetailsDBHelper.columnLastMsgSender: grp.lastSender, 
      GroupSmsDetailsDBHelper.columnUnseen: grp.unSeen,
      GroupSmsDetailsDBHelper.columnGrpId: grp.grpId
    };
  }

  GroupMsgDetails? fromMap(Map<String, dynamic>? map) {
    return map==null?null: GroupMsgDetails(
        name: map[GroupSmsDetailsDBHelper.columnName],
        date: map[GroupSmsDetailsDBHelper.columDate],
        lastMessage: map[GroupSmsDetailsDBHelper.columnLastMsg],
        lastSender: map[GroupSmsDetailsDBHelper.columnLastMsgSender],
        unSeen: map[GroupSmsDetailsDBHelper.columnUnseen],
        grpId: map[GroupSmsDetailsDBHelper.columnGrpId]);
  }
}
