// import 'package:device_preview/device_preview.dart';
import 'dart:async';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Registration/phone.dart';
import 'package:tuchati/screens/Registration/profile.dart';
import 'package:tuchati/screens/main_tab_bar/main_tab_bar.dart';
import 'package:tuchati/screens/recording/src/globals.dart';
import 'package:tuchati/services/awesome_notify_fcm.dart';
import 'package:tuchati/services/cloud_messaging.dart';
import 'package:tuchati/services/contacts.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/groups.dart';
import 'package:tuchati/services/notification.dart';
// import 'package:tuchati/services/notification.dart';
import 'package:tuchati/services/secure_storage.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Globals.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AwesomeNotifyFcm.initialize();
   await AwesomeNotifyFcm().requestPermision();
  AwesomeNotifyFcm().listernActions();
  // await AwesomeNotifyFcm.instantNotify("hello","this is awesome broh.........",{"name":"hello anuary"});
  
  contactsCallback();
  loadSms();
  loadContacts();

  //alarm manager setup
   await AndroidAlarmManager.initialize();
   await AndroidAlarmManager.periodic(const Duration(minutes: 1), 0, allowMessaging);
  //  CloudMessaging().requestPermisiion();
   //handle background message
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //   CloudMessaging().getNotificationdataAfterClick();
  //   CloudMessaging().getNotificationdata();
  //  //local notify setup
  //  await NotificationService().setup();
  // CloudMessaging().getMyToken();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<Uint8List>("groups");
   await Hive.openBox<Uint8List>("voiceNotes");
    await Hive.openBox<String>("voiceNotesPaths");
    await Hive.openBox<Uint8List>("messagesFiles");
  await Hive.openBox<String>("simples");
  await Hive.openBox<String>("messages");
  await Hive.openBox<List<dynamic>>("sents");
  await Hive.openBox<int>("channels");
    await Hive.openBox<String>("voice");
  bool userr = await SecureStorageService().containsKey("user");
  print(userr);
  //load every time on netwok connected
   
 
//end load
  runApp(MyApp(
    user: userr,
  ));
}
//background tasks method
 void allowMessaging()async {
  print("background running now.................................");
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
   Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<Uint8List>("voiceNotes");
  await Hive.openBox<String>("voiceNotesPaths");
  await Hive.openBox<int>("channels");
  await Hive.openBox<Uint8List>("groups");
  await Hive.openBox<String>("simples");
   await Hive.openBox<String>("messages");
   await Hive.openBox<Uint8List>("messagesFiles");
     await Hive.openBox<String>("voice");
  print("background running now initialization firebase success.................................");
 
 loadSms();
}


// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   CloudMessaging().handleBackGroundMessages(message);
// }
  loadContacts() async {
    Timer.periodic(const Duration(days: 1), (timer) {
      contactsCallback();
    },);
   
  }
 contactsCallback()async{
  Timer(const Duration(seconds: 20), ()async {
     await MyContacts().phoneContacts();
  },);

 }
void loadSms() async {
  Timer(
    const Duration(seconds: 10),
    () {
      loadSmsUsers();
    },
  );
}



loadSmsUsers() async {
 
  await GroupService().filterMyGroups();
  // await FirebaseService().getGroupMembersAndSaveLocal();
  await FirebaseService().groupMsgsDetails();
  backgroungMsgs();
}

backgroungMsgs() {
   Timer(
    const Duration(seconds: 10),
    () async {
      await FirebaseService().receiveMsgAndSaveLocal();
      await FirebaseService().usersSentMsgsToMe();
      
    },
  );
}

class MyApp extends StatefulWidget {
// ...

  const MyApp({super.key, required this.user});
  final bool user;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    GetMaterialApp getXApp = GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(primaryColor: AppColors.appColor),
      home: !widget.user ? Phone() : MainTabBar(),
    );

    return getXApp;
  }
}
