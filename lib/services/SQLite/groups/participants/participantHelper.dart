import 'package:tuchati/services/SQLite/groups/participants/participant.dart';
import 'package:tuchati/services/SQLite/groups/participants/participantDbHelper.dart';

class ParticipantHelper {
  final ParticipantDbHelper _dbHelper = ParticipantDbHelper();

  Future<int> insert(ParticipantModel user) async {
    return _dbHelper.insert(toMap(user));
  }

  Future<ParticipantModel?> queryById(int id) async {
    return fromMap(await _dbHelper.queryById(id));
  }

  Future<List<ParticipantModel?>> queryAll() async {
    List<Map<String, dynamic>> reportMapList = await _dbHelper.queryAll();
    return reportMapList.map((e) => fromMap(e)).toList();
  }

  Future<List<ParticipantModel?>> queryByGrp(String grp) async {
    List<Map<String, dynamic>> reportMapList =
        await _dbHelper.queryByGroup(grp);
    return reportMapList.map((e) => fromMap(e)).toList();
  }

  Future<ParticipantModel?> queryByUserGroup(String user, String grp) async {
    return fromMap(await _dbHelper.queryByParticipantAndGroup(user, grp));
  }
  //   Future<List<DirMsgDetails>> queryUserToMe(String log) async {
  //   List<Map<String, dynamic>> reportMapList = await _dbHelper.queryUserDetails(log);
  //   return reportMapList.map((e) => fromMap(e)).toList();
  // }

  Future<int> delete(int id) async {
    return _dbHelper.delete(id);
  }

  Future<int> update(ParticipantModel myUser) async {
    return _dbHelper.update(toMap(myUser));
  }

  Map<String, dynamic> toMap(ParticipantModel part) {
    return {
      ParticipantDbHelper.columnParticipantGrpId: part.grpId,
      ParticipantDbHelper.columnParticipantUserId: part.userId,
      ParticipantDbHelper.columnParticipantAddedBy: part.addedByUserId
    };
  }

  ParticipantModel? fromMap(Map<String, dynamic>? map) {
    return map == null
        ? null
        : ParticipantModel(
            grpId: map[ParticipantDbHelper.columnParticipantGrpId],
            userId: map[ParticipantDbHelper.columnParticipantUserId],
            addedByUserId: map[ParticipantDbHelper.columnParticipantAddedBy],
          );
  }
}
