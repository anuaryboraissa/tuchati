import 'package:tuchati/services/SQLite/databaseHelper/userDBHelper.dart';
import 'package:tuchati/services/SQLite/models/user.dart';

class UserHelper {
  final UserDBHelper _dbHelper = UserDBHelper();

  Future<int> insert(MyUser user) async {
    return _dbHelper.insert(toMap(user));
  }

  Future<MyUser?> queryById(String id) async {
    return fromMap(await _dbHelper.queryById(id));
  }

  Future<MyUser?> queryByPhone(String phone) async {
    return fromMap(await _dbHelper.queryByPhone(phone));
  }

  Future<List<MyUser?>> queryAll() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryAll();
    return reportMapList.map((e) => fromMap(e)).toList();
  }

  Future<List<MyUser?>> queryUserToMe(String log) async {
    List<Map<String, dynamic>> reportMapList =
        await _dbHelper.queryUserDetails(log);
    return reportMapList.map((e) => fromMap(e)).toList();
  }

  Future<List<MyUser?>> queryParticipants(int grpId) async {
    List<Map<String, dynamic>> reportMapList =
        await _dbHelper.queryParticipants(grpId);
    return reportMapList.map((e) => fromMap(e)).toList();
  }

  // Future<List<MyUser?>> queryActiveFriends(int days) async {
  //   List<Map<String, dynamic>> reportMapList =
  //       await _dbHelper.queryActiveFriends(days);
  //   return reportMapList.map((e) => fromMap(e)).toList();
  // }

  Future<List<MyUser?>> queryAdmins(int grpId) async {
    List<Map<String, dynamic>> reportMapList =
        await _dbHelper.queryAdmins(grpId);
    return reportMapList.map((e) => fromMap(e)).toList();
  }

  Future<MyUser?> queryUserByFields(
      String fName, String lName, String phone) async {
    Map<String, dynamic>? reportMapList =
        await _dbHelper.queryByFields(fName, lName, phone);
    return fromMap(reportMapList);
  }

  Future<int> delete(int id) async {
    return _dbHelper.delete(id);
  }

  Future<int> update(MyUser MyUser) async {
    return _dbHelper.update(toMap(MyUser));
  }

  Map<String, dynamic> toMap(MyUser user) {
    return {
      UserDBHelper.columnUserId: user.id,
      UserDBHelper.columnFirstName: user.firstName, // TODO get project id
      UserDBHelper.columLastName: user.lastName,
      UserDBHelper.columnAbout: user.about,
      UserDBHelper.columnCreated: user.created, // TODO get project id
      UserDBHelper.columnPhone: user.phone,
      UserDBHelper.columnProfile: user.profile
    };
  }

  MyUser? fromMap(Map<String, dynamic>? map) {
    return map == null
        ? null
        : MyUser(
            id: map[UserDBHelper.columnUserId],
            about: map[UserDBHelper.columnAbout],
            created: map[UserDBHelper.columnCreated],
            firstName: map[UserDBHelper.columnFirstName],
            lastName: map[UserDBHelper.columLastName],
            phone: map[UserDBHelper.columnPhone],
            profile: map[UserDBHelper.columnProfile]);
  }
}
