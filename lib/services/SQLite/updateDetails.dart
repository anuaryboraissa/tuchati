import 'package:tuchati/services/SQLite/groups/group.dart';
import 'package:tuchati/services/SQLite/groups/groupHelper.dart';
import 'package:tuchati/services/SQLite/modelHelpers/grpDetailsHelper.dart';
import 'package:tuchati/services/SQLite/modelHelpers/userHelper.dart';
import 'package:tuchati/services/SQLite/models/grpDetails.dart';
import 'package:tuchati/services/SQLite/models/user.dart';

import 'modelHelpers/directsmsdetails.dart';
import 'models/msgDetails.dart';

class UpdateDetails{
    updateUserDetails(String lastMessage, String time, String date,String user) async {
    print("las message is $lastMessage time $time &&&&&&&&&&&&");
    DirMsgDetails? details = await DirectSmsDetailsHelper().queryById(user);
    if (details != null) {
      if (lastMessage.isNotEmpty) {
        print("apa las mesag is empty............");
        details.lastMessage = lastMessage;
        details.date = date;
        details.time = time;
      }
      
      details.unSeen = 0;
      int rss = await DirectSmsDetailsHelper().update(details);
      if (rss > 0) {
        print("details updated success.........");
         DirMsgDetails? detai = await DirectSmsDetailsHelper().queryById(user);
        print("my updated details ${detai!.name} ${detai.lastMessage}");
      }
    } else {
      MyUser? myUser=await UserHelper().queryById(user);
      DirMsgDetails detail = DirMsgDetails(
          name: myUser!.firstName,
          userId: user,
          lastMessage: lastMessage,
          date: date,
          time: time,
          unSeen: 0);
      int rss = await DirectSmsDetailsHelper().insert(detail);
      if (rss > 0) {
        print("details uploaded success.........$rss");
        DirMsgDetails? detail = await DirectSmsDetailsHelper().queryById(user);
        print("my inserted details ${detail!.name} ${detail.lastMessage}");
      }
    }
      
  }
      updateGroupDetails(String lastMessage,String lastSender,String date,String grpId,int unseen) async {
    GroupMsgDetails? details = await GroupSmsDetailsHelper().queryById(grpId);
    if (details != null) {
      if (lastMessage.isNotEmpty) {
      
        details.lastMessage = lastMessage;
        details.date = date;
        details.lastSender = lastSender;
      }
      
      details.unSeen = unseen;
      int rss = await GroupSmsDetailsHelper().update(details);
      if (rss > 0) {
       
         GroupMsgDetails? detai = await GroupSmsDetailsHelper().queryById(grpId);
           print("grp ${detai!.name} updated lst message ${detai.lastMessage}  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..");
      }
    } else {
      GroupModel? group=await GroupHelper().queryById((int.parse(grpId)));
      GroupMsgDetails detaill=GroupMsgDetails(name: group!.name, grpId: group.grpId, lastMessage: lastMessage, date: date, lastSender: lastSender, unSeen: 0);
      int rss = await GroupSmsDetailsHelper().insert(detaill);
      if (rss > 0) {
        print("details uploaded success.........$rss");
        GroupMsgDetails? detail = await GroupSmsDetailsHelper().queryById(grpId);
        print("my inserted details ${detail!.name} ${detail.lastMessage}");
      }
    }
      
  }


}