import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tuchati/screens/groupcreate/details.dart';
import 'package:tuchati/services/cloud_messaging.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import "package:http/http.dart" as http;

import '../screens/page/progress/progress.dart';
import 'awesome_notify_fcm.dart';

class FirebaseService {
  Future<bool> postUserData(uid, firstname, lastname, phone, context) async {
    try {
      DateTime now = DateTime.now();
      var created = DateFormat("yyyy-MM-dd hh:mm:ss").format(now);
      final firebase =
          FirebaseFirestore.instance.collection("Users").doc("$uid");
      // String? notifyToken = await CloudMessaging().getMyToken();
      final json = {
        'uid': uid,
        'first_name': firstname,
        "last_name": lastname,
        "phone": phone,
        "created": created,
        "notify_token": "",
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
        print(element['phone']);
        List<String> user = [
          element['uid'],
          element['first_name'],
          element['last_name']
        ];
        StorageItem item = StorageItem(element['phone'], user);
        await SecureStorageService().writeSecureData(item);
        print("user saved locally");
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
      "icon": iconPath
    };
    firebase.set(grp).whenComplete(() {
      print(
          "completed .................................${grp["name"]} saved to firebase");
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
      print("group icon uploaded successfully");
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
    firebase.update(grp).whenComplete(() =>
        print("group $groupId changes committed successfully............."));
    return true;
  }

  Future<void> leftGroup(String groupId, String uid) async {
    FirebaseFirestore.instance
        .collection("Lefts")
        .doc("$groupId}")
        .get()
        .then((value) {
      final firebase =
          FirebaseFirestore.instance.collection("Lefts").doc(groupId);

      if (value.exists) {
        print("doc exists going to update it...............");
        List uidd = jsonDecode(value.data()!["uid"]);
        uidd.add(uid);
        final json = {"uid": jsonEncode(uidd)};
        firebase.update(json).whenComplete(
            () => print("left to group $groupId committed..............."));
      } else {
        print("doc doesn't exists going to set it...............");

        List uids = [];
        uids.add(uid);
        final json = {"group_id": groupId, "uid": jsonEncode(uids)};
        firebase.set(json).whenComplete(
            () => print("left to group $groupId committed..............."));
      }
    });
  }

//load group replies
  Future receiveGroupsMsgAndSaveLocal() async {
    print(
        "loading groups replies.............................................");
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    if (logged.isNotEmpty) {
      List localmsgs =
          await SecureStorageService().readModalData("grpMessages");

      String senderId = logged[0];
      List mygroups = await SecureStorageService().readModalData("groups");
      if (mygroups.isNotEmpty) {
        for (var grp = 0; grp < mygroups.length; grp++) {
          if (mygroups[grp][4].contains(senderId)) {
            FirebaseFirestore.instance
                .collection("GroupMessages")
                .where("grp_id", isEqualTo: mygroups[grp][0])
                .get()
                .then((value) async {
              value.docs.forEach((element) async {
                //check if group is participant

                List msggg = [
                  element["msg_id"],
                  element["msg"],
                  element["sender"],
                  element["replied"],
                  element["created"],
                  element["grp_id"],
                  element["sent"],
                  element["seen"],
                  element["file_name"],
                  element["file_size"],
                  element["replied_msg_id"],
                  element["replied_msg_sender"],
                ];
                Box<String> voicePaths = Hive.box<String>("voice");
                if (voicePaths.get(element["msg_id"]) == null &&
                    element["file_name"].toString().contains(".m4a")) {
                  try {
                    String fileUri = element["msg_file"].toString();
                    var response = await http.get(Uri.parse(fileUri));
                    final Directory directory =
                        await getApplicationDocumentsDirectory();
                    final File file = File('${directory.path}/${element["msg_id"]}.m4a');
                    Uint8List bytes=response.bodyBytes;
                    file.writeAsBytesSync(bytes);
                    voicePaths.put(element["msg_id"],"${directory.path}/${element["msg_id"]}.m4a");
                    print("file from group successfully saved to directory and path to  hive...........");
                  } catch (e) {
                    print("failed to write audio file.... from group....");
                  }
                }
                bool tester = false;
                bool isEmty = false;
                if (localmsgs.isEmpty) {
                  localmsgs.add(msggg);
                  isEmty = true;
                  Modal mysms = Modal("grpMessages", localmsgs);
                  await SecureStorageService().writeModalData(mysms);
                } else {
                  List seen = element["seen"];
                  for (var msg = 0; msg < localmsgs.length; msg++) {
                    if (localmsgs[msg][0] == element["msg_id"]) {
                      tester = true;

                      if (element["seen"] != localmsgs[msg][7]) {
                        //there is changes
                        if (element["sender"] != senderId &&
                            !seen.contains(senderId)) {
                          // print(
                          //     "changess performed in message ${localmsgs[msg][1]}........");

                          localmsgs[msg][7] = seen;
                          Modal mysms = Modal("grpMessages", localmsgs);
                          await SecureStorageService().writeModalData(mysms);
                          // print("changess performed written sucesssssssfull");
                        }
                      }
                    }
                  }
                }
                if (!isEmty && !tester) {
                  localmsgs.add(msggg);
                  Modal mysms = Modal("grpMessages", localmsgs);
                  await SecureStorageService().writeModalData(mysms);
                }
                if (element["msg_file"] != "0" && element["msg_file"] != "" && !element["file_name"].toString().contains(".m4a")) {
                  // print(
                  //     "message file going to be loaded..............${element["msg_file"]}");
                  saveMessageFile(element["msg_id"], element["msg_file"]);
                }
              });
            });
          }
        }
      }
    }
  }

  Future receiveMsgAndSaveLocal() async {
    print("loading replies.............................................");
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    if (logged.isNotEmpty) {
      FirebaseFirestore.instance
          .collection("Messages")
          .get()
          .then((value) async {
        List localmsgs =
            await SecureStorageService().readAllMsgData("messages");

        String senderId = logged[0];
        value.docs.forEach((element) async {
          if (element["receiver"] == senderId) {
            //             "file_name":message[10],
            // "file_size":message[11]
            //save file image
            if (element["msg_file"] != "0" && element["msg_file"] != "" && !element["file_name"].toString().contains(".m4a")) {
              saveMessageFile(element["msg_id"], element["msg_file"]);
            }
            List msggg = [
              element["msg_id"],
              element["msg"],
              element["sender"],
              element["receiver"],
              element["replied"],
              element["seen"],
              element["date"],
              element["time"],
              element["file_name"],
              element["file_size"],
              element["replied_msg_id"]
            ];
        Box<String> voicePaths = Hive.box<String>("voice");
        if (voicePaths.get(element["msg_id"]) == null &&
                    element["file_name"].toString().contains(".m4a")) {
                  try {
                    String fileUri = element["msg_file"].toString();
                    var response = await http.get(Uri.parse(fileUri));
                    final Directory directory =
                        await getApplicationDocumentsDirectory();
                    final File file = File('${directory.path}/${element["msg_id"]}.m4a');
                    Uint8List bytes=response.bodyBytes;
                    file.writeAsBytesSync(bytes);
                    voicePaths.put(element["msg_id"],"${directory.path}/${element["msg_id"]}.m4a");
                    print("file from user successfully saved to directory and path to  hive...........");
                  } catch (e) {
                    print("failed to write audio file from user........");
                  }
                }

            bool tester = false;
            bool changes = false;
            for (var msg = 0; msg < localmsgs.length; msg++) {
              if (localmsgs[msg][5] == "1") {
                Box<String> messages = Hive.box<String>("messages");
                messages.put("${localmsgs[msg][0]}", "1");
                //delete message
                try {
                  DocumentReference refs = FirebaseFirestore.instance
                      .collection('Messages')
                      .doc(localmsgs[msg][0]);
                  refs.get().then((value) {
                    if (value.exists) {
                      refs.delete();
                      print(
                          "message  ${element["msg"]}...........deleted success from firebase");
                      storage.Reference ref = storage.FirebaseStorage.instance
                          .ref()
                          .child("MessageFiles")
                          .child("/${localmsgs[msg][0]}");

                      ref.delete();
                    }
                  }).whenComplete(() {
                    print("object succesfulyy deleted...............");
                  });
                } catch (e) {
                  // print("failed deleting item ${element["msg_id"]}...........");
                }
              }
              if (element["msg_id"] == localmsgs[msg][0]) {
                tester = true;
              }
            }

            if (!tester) {
              localmsgs.add(msggg);
            }
          }
        });

        Message mysmss = Message("messages", localmsgs);
        await SecureStorageService().writeMsgData(mysmss);
      });
      print(" firebase........ load success.");
    }
  }

  saveMessageFile(String msgId, String fileUrl) async {
    Box<Uint8List> msgFiles = Hive.box<Uint8List>("messagesFiles");
    if (msgFiles.get(msgId) == null) {
      await http.get(Uri.parse(fileUrl)).then((value) {
        Uint8List bytes = value.bodyBytes;
        msgFiles.put(msgId, bytes);
        print("image of message $msgId saved to hive.......");
      });
    }
  }

  Future groupMsgsDetails() async {
    await receiveGroupsMsgAndSaveLocal();
    // await SecureStorageService().deleteByKeySecureData("grpSmsDetails");
    // print("hellow group access vpii.....................");
    List mygroups = await SecureStorageService().readModalData("groups");

    List groupMessages =
        await SecureStorageService().readModalData("grpMessages");
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    Box<String> simples = Hive.box<String>("simples");
    if (logged.isNotEmpty) {
      List grpSmsDetails =
          await SecureStorageService().readUsersSentToMe("grpSmsDetails");

      String mimi = logged[0];
      var totalGrpsms = 0;
      for (var grp in mygroups) {
        List participants = grp[4];
        if (participants.contains(mimi)) {
          // print(
          //     "yeah group .............${grp[1]}............nipo mimi ............$mimi");
          List group = [];
          var unreaded = 0;
          var lastMsg = "";
          var lastMsgUnseen = "";
          var lastMsgunseenSender = "";
          var timeSent = "";
          List unseenMsgs = [];

          for (var msg = 0; msg < groupMessages.length; msg++) {
            List unseen = [];
            if (grp[0] == groupMessages[msg][5]) {
              // print("imeingia apaa..........ety");
              List seen = groupMessages[msg][7];
              // print("seen wote $seen    na mimi apaaaaaaaaaaa $mimi");
              if (groupMessages[msg][2] != mimi && !seen.contains(mimi)) {
                // print(
                //     "yess this message ................${groupMessages[msg][1]} n $mimi cjaonaaaaaaaaaaaaaaaaaaaaaaaaaa ");
                print("unreaded going to be added...........$unreaded. ");
                unreaded = unreaded + 1;
                print("unreaded added sucess added...........$unreaded. ");

                lastMsgUnseen = groupMessages[msg][1];

                lastMsgunseenSender = groupMessages[msg][2];
                print(
                    "unreaded added $lastMsgUnseen and sender $lastMsgunseenSender as sender ");
                unseen.add(groupMessages[msg][2]);
                unseen.add(groupMessages[msg][1]);

                if (unseen.isNotEmpty) {
                  unseenMsgs.add(unseen);
                }
              }
              lastMsg = groupMessages[msg][1];
              var format = DateFormat("yyyy-MM-dd");
              var now = format.format(DateTime.now());
              timeSent =
                  groupMessages[msg][4].toString().split(" ").removeAt(0);
              if (timeSent == now) {
                timeSent =
                    groupMessages[msg][4].toString().split(" ").removeAt(1);
              }
            }
          }
          print(
              "apaaaa njeeeeeeeeeee $lastMsgUnseen and sender $lastMsgunseenSender as sender njeeeeeeeeeee");
          group.add(grp[0]);
          group.add(grp[1]);
          group.add(unreaded);
          group.add(lastMsg);
          group.add(timeSent);
          group.add(unseenMsgs);
          group.add(grp[4]);
          group.add(grp[5]);
          group.add(lastMsgUnseen);
          group.add(lastMsgunseenSender);

          if (unreaded != 0) {
            totalGrpsms = totalGrpsms + 1;
          }
          group.add(totalGrpsms);
          bool tester2 = false;
          bool changes = false;
          bool isEmptyy = false;
          if (grpSmsDetails.isEmpty) {
            isEmptyy = true;
            grpSmsDetails.add(group);
          } else {
            for (var us = 0; us < grpSmsDetails.length; us++) {
              if (grp[0] == grpSmsDetails[us][0]) {
                tester2 = true;
              }
              if (grp[0] == grpSmsDetails[us][0]) {
                if (lastMsg != grpSmsDetails[us][3]) {
                  grpSmsDetails[us][3] = lastMsg;
                }
                if (unreaded != grpSmsDetails[us][2]) {
                  if (unreaded > grpSmsDetails[us][2]) {
                    print("unreaded is greater than iliyokuwepo............");
                    changes = true;
                    simples.delete(grp[0]);
                  }
                  grpSmsDetails[us][2] = unreaded;

                  print(
                      "updating sender and last unseeeeeeen $lastMsgUnseen and sender $lastMsgunseenSender");
                  grpSmsDetails[us][9] = lastMsgUnseen;
                  grpSmsDetails[us][10] = lastMsgunseenSender;
                }
                if (timeSent != grpSmsDetails[us][4]) {
                  grpSmsDetails[us][4] = timeSent;
                }
              }
            }
          }

          if (!tester2 && !isEmptyy) {
            grpSmsDetails.add(group);
          }
        }
      }
      //save groupMembers

      Box<String> myGrpSms = Hive.box<String>("simples");
      myGrpSms.put("grpMessags", totalGrpsms.toString());
      await SecureStorageService().deleteByKeySecureData("totalGrpSms");
      List newSorted = grpSmsDetails
        ..sort((a, b) {
          if (a[4].toString().length == b[4].toString().length) {
            return a[4].toString().compareTo(b[4].toString());
          } else {
            return b[4].toString().length.compareTo(a[4].toString().length);
          }
        });
      Modal grpdetails = Modal("grpSmsDetails", newSorted);
      await SecureStorageService().writeModalData(grpdetails);
      //send push notification

      List groupMemberss =
          await SecureStorageService().readModalData("groupMembers");
      List groupAdminss =
          await SecureStorageService().readModalData("groupAdmins");
      for (var memb in grpSmsDetails) {
        List mymembers = [];
        List myadmins = [];

        List members = memb[6];
        List admins = memb[7];
        List newmembers = [];
        List newadmins = [];
        for (var user in members) {
          List member = [];
          FirebaseFirestore.instance
              .collection("Users")
              .doc(user)
              .get()
              .then((value) {
            member.add(value["first_name"]);
            member.add(value["last_name"]);
            member.add(value["phone"]);
            member.add(value["uid"]);
          }).then((value) async {
            newmembers.add(member);
            if (newmembers.length == members.length) {
              mymembers.add(memb[0]);
              mymembers.add(newmembers);
              bool tester = false;
              bool isEmptt = false;
              if (groupMemberss.isEmpty) {
                isEmptt = true;
                if (mymembers.isNotEmpty) {
                  groupMemberss.add(mymembers);
                }
              } else {
                for (var m = 0; m < groupMemberss.length; m++) {
                  if (memb[0] == groupMemberss[m][0]) {
                    tester = true;
                  }
                }
              }
              if (!tester && !isEmptt) {
                groupMemberss.add(mymembers);
              }
              Modal groupMemb = Modal("groupMembers", groupMemberss);
              await SecureStorageService().writeModalData(groupMemb);

              if (groupMemberss.isNotEmpty) {
                print("now nityfy...... on group............");

                sendPushMsgdeatils();
              }
            }
          });
        }

        for (var adm in admins) {
          List admm = [];
          FirebaseFirestore.instance
              .collection("Users")
              .doc(adm)
              .get()
              .then((value) {
            admm.add(value["first_name"]);
            admm.add(value["last_name"]);
            admm.add(value["phone"]);
            admm.add(value["uid"]);
          }).then((value) async {
            newadmins.add(admm);
            if (newadmins.length == admins.length) {
              myadmins.add(memb[0]);
              myadmins.add(newadmins);
              bool tester2 = false;
              bool isEmptt2 = false;
              if (groupAdminss.isEmpty) {
                isEmptt2 = true;
                if (myadmins.isNotEmpty) {
                  groupAdminss.add(myadmins);
                }
              } else {
                for (var m = 0; m < groupAdminss.length; m++) {
                  if (memb[0] == groupAdminss[m][0]) {
                    tester2 = true;
                  }
                }
              }
              if (!tester2 && !isEmptt2) {
                groupAdminss.add(myadmins);
              }
              Modal groupAdm = Modal("groupAdmins", groupAdminss);
              await SecureStorageService().writeModalData(groupAdm);
            }
          });
        }

        // print("group admins $groupAdmins");
      }
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
                  // print("print compare apa ivi in notify................${mid[3]} na  ${element["uid"]}");
                  if (mid[3] == element["uid"]) {
                    isMember = true;
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
            print("primary sending notify.................");
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
                print(
                    "message going to be posted..........fro group ${grp[1]}.......................");
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
      print("no stable internet to do this notify..................");
    }
  }

  Future usersSentMsgsToMe() async {
    // await SecureStorageService().deleteByKeySecureData("usersToMe");
    print("wait for loading userss sent to mimi.......................");
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    Box<String> simples = Hive.box<String>("simples");
    if (logged.isNotEmpty) {
      String senderId = logged[0];
      FirebaseFirestore.instance
          .collection("Users")
          .where("uid", isNotEqualTo: logged[0])
          .get()
          .then((user) async {
        // print("key user sent exists  .........");

        List sentToMe =
            await SecureStorageService().readUsersSentToMe("usersToMe");
        List localmsgs =
            await SecureStorageService().readAllMsgData("messages");
        int totalMsgs = 0;
        user.docs.forEach((element) {
          if (element["uid"] != senderId) {
            List userrr = [
              element["uid"],
              element["first_name"],
              element["last_name"],
              element["phone"],
              element["created"],
              element["notify_token"],
            ];

            int numberMsgs = 0;
            String lastMsg = "";
            String timeSent = "";
            bool sentReceiver = false;
            String msgId = '';
            for (var msg = 0; msg < localmsgs.length; msg++) {
              if (element["uid"] == localmsgs[msg][2] &&
                  senderId == localmsgs[msg][3] &&
                  localmsgs[msg][5] == "0") {
                // print("this message ${localmsgs[msg][1]}    not seen already local message senn ${localmsgs[msg][5]}" );
                numberMsgs = numberMsgs + 1;
              }
              if ((element["uid"] == localmsgs[msg][3] &&
                      senderId == localmsgs[msg][2]) ||
                  (element["uid"] == localmsgs[msg][2] &&
                      senderId == localmsgs[msg][3])) {
                sentReceiver = true;
                if (localmsgs[msg][2] == senderId) {
                  lastMsg = "you: ${localmsgs[msg][1]}";
                } else {
                  lastMsg = "${localmsgs[msg][1]}";
                }
                timeSent = localmsgs[msg][7];
              }
            }
            // print("users sent to me total em apaaa ${sentToMe[0].length}");
            bool tester2 = false;
            bool isEmptyy = false;
            if (numberMsgs != 0) {
              totalMsgs = totalMsgs + 1;
            }

            // print("tester is ..........$tester2 user.........${element["uid"]} ");
            userrr.add(numberMsgs);
            userrr.add(lastMsg);
            userrr.add(timeSent);
            userrr.add(element["about"]);
            userrr.add(totalMsgs);
            bool changes = true;
            if (sentToMe.isEmpty && sentReceiver) {
              isEmptyy = true;

              sentToMe.add(userrr);
            } else {
              for (var us = 0; us < sentToMe.length; us++) {
                // print(
                //     "compare ;;;;;;;;;;;;;;;;;;....... ${element["uid"]}.............${sentToMe[us][0]}");
                if (element["uid"] == sentToMe[us][0]) {
                  tester2 = true;
                }
                if (element["uid"] == sentToMe[us][0]) {
                  if (lastMsg != sentToMe[us][7]) {
                    // print(
                    //     "changesssssss.......${element["uid"]} with last msg..........$lastMsg");
                    sentToMe[us][7] = lastMsg;
                  }
                  if (numberMsgs != sentToMe[us][6]) {
                    if (numberMsgs > sentToMe[us][6]) {
                      print("unreaded is greater than iliyokuwepo............");
                      changes = true;
                      simples.delete(sentToMe[us][0]);
                    }
                    sentToMe[us][6] = numberMsgs;
                  }
                  if (timeSent != sentToMe[us][8]) {
                    sentToMe[us][8] = timeSent;
                    // print(
                    //     "changesssssss.......${element["uid"]} with time sent msg..........$timeSent");
                  }
                }
              }
            }

            if (!tester2 && sentReceiver && !isEmptyy) {
              sentToMe.add(userrr);
            }
          }
        });
        //write toal sms
        simples.delete("totalSms");
        // simples.put("totalSms", totalMsgs.toString());
        List newSorted = sentToMe
          ..sort((a, b) {
            if (a[8].toString().length == b[8].toString().length) {
              return a[8].toString().compareTo(b[8].toString());
            } else {
              return b[4].toString().length.compareTo(a[4].toString().length);
            }
          });
        Userr myuser = Userr("usersToMe", newSorted);
        await SecureStorageService().writeUserSentToMe(myuser);
        //send notifications
        sendUserNotication();
        print("writting userss........");
      });
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
        print(
            "now sending messages to the clound for notify userssss to ${logged[4]}");
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
      print("update commited success..........");
    }).then((value) {
      print("message ...........$message updated.....");
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
      print("sent to firebase");
      await Progresshud.mySnackBar(
          context, "file for message $msgId uploaded successfully....");
    });
  }
}
