import 'package:tuchati/services/SQLite/groups/groupDbHelper.dart';

import 'group.dart';

class GroupHelper{
    final GroupDbHelper _dbHelper = GroupDbHelper();

  Future<int> insert(GroupModel user) async {
    return _dbHelper.insert(toMap(user));
  }

  Future<GroupModel?> queryById(int id) async {
    return fromMap(await _dbHelper.queryById(id));
  }

  Future<List<GroupModel?>> queryAll() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryAll();
    return reportMapList.map((e) => fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    return _dbHelper.delete(id);
  }

  Future<int> update(GroupModel myUser) async {
    return _dbHelper.update(toMap(myUser));
  }

  Map<String, dynamic> toMap(GroupModel grp) {
    return {
      GroupDbHelper.columnGrpName: grp.name, // TODO get project id
      GroupDbHelper.columnGrpId: grp.grpId,
      GroupDbHelper.columnCreated: grp.created,
      GroupDbHelper.columnGrpOwner: grp.owner, // TODO get project id
      GroupDbHelper.columnGrpDesc: grp.description
    };
  }

  GroupModel? fromMap(Map<String, dynamic>? map) {
    return map==null?null: GroupModel(
        name: map[GroupDbHelper.columnGrpName],
        grpId: map[GroupDbHelper.columnGrpId],
        created: map[GroupDbHelper.columnCreated],
        owner: map[GroupDbHelper.columnGrpOwner],
        description: map[GroupDbHelper.columnGrpDesc]);
  }
}