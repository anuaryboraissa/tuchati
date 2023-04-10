// import 'dart:convert';

// import 'package:chat/services/notification.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;

// import 'awesome_notify_fcm.dart';

// class CloudMessaging {
//   Future<String?> getMyToken() async {
//     return await FirebaseMessaging.instance.getToken();
//   }

//   Future<AuthorizationStatus> requestPermisiion() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//     print('User granted permission: ${settings.authorizationStatus}');

//     return settings.authorizationStatus;
//   }

//   handleForegroundMessages() async {}
//   handleBackGroundMessages(RemoteMessage message) async {
//     print("Handling a background message: ${message.messageId}");
//   }

//   //at initiate state
//   getdataAfterClickNotificationAppInBackground() async {
//     FirebaseMessaging.instance.getInitialMessage().then((value) async {
//       if (value != null) {
//            Map<String, dynamic> queryParameters = value.data;
//         Map<String, String> stringQueryParameters =
//       queryParameters.map((key, value) => MapEntry(key, value.toString()));
//         // await AwesomeNotifyFcm.instantNotify( value.notification!.title!, value.notification!.body!,stringQueryParameters);
//         print("stating back ground notification..........................");
//             // await NotificationService().addNotification(
//             //     value.notification!.title!,
//             //     value.notification!.body!,
//             //     DateTime.now().millisecondsSinceEpoch + 1000,
//             //     "chat",
//             //     "pristive.mp3",
//             //     value.data);
//       }
//     });
//   }

//   //when app in foreground
//   getNotificationdataAfterClick() async {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       print('Got a message whilst in the foreground!');
//       print('Message data: ${message.data}');

//       if (message.notification != null) {
//          Map<String, dynamic> queryParameters = message.data;
//         Map<String, String> stringQueryParameters =
//       queryParameters.map((key, value) => MapEntry(key, value.toString()));
//         // await AwesomeNotifyFcm.instantNotify( message.notification!.title!, message.notification!.body!,stringQueryParameters);
//         //handle notification local
//         print("stating fore ground notification..........................");
//             // await NotificationService().addNotification(
//             //     message.notification!.title!,
//             //     message.notification!.body!,
//             //     DateTime.now().millisecondsSinceEpoch + 1000,
//             //     "chat",
//             //     "pristive.mp3",
//             //     message.data);
//       }
//     });
//   }

//   //when app is background but not terminated
//   getNotificationdata() async {
//     FirebaseMessaging.onMessageOpenedApp.listen((event) async {
//       if (event.notification != null) {
//             Map<String, dynamic> queryParameters = event.data;
//         Map<String, String> stringQueryParameters =
//       queryParameters.map((key, value) => MapEntry(key, value.toString()));
//         // await AwesomeNotifyFcm.instantNotify( event.notification!.title!, event.notification!.body!,stringQueryParameters);
//         print("stating sneezed app notification..........................");
//           // await NotificationService().addNotification(
//           //     event.notification!.title!,
//           //     event.notification!.body!,
//           //     DateTime.now().millisecondsSinceEpoch + 1000,
//           //     "chat",
//           //     "pristive.mp3",
//           //     event.data);
//       }
//     });
//   }

//   sendPushMessage(String token, String body, String title) async {
//     print(
//         "now sending push message to server...............granted............");

//     if (token != "") {
//       print("wait it send to the server broh................");
//       try {
//         await http
//             .post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
//                 headers: <String, String>{
//                   "Content-type": "application/json",
//                   "Authorization":
//                       "key=AAAAEiH-wr4:APA91bHFA4kD3X_iCs1TjWj18hHtNoxfcoQ2E4WMf15mgiKi8vMw9jLfb2WW1x8PZZZtVCwcLLEl5WXy5-9lN4cqsXClFXOIBNaUNEpzEeCL3MKVH85xRrmrqla5tbcOg_7ldDPzkU5t"
//                 },
//                 body: jsonEncode(<String, dynamic>{
//                   "priority": "high",
//                   "data": <String, dynamic>{
//                     "click_action": "FLUTTER_NOTIFICATION_CLICK",
//                     "status": "done",
//                     "body": body,
//                     "title": title
//                   },
//                   "notification": <String, dynamic>{
//                     "title": title,
//                     "body": body,
//                     "android_channel_id": "chat"
//                   },
//                   "to": token
//                 }))
//             .then((value) {
//           print("notification response is ${value.statusCode}  ${value.body}");
//         });
//       } catch (e) {
//         print("No stable internet broh............................");
//       }
//     } else {
//       print("authorization no granted......................now.............");
//     }
//   }

//   sendNotifyWithAwesomefcm(String token,List body,String title,) async {
//      print("starting awesome notifications send........................");
//     if (token != "") {
//       try {
//         await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               "Authorization":
//                   "key=AAAAEiH-wr4:APA91bHFA4kD3X_iCs1TjWj18hHtNoxfcoQ2E4WMf15mgiKi8vMw9jLfb2WW1x8PZZZtVCwcLLEl5WXy5-9lN4cqsXClFXOIBNaUNEpzEeCL3MKVH85xRrmrqla5tbcOg_7ldDPzkU5t"
//             },
//             body: jsonEncode(<String, dynamic>{
//               "to": token,
//               "priority": "high",
//               "mutable_content": true,
//               "notification": {
//                 "badge": 42,
//                 "title": title,
//                 "body":
//                     body
//               },
//               "data": {
//                 "content": {
//                   "id": 1,
//                   "badge": 42,
//                   "channelKey": "alerts",
//                   "displayOnForeground": true,
//                   "notificationLayout": "BigPicture",
//                   "largeIcon":
//                       "https://br.web.img3.acsta.net/pictures/19/06/18/17/09/0834720.jpg",
//                   "bigPicture": "https://www.dw.com/image/49519617_303.jpg",
//                   "showWhen": true,
//                   "autoDismissible": true,
//                   "privacy": "Private",
//                   "payload": body
//                 },
//                 "actionButtons": [
//                   {
//                     "key": "REDIRECT",
//                     "label": "Redirect",
//                     "autoDismissible": true
//                   },
//                   {
//                     "key": "DISMISS",
//                     "label": "Dismiss",
//                     "actionType": "DismissAction",
//                     "isDangerousOption": true,
//                     "autoDismissible": true
//                   }
//                 ],
//                 "Android": {
//                   "content": {
//                     "title": "Android! The eagle has landed!",
//                     "payload": {"android": "android custom content!"}
//                   }
//                 },
           
//               }
//             })).then((value) {
//               print("complete notification send with status ${value.statusCode}.......and body ${value.body}.............");
//             });
//       } catch (e) {
//         print("Network connection is low...............");
//       }
//     }
//   }
// }
