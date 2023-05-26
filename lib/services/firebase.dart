// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import "package:http/http.dart" as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuchati/services/SQLite/groups/participants/participantHelper.dart';
import 'package:tuchati/services/collectmsgs.dart';
import 'package:tuchati/services/secure_storage.dart';
import '../screens/page/progress/progress.dart';
import 'SQLite/groups/admins/admin.dart';
import 'SQLite/groups/admins/adminHelper.dart';
import 'SQLite/groups/group.dart';
import 'SQLite/groups/groupHelper.dart';
import 'SQLite/groups/participants/participant.dart';
import 'SQLite/modelHelpers/dirMsgsHelper.dart';
import 'SQLite/modelHelpers/directsmsdetails.dart';
import 'SQLite/modelHelpers/grpDetailsHelper.dart';
import 'SQLite/modelHelpers/grpMsgsHelper.dart';
import 'SQLite/modelHelpers/userHelper.dart';
import 'SQLite/models/dirMessages.dart';
import 'SQLite/models/groupMessages.dart';
import 'SQLite/models/grpDetails.dart';
import 'SQLite/models/msgDetails.dart';
import 'SQLite/models/user.dart';
import 'SQLite/updateDetails.dart';
import 'awesome_notify_fcm.dart';
import 'groups.dart';

class FirebaseService {
  Future<bool> postUserData(
      uid, firstname, lastname, phone, context, url) async {
    try {
      DateTime now = DateTime.now();
      var created = DateFormat("yyyy-MM-dd hh:mm:ss").format(now);
      final firebase =
          FirebaseFirestore.instance.collection("Users").doc("$uid");
      // String? notifyToken = await CloudMessaging().getMyToken();
      DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
      var lastSeen = format.format(DateTime.now());
      final json = {
        'uid': uid,
        'first_name': firstname,
        "last_name": lastname,
        "phone": phone,
        "created": created,
        "notify_token": "",
        "profile": url,
        "online_status": false,
        "last_seen": lastSeen,
        "about": "hey there i'm using Tuchati"
      };
      firebase.set(json);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registered successfully!!'),
          duration: Duration(milliseconds: 1500),
          width: 280.0,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed'),
          duration: Duration(milliseconds: 1500),
          width: 280.0,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  Future<bool> sendOTP(String phone, context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("wait!!..........Request OTP for $phone...."),
        duration: const Duration(milliseconds: 1500),
        width: 280.0,
        behavior: SnackBarBehavior.floating,
      ),
    );
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(seconds: 50),
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account is successfully verified'),
            duration: Duration(milliseconds: 1500),
            width: 280.0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('The provided phone number is not valid. $phone'),
              duration: const Duration(milliseconds: 1500),
              width: 280.0,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (e.code == 'too-many-requests') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Too many requests.. Please try again later'),
              duration: Duration(milliseconds: 1500),
              width: 280.0,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('otp send failed.....${e.code}'),
            duration: const Duration(milliseconds: 1500),
            width: 280.0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Verification code is successfully sent to $phone....'),
            duration: const Duration(milliseconds: 1500),
            width: 280.0,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await SecureStorageService().writeKeyValueData("otp", verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server timed out while send sms to $phone...."),
            duration: const Duration(milliseconds: 1500),
            width: 280.0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );

    return true;
  }

  Future storeFirebaseUsersInLocal() async {
    FirebaseFirestore.instance.collection("Users").get().then((value) {
      value.docs.forEach((element) async {
        Box<Uint8List> myProfile = Hive.box<Uint8List>("myProfile");
        if (myProfile.get(element['uid']) == null) {
          http.get(Uri.parse(element["profile"])).then((value) {
            print(
                "user ${element['first_name']} his profile going to be saved....................");
            Uint8List bytes = value.bodyBytes;
            myProfile.put(element['uid'], bytes);
          });
        }
        String userName = "";

        MyUser? result2 = await UserHelper().queryById(element['uid']);
        SecureStorageService().readCntactsData("contacts").then((cont) async {
          List cont2 = cont.where((us) {
            return us[0].toString().replaceAll(" ", "") == element["phone"];
          }).toList();
          if (cont2.isNotEmpty) {
            userName = cont2.single[1];
          }
         List<String> user = [
              element['uid'],
              userName.isEmpty?element['first_name']:userName,
              element['last_name']
            ];
            if (result2 == null) {
              StorageItem item = StorageItem(element['phone'], user);
              await SecureStorageService().writeSecureData(item);

              MyUser userr = MyUser(
                  id: element['uid'],
                  firstName: userName.isEmpty?element['first_name']:userName,
                  profile: element["profile"],
                  lastName: element['last_name'],
                  phone: element['phone'],
                  created: element['created'],
                  about: element['about']);
              int result = await UserHelper().insert(userr);
              if (result > 0) {
                print("user saved locally_________");
              }
            } else {
              print(
                  "try___________${result2.firstName} na ${element["first_name"]} na ${userName.isEmpty}");
              if (userName.isNotEmpty && result2.firstName != userName) {
                print("going_________________");
                MyUser user2 = MyUser(
                    id: element['uid'],
                    firstName: userName,
                    profile: element["profile"],
                    lastName: element['last_name'],
                    phone: element['phone'],
                    created: element['created'],
                    about: element['about']);
                int result = await UserHelper().update(user2);
                if (result > 0) {
                  print("user updated successfully____________");
                  DirMsgDetails? details =
                      await DirectSmsDetailsHelper().queryById(element['uid']);
                  if (details != null) {
                    DirMsgDetails detail = DirMsgDetails(
                        name: userName,
                        userId: element['uid'],
                        lastMessage: "",
                        date: "",
                        time: "",
                        unSeen: 0);
                    await DirectSmsDetailsHelper().update(detail);
                  }
                }
              }
            }
        });
      });
    });
  }

  Future sendMessage(List message) async {
    final firebase =
        FirebaseFirestore.instance.collection("Messages").doc("${message[0]}");

    final msg = {
      'msg_id': message[0],
      'msg': message[1],
      "sender": message[2],
      "receiver": message[3],
      "replied": message[4],
      "seen": message[5],
      "date": message[6],
      "time": message[7],
      "msg_file": message[9],
      "file_name": message[10],
      "file_size": message[11],
      "replied_msg_id": message[12]
    };
    firebase.set(msg).whenComplete(() async {
      // await SecureStorageService().writeKeyValueData("${message[0]}", "1");
      Box<String> messages = Hive.box<String>("messages");
      messages.put("${message[0]}", "0");
      print(
          "completed .................................${msg["msg"]} sent and saved");
    });
    await CollectMessageData()
        .storeMessage(message[1].toString(), message[6].toString());
  }

  Future sendGrpMessage(List message) async {
    final firebase = FirebaseFirestore.instance
        .collection("GroupMessages")
        .doc("${message[0]}");
    final msg = {
      'msg_id': message[0],
      'msg': message[1],
      "sender": message[2],
      "replied": message[3],
      "created": message[4],
      "grp_id": message[5],
      "sent": message[6],
      "seen": message[7],
      "msg_file": message[8],
      "file_name": message[9],
      "file_size": message[10],
      "replied_msg_id": message[11],
      "replied_msg_sender": message[12]
    };
    firebase.set(msg).whenComplete(() async {
      // await SecureStorageService().writeKeyValueData("${message[0]}", "1");
      Box<String> messages = Hive.box<String>("messages");
      messages.put("${message[0]}", "0");
    });
    CollectMessageData().storeMessage(message[1], message[4]);
  }

  Future<bool> checkIfGrpExist(String groupId) async {
    try {
      bool itExists = false;
      FirebaseFirestore.instance.collection("Groups").get().then((value) {
        value.docs.forEach((element) {
          if (element["grp_id"] == groupId) {
            itExists = true;
          }
        });
      });
      return itExists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIfMsgExist(String msgId) async {
    try {
      bool itExists = false;
      FirebaseFirestore.instance.collection("Messages").get().then((value) {
        value.docs.forEach((element) {
          if (element["msg_id"] == msgId) {
            itExists = true;
          }
        });
      });
      return itExists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkIfMsgIdExist(String msgId) async {
    try {
      bool itExists = false;
      FirebaseFirestore.instance
          .collection("GroupMessages")
          .get()
          .then((value) {
        value.docs.forEach((element) {
          if (element["msg_id"] == msgId) {
            itExists = true;
          }
        });
      });
      return itExists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createGroup(List group) async {
    final firebase =
        FirebaseFirestore.instance.collection("Groups").doc("${group[0]}");

    storage.UploadTask uploadTask;
    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child("groupIcons")
        .child("/${group[0]}");
    uploadTask = ref.putFile(group[3]);
    await uploadTask.whenComplete(() {
      print("group icon uploaded successfully");
    });
    String iconPath = await ref.getDownloadURL();
    final grp = {
      'grp_id': group[0],
      'name': group[1],
      'created': group[2],
      "decription": group[4],
      "participants": group[5],
      "admins": group[6],
      "icon": iconPath,
      "creater": group[7]
    };
    firebase.set(grp).whenComplete(() {
      // print(
      //     "completed .................................${grp["name"]} saved to firebase");
    });
    return true;
  }

  Future<bool> updateGroup(String groupId, List group) async {
    final firebase =
        FirebaseFirestore.instance.collection("Groups").doc("$groupId}");
    Map<String, dynamic> participants = {};
    Map<String, dynamic> admins = {};
    for (var partici = 0; partici < group[5].length; partici++) {
      participants["uid$partici"] = group[5][partici][0];
      participants["name$partici"] = group[5][partici][1];
    }
    for (var admin = 0; admin < group[6].length; admin++) {
      admins["uid$admin"] = group[6][admin][0];
      admins["name$admin"] = group[6][admin][1];
    }
    storage.UploadTask uploadTask;
    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child("groupIcons")
        .child("/${group[0]}");
    uploadTask = ref.putFile(group[3]);
    await uploadTask.whenComplete(() {
      // print("group icon uploaded successfully");
    });
    String iconPath = await ref.getDownloadURL();
    final grp = {
      'grp_id': group[0],
      'name': group[1],
      'created': group[2],
      "decription": group[4],
      "participants": participants,
      "admins": admins,
      "icon": iconPath
    };
    firebase.update(grp).whenComplete(() {}
        // print("group $groupId changes committed successfully.............")
        );
    return true;
  }

  Future<void> leftGroup(String groupId, String uid) async {
    FirebaseFirestore.instance
        .collection("Lefts")
        .doc(groupId)
        .get()
        .then((value) {
      final firebase =
          FirebaseFirestore.instance.collection("Lefts").doc(groupId);

      if (value.exists) {
        // print("doc exists going to update it...............");
        List uidd = value["uids"];
        uidd.add(uid);
        final json = {"uids": uidd};
        firebase.update(json).whenComplete(() {
// print("left to group $groupId committed...............")
        });
      } else {
        // print("doc doesn't exists going to set it...............");

        List uids = [];
        uids.add(uid);
        final json = {"group_id": groupId, "uids": uids};
        firebase.set(json).whenComplete(() {
          // print("left to group $groupId committed...............");
        });
      }
    });
  }

  checkExistence(String grpId) async {
    GroupMsgDetails? details = await GroupSmsDetailsHelper().queryById(grpId);
    if (details == null) {
      return true;
    } else {
      return false;
    }
  }

  Future filterMyGroups() async {
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    if (logged.isNotEmpty) {
      FirebaseFirestore.instance.collection("Groups").get().then((value) {
        value.docs
          ..where((element) => element["participants"].contains(logged[0]))
              .toList()
              .forEach((elementt) async {
            print(
                "zilizokua filtered is ${elementt["name"]} %%%%%%%%%%%%%%%%%%%%%%");
            Box<Uint8List> grpIcon = Hive.box<Uint8List>("groups");
            if (grpIcon.get(elementt['grp_id']) == null) {
              print(
                  "changing group icon... ${elementt["name"]}...........%%%%%%%%%%%%%%%%%%.......");
              http.get(Uri.parse(elementt["icon"])).then((value) {
                Uint8List bytes = value.bodyBytes;
                grpIcon.put(elementt['grp_id'], bytes);
              });
            }

            GroupModel? group =
                await GroupHelper().queryById((int.parse(elementt["grp_id"])));

            if (group == null) {
              GroupModel thisGroup = GroupModel(
                  name: elementt["name"],
                  grpId: int.parse(elementt["grp_id"]),
                  created: elementt["created"],
                  description: elementt["decription"],
                  owner: elementt["creater"]);

              int i = await GroupHelper().insert(thisGroup);
              if (i > 0) {
//save icon
                print("saving participants and admins..........");
                List participants = elementt["participants"];
                List admins = elementt["admins"];
                // ignore: avoid_function_literals_in_foreach_calls
                admins.forEach((element2) async {
                  AdminModel adminModel =
                      AdminModel(grpId: elementt["grp_id"], userId: element2);
                  int a = await AdminHelper().insert(adminModel);
                  if (a > 0) {
                    print("admin served successfully...............");
                  }
                });
                participants.forEach((element2) async {
                  ParticipantModel partModel = ParticipantModel(
                      grpId: elementt["grp_id"].toString(),
                      userId: element2,
                      addedByUserId: logged[0]);
                  int b = await ParticipantHelper().insert(partModel);
                  if (b > 0) {
                    print("participant served successfully...............");
                  }
                });
                GroupModel? group2 = await GroupHelper()
                    .queryById((int.parse(elementt["grp_id"])));
                if (group2 != null) {
                  GroupMsgDetails detail2 = GroupMsgDetails(
                      name: group2.name,
                      grpId: group2.grpId,
                      lastMessage: "",
                      date: "",
                      lastSender: "",
                      unSeen: 0);
                  int rss = await GroupSmsDetailsHelper().insert(detail2);
                  if (rss > 0) {
                    print(
                        "New group ${group2.name} saved successfully.................");
                  }
                }
              }
            } else {
              if (elementt["participants"].toList().contains(logged[0])) {
                AdminHelper().queryByGrp(elementt["grp_id"]).then((value) {
                  List admins = elementt["admins"];
                  if (admins.length != value.length) {
                    //update participants
                    List newAdmins = admins
                        .where(
                          (element2) {
                            bool newAdmin = false;
                            for (var admin in value) {
                              if (admin!.userId != element2) {
                                newAdmin = true;
                              }
                            }
                            return newAdmin;
                          },
                        )
                        .toSet()
                        .toList();
                    if (newAdmins.isNotEmpty) {
                      newAdmins.forEach(
                        (element3) {
                          AdminHelper()
                              .queryByUserGroup(element3, elementt["grp_id"])
                              .then((value2) async {
                            if (value2 == null) {
                              //insert new admin
                              AdminModel adminModel = AdminModel(
                                  grpId: elementt["grp_id"], userId: element3);
                              int a = await AdminHelper().insert(adminModel);
                              if (a > 0) {
                                print(
                                    "hey  $element3  %%%%% added  locally success");
                              }
                            }
                          });
                        },
                      );
                    }
                  }
                });
                group.description = elementt["decription"];
                group.name = elementt["name"];
                int up = await GroupHelper().update(group);
                if (up > 0) {
                  GroupMsgDetails? detail = await GroupSmsDetailsHelper()
                      .queryById(group.grpId.toString());
                  if (detail != null) {
                    detail.name = elementt["name"];
                    int up2 = await GroupSmsDetailsHelper().update(detail);
                    if (up2 > 0) {
                      print("detail updated successfully..");
                    }
                  }
                }
              }
            }
          });
      });
    }
  }

//load group replies
  Future receiveGroupsMsgAndSaveLocal() async {
    print(
        "loading groups replies.............................................");
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    if (logged.isNotEmpty) {
      String senderId = logged[0];
      GroupSmsDetailsHelper().queryAll().then((value) {
        value.forEach((element) {
          Box<List<String>> grpLetfs = Hive.box<List<String>>("lefts");
          if (grpLetfs.get(logged[0]) == null) {
            retrieveGroupMessage(element!, senderId);
          } else {
            bool ameLeft =
                grpLetfs.get(logged[0])!.contains(element!.grpId.toString());
            if (!ameLeft) {
              retrieveGroupMessage(element, senderId);
            }
          }
        });
      });
    }
  }

  void retrieveGroupMessage(GroupMsgDetails element, String senderId) {
    FirebaseFirestore.instance
        .collection("GroupMessages")
        .where("grp_id", isEqualTo: element.grpId.toString())
        .where("sender", isNotEqualTo: senderId)
        .get()
        .then((value) async {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> newData = value.docs
          .where((element) => !element["seen"].toList().contains(senderId))
          .toList();
      // print(
      //     "messages ${value.docs.length} ******************************** na ${newData.length}****");
      if (newData.isNotEmpty) {
        int unSeen = newData.length;
        QueryDocumentSnapshot<Map<String, dynamic>> lastData = newData.last;
        String lastMessage = lastData["msg"];
        String lastSender = "";
        MyUser? result2 = await UserHelper().queryById(lastData["sender"]);
        if (result2 != null) {
          lastSender = result2.firstName;
        }
        String date = lastData["created"];
        int groupId = element.grpId;
        String groupName = element.name;

        newData.forEach((element) async {
          GroupMessage? result2 =
              await GrpMsgsHelper().queryById(int.parse(element["msg_id"]));
          if (result2 == null) {
            //sendNotify
            Box<int> channel = Hive.box<int>("channels");
            if (channel.get(groupId.toString()) == null) {
              int userchannel = UniqueKey().hashCode;
              channel.put(groupId.toString(), userchannel);
            }
            Map<String, String> payload = {
              "user": groupId.toString(),
              "name": groupName,
              "lastMessage": lastMessage,
              "date": date,
              "time": date
            };

            await AwesomeNotifyFcm.instantNotify(
                "$groupName ($unSeen messages)",
                lastMessage,
                payload,
                channel.get(groupId.toString())!);

            GroupMessage grpMsg = GroupMessage(
                msgId: int.parse(element["msg_id"]),
                msg: element["msg"],
                sender: element["sender"],
                grpId: element["grp_id"],
                replied: element["replied"],
                repliedMsgId: element["replied_msg_id"],
                date: element["created"],
                fileName: element["file_name"],
                msgFile: element["msg_file"],
                fileSize: element["file_size"],
                repliedMsgSender: element["replied_msg_sender"]);
            int result = await GrpMsgsHelper().insert(grpMsg);
            if (result > 0) {
              if (element["msg_file"] != "0" &&
                  element["msg_file"] != "" &&
                  !element["file_name"].toString().contains(".m4a")) {
                // print(
                //     "message file going to be loaded..............${element["msg_file"]}");
                saveMessageFile(element["msg_id"], element["msg_file"]);
              }
              List saws = element["seen"];
              ParticipantHelper().queryByGrp(element["grp_id"]).then((value) {
                if (saws.length == value.length) {
                  DocumentReference ref = FirebaseFirestore.instance
                      .collection("GroupMessages")
                      .doc(element["msg_id"]);
                  ref.get().then((value) {
                    if (value.exists) {
                      ref.delete();
                      // print(
                      //     "group message ${element["msg"]} deleted successfully......................");
                      if (value["msg_file"].toString().isNotEmpty &&
                          value["msg_file"].toString() != "0") {
                        storage.FirebaseStorage.instance
                            .ref()
                            .child("MessageFiles")
                            .child("/${value["msg_id"]}")
                            .delete();
                      }
                    }
                  });
                }
              });
              Box<String> voicePaths = Hive.box<String>("voice");
              if (voicePaths.get(element["msg_id"]) == null &&
                  element["file_name"].toString().contains(".m4a")) {
                try {
                  String fileUri = element["msg_file"].toString();
                  var response = await http.get(Uri.parse(fileUri));
                  final Directory directory =
                      await getApplicationDocumentsDirectory();
                  final File file =
                      File('${directory.path}/${element["msg_id"]}.m4a');
                  Uint8List bytes = response.bodyBytes;
                  file.writeAsBytesSync(bytes);
                  voicePaths.put(element["msg_id"],
                      "${directory.path}/${element["msg_id"]}.m4a");
                  // print(
                  //     "file from group successfully saved to directory and path to  hive...........");
                } catch (e) {
                  // print("failed to write audio file.... from group....");
                }
              }
            }
          } else {
            print("message already existsssssssssss.....");
          }
        });

        UpdateDetails().updateGroupDetails(
            lastMessage, lastSender, date, groupId.toString(), unSeen);
      } else {
        print("for this group ${element.name} no new message");
      }
    });
  }

  Future receiveMsgAndSaveLocal() async {
    print("loading replies.............................................");
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    if (logged.isNotEmpty) {
      FirebaseFirestore.instance
          .collection("Messages")
          .get()
          .then((value) async {
        String senderId = logged[0];
        value.docs.forEach((element) async {
          if (element["receiver"] == senderId) {
            DirectMessage? result =
                await DirMsgsHelper().queryById(int.parse(element["msg_id"]));
            if (result == null) {
              print("this message is new ${element["msg"]}.....");

              DirectMessage directMsg = DirectMessage(
                  msgId: int.parse(element["msg_id"]),
                  msg: element["msg"],
                  sender: element["sender"],
                  receiver: element["receiver"],
                  replied: element["replied"],
                  repliedMsgId: element["replied_msg_id"],
                  seen: element["seen"],
                  time: element["time"],
                  date: element["date"],
                  fileName: element["file_name"],
                  msgFile: element["msg_file"],
                  fileSize: element["file_size"]);
              int res = await DirMsgsHelper().insert(directMsg);
              if (res > 0) {
                print(
                    "msg ${element["msg"]} received now....... wait for notify");
                UserHelper().queryUserToMe(senderId).then((value) {
                  value.forEach(
                    (user) {
                      print("user  ${user!.firstName}.......");
                      Box<int> channel = Hive.box<int>("channels");
                      if (channel.get(user.id) == null) {
                        int userchannel = UniqueKey().hashCode;
                        channel.put(user.id, userchannel);
                      }
                      DirMsgsHelper()
                          .querySmsDetails(user.id)
                          .then((value) async {
                        if (value.isNotEmpty) {
                          DirectMessage? msgg = value.toList().last;
                          Map<String, String> payload = {
                            "user": user.id.toString(),
                            "name": user.firstName,
                            "lastMessage": msgg!.msg,
                            "date": msgg.date,
                            "time": msgg.time
                          };

                          await AwesomeNotifyFcm.instantNotify(
                              "${user.firstName}(${value.length} messages)",
                              msgg.msg,
                              payload,
                              channel.get(user.id)!);

                          DirMsgDetails? details =
                              await DirectSmsDetailsHelper().queryById(user.id);
                          if (details == null) {
                            DirMsgDetails detail = DirMsgDetails(
                                name: user.firstName,
                                userId: user.id,
                                lastMessage: msgg.msg,
                                date: msgg.date,
                                time: msgg.time,
                                unSeen: value.length);
                            int rss =
                                await DirectSmsDetailsHelper().insert(detail);
                            if (rss > 0) {
                              print("details uploaded success.........");
                              DirMsgDetails? detail =
                                  await DirectSmsDetailsHelper()
                                      .queryById(user.id);
                              print(
                                  "my details ${detail!.name} ${detail.lastMessage}");
                            }
                          } else if (details.unSeen != value.length) {
                            details.unSeen = value.length;
                            details.lastMessage = msgg.msg;
                            int rss =
                                await DirectSmsDetailsHelper().update(details);
                            if (rss > 0) {
                              print("details updated success.........");
                              DirMsgDetails? detail =
                                  await DirectSmsDetailsHelper()
                                      .queryById(user.id);
                              print(
                                  "my details ${detail!.name} ${detail.lastMessage}");
                            }
                          }
                        }
                      });
                    },
                  );
                });
              }
              Box<String> voicePaths = Hive.box<String>("voice");
              if (voicePaths.get(element["msg_id"]) == null &&
                  element["file_name"].toString().contains(".m4a")) {
                try {
                  String fileUri = element["msg_file"].toString();
                  var response = await http.get(Uri.parse(fileUri));
                  final Directory directory =
                      await getApplicationDocumentsDirectory();
                  final File file =
                      File('${directory.path}/${element["msg_id"]}.m4a');
                  Uint8List bytes = response.bodyBytes;
                  file.writeAsBytesSync(bytes);
                  voicePaths.put(element["msg_id"],
                      "${directory.path}/${element["msg_id"]}.m4a");
                  // print(
                  //     "file from user successfully saved to directory and path to  hive...........");
                } catch (e) {
                  print("failed to write audio file from user........");
                }
              }
              try {
                FirebaseFirestore.instance
                    .collection('Messages')
                    .where("seen", isEqualTo: "1")
                    .get()
                    .then((value) {
                  value.docs.forEach((elementt) {
                    Box<String> msgs = Hive.box<String>("messages");
                    if (elementt.exists &&
                        msgs.get(elementt["msg_id"]) == "1") {
                      FirebaseFirestore.instance
                          .collection('Messages')
                          .doc(elementt["msg_id"])
                          .delete();
                      // print(
                      //     "message  ${element["msg"]}...........deleted success from firebase");
                      if (elementt["msg_file"] != "" ||
                          elementt["msg_file"] != "0") {
                        storage.Reference ref = storage.FirebaseStorage.instance
                            .ref()
                            .child("MessageFiles")
                            .child("/${elementt["msg_id"]}");
                        ref.delete();
                      }
                    }
                  });
                });
              } catch (e) {
                // print("failed deleting item ${element["msg_id"]}...........");
              }
              if (element["msg_file"] != "0" &&
                  element["msg_file"] != "" &&
                  !element["file_name"].toString().contains(".m4a")) {
                saveMessageFile(element["msg_id"], element["msg_file"]);
              }
            } else {
              print("this msg  ${element["msg"]}already exist *************");
            }
          }
        });

        // print(" firebase........ load success.");
      });
    }
  }

  saveMessageFile(String msgId, String fileUrl) async {
    Box<Uint8List> msgFiles = Hive.box<Uint8List>("messagesFiles");
    if (msgFiles.get(msgId) == null) {
      await http.get(Uri.parse(fileUrl)).then((value) {
        Uint8List bytes = value.bodyBytes;
        msgFiles.put(msgId, bytes);
        // print("image of message $msgId saved to hive.......");
      });
    }
  }


  sendPushMsgdeatils() async {
    List notifGrpdetails =
        await SecureStorageService().readUsersSentToMe("grpSmsDetails");
    List groupMemberss =
        await SecureStorageService().readModalData("groupMembers");
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    try {
      FirebaseFirestore.instance.collection("Users").get().then((value) async {
        value.docs.forEach((element) async {
          List myDetails = [];
          for (var grp in notifGrpdetails) {
            bool isMember = false;
            for (var memb in groupMemberss) {
              if (memb[0] == grp[0]) {
                for (var mid in memb[1]) {
                  if (mid.length < 4) {
                  } else {
                    if (mid[3] == element["uid"]) {
                      isMember = true;
                    }
                  }
                }
              }
            }
            //  print("unreaded apaaaaaaaaaaaa ${grp[1]}  is      ${grp[2]} status..........nimember  $isMember unreaded ${grp[2]}");
            if (isMember) {
              myDetails.add(grp);
            }
          }
          if (myDetails.isNotEmpty) {
            //send push message
            // print("primary sending notify.................");
            Box<String> simples = Hive.box<String>("simples");
            for (var grp in myDetails) {
              String name = "";
              // print("unseen msgs is $unseen");

              for (var membb in groupMemberss) {
                if (grp[0] == membb[0]) {
                  for (var mem in membb[1]) {
                    // print("checking sender by compare ${mem[3]} na ${grp[10]}......8 .${grp[8]}..lets compare........");
                    if (mem[3] == grp[10]) {
                      name = "${mem[0]} ${mem[1]}";
                    }
                  }
                }
              }

              // }
              //  simples.delete(grp[0]);
              if (simples.get(grp[0]) == null && grp[2] > 0) {
                simples.put(grp[0], "1");
                // print(
                //     "message going to be posted..........fro group ${grp[1]}.......................");
                Map<String, String> payload = {
                  "user": grp[0].toString(),
                  "name": "${grp[1]}"
                };
                await AwesomeNotifyFcm.instantNotify(
                    "${grp[1]}(${grp[2]} messages)",
                    "$name: ${grp[9]} ",
                    payload,
                    int.parse(grp[0]));
                // CloudMessaging().sendPushMessage(logged[4],
                //     "${grp[1]}(${grp[2]} messages)", "$name ${grp[3]}");
              }
            }
          }
        });
      });
    } catch (e) {
      // print("no stable internet to do this notify..................");
    }
  }

  sendUserNotication() async {
    List sentToMe = await SecureStorageService().readUsersSentToMe("usersToMe");
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    Box<String> simples = Hive.box<String>("simples");
    Box<int> channel = Hive.box<int>("channels");
    for (var user in sentToMe) {
      if (channel.get(user[0]) == null) {
        int userchannel = UniqueKey().hashCode;
        channel.put(user[0], userchannel);
      }
      if (simples.get(user[0]) == null && user[6] > 0) {
        // print(
        //     "now sending messages to the clound for notify userssss to ${logged[4]}");
        simples.put(user[0], "1");
        Map<String, String> payload = {
          "user": user[0].toString(),
          "name": "${user[1]} ${user[2]}"
        };
        await AwesomeNotifyFcm.instantNotify(
            "${user[1]} ${user[2]}(${user[6]} messages)",
            "${user[7]}",
            payload,
            channel.get(user[0])!);
        //  CloudMessaging().sendPushMessage(logged[4],
        //     , "${user[7]}");
      }
    }
  }

  Future updateMsgs(Map<String, dynamic> message) async {
    final firebase = FirebaseFirestore.instance
        .collection("Messages")
        .doc("${message["msg_id"]}");
    firebase.update(message).whenComplete(() {
      // print("update commited success..........");
    }).then((value) {
      // print("message ...........$message updated.....");
    });
  }

  Future<void> sendFiletofirebase(
      String msgId, File file, attributes, context) async {
    storage.UploadTask uploadTask;
    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child("MessageFiles")
        .child("/$msgId");
    uploadTask = ref.putFile(file);
    // setState(() {
    //   filesend = false;
    //   myfile = null;
    //   fileBytes = null;
    // });
    await uploadTask.whenComplete(() async {
      String filePath = await ref.getDownloadURL();
      attributes[9] = filePath;
      await FirebaseService().sendMessage(attributes);
      // print("sent to firebase");
      await Progresshud.mySnackBar(
          context, "file for message $msgId uploaded successfully....");
    });
  }
}
