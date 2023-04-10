import 'dart:io';
import "package:firebase_storage/firebase_storage.dart" as storage;
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class GroupService {
  Future<bool> createGroup(String groupId, String name, String description,
      List participants, List admins, File? icon) async {
    // await SecureStorageService().deleteByKeySecureData("groups");
    DateFormat format = DateFormat("yyyy-MM-dd hh:mm");
    var created = format.format(DateTime.now());
    Uint8List uint8list = icon!.readAsBytesSync();
    //check if id doesn't exist in fire
    while (await FirebaseService().checkIfGrpExist(groupId)) {
      // print("group exists.........");
      groupId = UniqueKey().hashCode.toString();
    }
    List groups = await SecureStorageService().readModalData("groups");
    List group = [];
    List myFirebasegroup = [];
    if (groups.isEmpty) {
      group.add(groupId);
      group.add(name);
      group.add(created);
      group.add(description);
      group.add(participants);
      group.add(admins);
      // to firebase
      myFirebasegroup.add(groupId);
      myFirebasegroup.add(name);
      myFirebasegroup.add(created);
      myFirebasegroup.add(icon);
      myFirebasegroup.add(description);
      myFirebasegroup.add(participants);
      myFirebasegroup.add(admins);
    } else {
      // print("available groups length ${groups.length}...............");
      for (var grp = 0; grp < groups.length; grp++) {
        // print("compare group $groupId and ${groups[grp][0]}...............");
        if (groupId != groups[grp][0]) {
          group.add(groupId);
          group.add(name);
          group.add(created);
          group.add(description);
          group.add(participants);
          group.add(admins);
          //to firebase
          myFirebasegroup.add(groupId);
          myFirebasegroup.add(name);
          myFirebasegroup.add(created);
          myFirebasegroup.add(icon);
          myFirebasegroup.add(description);
          myFirebasegroup.add(participants);
          myFirebasegroup.add(admins);
        }
      }
    }
    if (group.isNotEmpty) {
      groups.add(group);
    }
    Box<Uint8List> grpIcon=Hive.box<Uint8List>("groups");
    grpIcon.put(groupId, uint8list);
    Modal groupp = Modal("groups", groups);
    await SecureStorageService().writeModalData(groupp);
    // await FirebaseService().getGroupMembersAndSaveLocal();
    await FirebaseService().groupMsgsDetails();
    
    //save to firebase
    if (myFirebasegroup.isNotEmpty) {
      bool result = await FirebaseService().createGroup(myFirebasegroup);
      if (result) {
        print("partially group saved to cache...............");
      }
    }
    return true;
  }

  Future<bool> updateGroup(String groupId, List changes) async {
    //update in local storage
    List availableGroups = await SecureStorageService().readModalData("groups");
    List group = [];
    List newChanges = changes;
    Uint8List uint8list = group[3].readAsBytesSync();
    for (var grp = 0; grp < availableGroups.length; grp++) {
      if (availableGroups[grp][0] == groupId) {
        group = availableGroups[grp];
        changes[3] = uint8list;
        availableGroups[grp] = changes;
      } else {
        break;
      }
    }
    if (group.isNotEmpty) {
      // print("write group changes to local storage.............");
      Modal groupp = Modal("groups", availableGroups);
      await SecureStorageService().writeModalData(groupp);
      //update to firebase
      bool result = await FirebaseService().updateGroup(groupId, newChanges);
      if (result) {
        // print(
        //     "group updating complete wait for committed message...............");
      }
      return true;
    }

    //false means group doesnt exist
    return false;
  }

  Future<void> leftGroup(String groupId, String uid) async {
    List grpLefts = await SecureStorageService().readModalData("groupLefts");
    List group = [];
    if (grpLefts.isEmpty) {
      group.add(groupId);
      group.add(uid);
      grpLefts.add(group);
    } else {
      bool alreadyLeft = false;
      for (var grp = 0; grp < grpLefts.length; grp++) {
        if (grpLefts[grp][0] == groupId) {
          alreadyLeft = true;
        } else {
          break;
        }
      }
      if (!alreadyLeft) {
        group.add(groupId);
        group.add(uid);
        grpLefts.add(group);
      }
    }
    Modal model = Modal("groupLefts", grpLefts);
    await SecureStorageService().writeModalData(model);
    //firebase changes
    await FirebaseService().leftGroup(groupId, uid);
  }

  // ignore: non_constant_identifier_names
  Future saveGrpMessages(List Mysms,File? file) async {
    List grpMsg = [];
    grpMsg.add(Mysms[0]);
    grpMsg.add(Mysms[1]);
    grpMsg.add(Mysms[2]);
    grpMsg.add(Mysms[3]);
    grpMsg.add(Mysms[4]);
    grpMsg.add(Mysms[5]);
    grpMsg.add(Mysms[6]);
    grpMsg.add(Mysms[7]);
    grpMsg.add(Mysms[8]);
    grpMsg.add(Mysms[9]);
    grpMsg.add(Mysms[10]);
    grpMsg.add(Mysms[11]);
      grpMsg.add(Mysms[12]);

    // List grpMsgs = await SecureStorageService().readModalData("grpMessages");

    // grpMsgs.add(grpMsg);
    // Modal modal = Modal("grpMessages", grpMsgs);
    // await SecureStorageService().writeModalData(modal);
    // print("message ${Mysms[1]} saved and sent to ${Mysms[5]}..........");
    //save it firebase
    if(file==null){
       await FirebaseService().sendGrpMessage(grpMsg);
    }
    else{
     storage.UploadTask uploadTask;
    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child("MessageFiles")
        .child("/${Mysms[0]}");
    uploadTask = ref.putFile(file);
  
    await uploadTask.whenComplete(() async {
       String filePath = await ref.getDownloadURL();
      grpMsg[8]=filePath;
          await FirebaseService().sendGrpMessage(grpMsg);
    print("sent to firebase group message");
      
    });
    }
  
  }

  Future filterMyGroups() async {
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    if(logged.isNotEmpty){
 String mimi = logged[0];
      List localGroups = await SecureStorageService().readModalData("groups");

    FirebaseFirestore.instance.collection("Groups").get().then((value) async {
      value.docs.forEach((element) async {
        List particii = element["participants"];
        if (particii.contains(mimi)) {
          List group = [];
          group.add(element["grp_id"]);
          group.add(element["name"]);
          group.add(element["created"]);
          group.add(element["decription"]);
          group.add(element["participants"]);
          group.add(element["admins"]);
          bool checkExits = false;
          bool isEmty=false;
          if (localGroups.isEmpty) {
            localGroups.add(group);
            isEmty=true;
          } else {
            for (var local = 0; local < localGroups.length; local++) {
              if (element["grp_id"] == localGroups[local][0]) {
                checkExits = true;
              }
            }
          }
           try {
              final response = await http.get(Uri.parse(element["icon"]));
            Uint8List uint8list = response.bodyBytes;
            Box<Uint8List> groupsIcon = Hive.box<Uint8List>("groups");
            groupsIcon.put("${element["grp_id"]}", uint8list);
           } catch (e) {
             print("unhandled exception........loading image");
           }
          
          if (!isEmty && !checkExits) {
            localGroups.add(group);
          }
       
          
        }
       Modal groupp = Modal("groups", localGroups);
            await SecureStorageService().writeModalData(groupp);
      });

    });
    }
   

    //save to local storage
  }

  Future<List> getGroupparticipants(String groupId) async {
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    if(logged.isNotEmpty){
      List groupMembers =
        await SecureStorageService().readModalData("groupMembers");
    List members = [];
    for (var x in groupMembers) {
      if (x[0] == groupId) {
        members = x[1];
      }
    }
    // print("member of group..................$groupId..........is $members");
    return members;
    }
    return [];
  }
  Future<List> getGroupAdmins(String groupId) async {
      List<dynamic> logged = await SecureStorageService().readByKeyData("user");
      if(logged.isNotEmpty){
List groupAdmins =
        await SecureStorageService().readModalData("groupAdmins");
    List admins = [];
    for (var x in groupAdmins) {
      if (x[0] == groupId) {
        admins = x[1];
      }
    }
    return admins;
      }
      return [];
    
  }
}
