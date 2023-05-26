import 'admin.dart';
import 'adminDbHelper.dart';

class AdminHelper{
        final AdminDbHelper _dbHelper = AdminDbHelper();

  Future<int> insert(AdminModel user) async {
    return _dbHelper.insert(toMap(user));
  }

  Future<AdminModel?> queryById(int id) async {
    return fromMap(await _dbHelper.queryById(id));
  }
   Future<AdminModel?> queryByUserGroup(String user,String grp) async {
    return fromMap(await _dbHelper.queryByAdminAndGroup(user,grp));
  }
  

  Future<List<AdminModel?>> queryAll() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryAll();
    return reportMapList.map((e) => fromMap(e)).toList();
  }
     Future<List<AdminModel?>> queryByGrp(String grp) async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryByGroup(grp);
    return reportMapList.map((e) => fromMap(e)).toList();
  }
  //   Future<List<GroupModel?>> queryChats() async {
  //   List<Map<String, dynamic>> reportMapList = await _dbHelper.queryByField();
  //   return reportMapList.map((e) => fromMap(e)).toList();
  // }
  //   Future<List<DirMsgDetails>> queryUserToMe(String log) async {
  //   List<Map<String, dynamic>> reportMapList = await _dbHelper.queryUserDetails(log);
  //   return reportMapList.map((e) => fromMap(e)).toList();
  // }

  Future<int> delete(int id) async {
    return _dbHelper.delete(id);
  }

  Future<int> update(AdminModel myUser) async {
    return _dbHelper.update(toMap(myUser));
  }

  Map<String, dynamic> toMap(AdminModel admin) {
    return {
      AdminDbHelper.columnAdminGrpId: admin.grpId.toString(), // TODO get project id
      AdminDbHelper.columnAdminId: admin.userId
      
    };
  }

  AdminModel? fromMap(Map<String, dynamic>? map) {
    return map==null?null: AdminModel(
        grpId: map[AdminDbHelper.columnAdminGrpId],
        userId: map[AdminDbHelper.columnAdminId],
  );
  }
}