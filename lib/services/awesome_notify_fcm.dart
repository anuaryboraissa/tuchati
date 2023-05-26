// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
// import 'package:tuchati/main.dart';
// import 'package:firebase_core/firebase_core.dart';
// import "package:http/http.dart" as http;

import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/page/progress/progress.dart';
import 'package:tuchati/services/SQLite/updateDetails.dart';
import 'package:tuchati/services/groups.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'SQLite/modelHelpers/dirMsgsHelper.dart';
import 'SQLite/modelHelpers/directsmsdetails.dart';
import 'SQLite/modelHelpers/grpMsgsHelper.dart';
import 'SQLite/models/dirMessages.dart';
import 'SQLite/models/groupMessages.dart';
import 'SQLite/models/msgDetails.dart';
import 'firebase.dart';

class AwesomeNotifyFcm {
//   //  *********************************************
//   ///     INITIALIZATION METHODS
//   ///  *********************************************
  static Future initialize() async {
    //null for default icon 'resource://drawable/res_notification_app_icon',
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
          channelKey: "basic_channel",
          channelGroupKey: "tuchati_wote",
          groupKey: "tuchati",
          groupSort: GroupSort.Desc,
          groupAlertBehavior: GroupAlertBehavior.Summary,
          channelName: "firebase",
          importance:
              NotificationImportance.High, //must appear from the top of screen
          channelShowBadge: true, //icons number of in app
          //  locked: true, //must swap or tap
          soundSource: "resource://raw/pristive",
          channelDescription: "notifying userss",
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white)
    ]);
  }

  static Future<bool> instantNotify(String title, String body,
      Map<String, String> payload, int channel) async {
    await Firebase.initializeApp();
    final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
    return awesomeNotifications.createNotification(
        content: NotificationContent(
            category: NotificationCategory.Message,
            groupKey: "tuchati",
            summary: "from 2 chats",
            id: channel,
            title: title,
            channelKey: "basic_channel",
            body: body,
            payload: payload),
        actionButtons: [
          NotificationActionButton(
              key: "mark", label: "Mark as Read", color: AppColors.appColor),
          NotificationActionButton(
            autoDismissible: true,
              buttonType: ActionButtonType.InputField,
              key: "reply",
              label: "Reply",
              color: AppColors.appColor)
        ]);
  }

  bool isNumeric(String s) {
    // ignore: unnecessary_null_comparison
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

//user messg
  void sendMessage(messag, receiver) async {
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    while (await FirebaseService().checkIfMsgExist(msgId)) {
      // print("msg existssssssssssss ipo ");
      msgId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    String seen = "0";
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
    var nowDate = format.format(DateTime.now());
    var now = DateFormat.Hm().format(DateTime.now());

    List attributes = [
      msgId,
      messag,
      logged[0],
      receiver,
      "",
      seen,
      nowDate,
      now,
    ];
    attributes.add("0");
    attributes.add("0");
    attributes.add("0");
    attributes.add("0");
    attributes.add("");

    List msgs = [];
    DirectMessage directMsg = DirectMessage(
        msgId: int.parse(attributes[0]),
        msg: attributes[1],
        sender: attributes[2],
        receiver: attributes[3],
        replied: attributes[4],
        repliedMsgId: attributes[10],
        seen: attributes[5],
        time: now,
        date: nowDate,
        fileName: attributes[8],
        msgFile: "0",
        fileSize: attributes[9]);
    int result = await DirMsgsHelper().insert(directMsg);
    if (result > 0) {
      print("data inserted successfully..........");
        UpdateDetails().updateUserDetails(attributes[1], now, nowDate,attributes[3]);
    }
    await FirebaseService().sendMessage(attributes);
  }

//reply group
  sendGrpMessage(msg, receiver) async {
    String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    while (await FirebaseService().checkIfMsgIdExist(msgId)) {
      msgId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    String mysms = msg;
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
    var nowDate = format.format(DateTime.now());
    List seen = [];

    List attributes = [
      msgId,
      mysms,
      logged[0],
      "",
      nowDate,
      receiver,
      "0",
      seen
    ];

    attributes.add("0");
    attributes.add("0");
    attributes.add("0");
    attributes.add("");
    attributes.add("");

   GroupMessage grpMsg = GroupMessage(
        msgId: int.parse(attributes[0]),
        msg: attributes[1],
        sender: attributes[2],
        grpId: receiver,
        replied: "",
        repliedMsgId: "",
        date: nowDate,
        fileName: attributes[8],
        msgFile: "0",
        fileSize: attributes[9],
        repliedMsgSender: "");
    int result = await GrpMsgsHelper().insert(grpMsg);
    if (result > 0) {
        UpdateDetails().updateGroupDetails(attributes[1], "you", nowDate,
           receiver.toString(),0);
    }
    await GroupService().saveGrpMessages(attributes, null);
  }

  listernActions() {
    AwesomeNotifications().actionStream.listen((notificaton) async {
      
      Map<String, String>? payload = notificaton.payload;
      String userId = payload!["user"].toString();
      String name = payload["name"].toString();
      String lastMsg=payload["lastMessage"].toString();
      String date=payload["date"].toString();
      String time=payload["time"].toString();
      if (notificaton.buttonKeyPressed == "reply") {
        if (notificaton.buttonKeyInput.isNotEmpty) {
          // print("no reply made.............");
          String message = notificaton.buttonKeyInput;
          if (isNumeric(userId)) {
            //group msg
            sendGrpMessage(message, userId);
          } else {
            sendMessage(message, userId);
          }
           await markRead(userId,lastMsg,time,date);
        }
      } else if (notificaton.buttonKeyPressed == "mark") {
        //mark as read
        await markRead(userId,lastMsg,time,date);

        // print("Mark as read now button is pressed.  update");
      }
    });
  }

  Future<void> markRead(String userId,lastMsg,time,date) async {
      List<dynamic> logged =
        await SecureStorageService().readByKeyData("user");
    if (isNumeric(userId)) {
      //group msg
      //group
    
      String whoSee = logged[0];
    
      FirebaseFirestore.instance
          .collection("GroupMessages")
          .where("grp_id", isEqualTo: userId)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          List saws = element["seen"];
          bool see = false;
          if (saws.isEmpty) {
            saws.add(whoSee);
          } else {
            for (var s in saws) {
              if (s == whoSee) {
                //kashaona
                see = true;
              }
            }
            if (!see) {
              saws.add(whoSee);
            }
          }
          final json = {"seen": saws};
          FirebaseFirestore.instance
              .collection("GroupMessages")
              .doc(element["msg_id"])
              .update(json)
              .whenComplete(()  {
      
          });
        });
      });
    } else {
      //user message
      UpdateDetails().updateUserDetails(lastMsg, time, date, userId);
      FirebaseFirestore.instance
          .collection("Messages")
          .where("sender", isEqualTo: userId)
          .where("receiver", isEqualTo: logged[0])
          .get()
          .then((value) {
        value.docs.forEach((element) {
          if (element["seen"] == "0") {
            final json = {"seen": "1"};
            FirebaseFirestore.instance
                .collection("Messages")
                .doc(element["msg_id"])
                .update(json)
                .whenComplete(() async {
              // print("seen updated successfully........user direct  .......saws message ${value["msg"]}");
              List localmsgss =
                  await SecureStorageService().readAllMsgData("messages");
              for (var msg = 0; msg < localmsgss.length; msg++) {
                if (localmsgss[msg][0] == element["msg_id"]) {
                  localmsgss[msg][5] = "1";
                  Modal mysmss = Modal("messages", localmsgss);
                  await SecureStorageService().writeModalData(mysmss);
                }
              }
            });
          }
        });
      });
          
    }
  }

  Future<void> requestPermision() async {
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      await AwesomeNotifications()
          .requestPermissionToSendNotifications()
          .then((value) {
        // print("permission granted........$value");
      });
    } else {
      // print("permission granted........success");
    }
  }

  //ondispose method
  disposeStreams() {
    AwesomeNotifications().actionSink.close();
    AwesomeNotifications().createdSink.close();
  }
//  //on background but not terminated
//  onOpenedApp()async{
//   AwesomeNotifications().getInitialNotificationAction().then((value) {
//    if(value!=null){
//       print("body received is ${value.body}");
//     }
//   });
//  }

//   //  *********************************************
//   ///     REMOTE NOTIFICATION EVENTS
//   ///  *********************************************

//   /// Use this method to execute on background when a silent data arrives
//   /// (even while terminated)
//   @pragma("vm:entry-point")
//   static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
//     print('"SilentData": ${silentData.toString()}');

//     if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
//       print(
//           "bg........................................                 ...........");
//     } else {
//       print(
//           "FOREGROUND.................                                ............");
//     }

//     print(
//         "starting long task .......     ..........     ..........        .........");

//     await Future.delayed(const Duration(seconds: 4));
//     loadSms();
//     // final url = Uri.parse("http://google.com");
//     // final re = await http.get(url);
//     // print(re.body);
//     // print("long task done............................");
//   }

//   /// Use this method to detect when a new fcm token is received
//   @pragma("vm:entry-point")
//   static Future<void> myFcmTokenHandle(String token) async {
//     print('FCM Token:"$token"');
//   }

//   /// Use this method to detect when a new native token is received
//   @pragma("vm:entry-point")
//   static Future<void> myNativeTokenHandle(String token) async {
//     print('Native Token:"$token"');
//   }
}
