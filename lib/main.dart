// import 'package:device_preview/device_preview.dart';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_offline/flutter_offline.dart';
// ignore: depend_on_referenced_packages
// import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Registration/phone.dart';
import 'package:tuchati/screens/main_tab_bar/main_tab_bar.dart';
import 'package:tuchati/screens/recording/src/globals.dart';
import 'package:tuchati/services/SQLite/implementation.dart';
import 'package:tuchati/services/SQLite/modelHelpers/directsmsdetails.dart';
import 'package:tuchati/services/SQLite/models/msgDetails.dart';
import 'package:tuchati/services/awesome_notify_fcm.dart';
import 'package:tuchati/services/contacts.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/groups.dart';
// import 'package:tuchati/services/notification.dart';
import 'package:tuchati/services/secure_storage.dart';

import 'firebase_options.dart';

@pragma("vm:entry-point")
void allowMessaging() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("background running now.................................");
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<Uint8List>("voiceNotes");
  await Hive.openBox<String>("voiceNotesPaths");
  await Hive.openBox<int>("channels");
  await Hive.openBox<Uint8List>("groups");
  await Hive.openBox<Uint8List>("myProfile");
  await Hive.openBox<String>("simples");
  await Hive.openBox<List<String>>("lefts");
  await Hive.openBox<String>("messages");
  await Hive.openBox<Uint8List>("messagesFiles");
  await Hive.openBox<String>("voice");
    await Hive.openBox<List<dynamic>>("sents");
   List<dynamic> logged = await SecureStorageService().readByKeyData("user");
   if(logged.isNotEmpty){
     FirebaseFirestore.instance.collection("Users").doc(logged[0]).get().then((value) {
      if(value["online_status"]){
         print("yes is online now......&&&&&&&&&&&&&&&& fetch his/her details.");
         loadSmsUsers();
      }
     });
       
   }

}




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Globals.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AwesomeNotifyFcm.initialize();
 
  await AwesomeNotifyFcm().requestPermision();
  AwesomeNotifyFcm().listernActions();
  Directory document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox<Uint8List>("voiceNotes");
  await Hive.openBox<String>("voiceNotesPaths");
  await Hive.openBox<int>("channels");
  await Hive.openBox<Uint8List>("groups");
  await Hive.openBox<Uint8List>("myProfile");
  await Hive.openBox<String>("simples");
  await Hive.openBox<List<String>>("lefts");
  await Hive.openBox<String>("messages");
  await Hive.openBox<Uint8List>("messagesFiles");
  await Hive.openBox<String>("voice");
  await Hive.openBox<List<dynamic>>("sents");
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.periodic(
      const Duration(minutes: 1), 0, allowMessaging);
  allowMessaging();
  await FirebaseService().storeFirebaseUsersInLocal();
  bool userr = await SecureStorageService().containsKey("user");
  print(userr);
  runApp(MyApp(
    user: userr,
  ));
}

loadSmsUsers() async {
  int initial = 0;


    
  Timer.periodic(const Duration(seconds: 2), (timer) async {
    if (initial <= 30) {
      print("initial timer $initial");
      initial = initial + 1;
        
        await FirebaseService().receiveMsgAndSaveLocal();
      await FirebaseService().receiveGroupsMsgAndSaveLocal();
      
      if (timer.tick % 2 == 0) {
         await FirebaseService().storeFirebaseUsersInLocal();
         await FirebaseService().filterMyGroups();
      } else {}

      
    }
    else{
      timer.cancel();
    }
  });
}

class MyApp extends StatefulWidget {
// ...

  const MyApp({super.key, required this.user});
  final bool user;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
    snackBar(String? message,context,bool sts) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: sts?Colors.green:Colors.red[400],
        content: Text(message!,textAlign: TextAlign.center,),
        duration: const Duration(seconds: 2),
        width: 280.0,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
    updateStatus(status,contex,String stat) async {
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    if (logged.isNotEmpty) {
      DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
      var lastSeen = format.format(DateTime.now());
      DocumentReference ref =
          FirebaseFirestore.instance.collection("Users").doc(logged[0]);
      ref.get().then((value) {
        if (status) {
             ref.update({"online_status": true, "last_seen": lastSeen});
          if(stat=="2"){
          snackBar("${logged[1]}, You're back online",contex,true);
          }
       
        } else {
           String userLastSeen = value["last_seen"];
          ref.update({"online_status": false, "last_seen": userLastSeen});
         if(stat=="2"){
          snackBar("${logged[1]}, You're offline",contex,false);
          }
        
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // print("updating online to true.................................");
      updateStatus(true,context,"1");
    } else {
      // print("updating online to false.................................");
      updateStatus(false,context,"1");
    }
  }

  @override
  void initState() {
     WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    GetMaterialApp getXApp = GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(primaryColor: AppColors.appColor),
      home: Scaffold(
        body: OfflineBuilder(connectivityBuilder: (context, value, child) {
             final bool connected = value != ConnectivityResult.none;
            updateStatus(connected,context,"2");
          return !widget.user ? Phone() : const MainTabBar();
        },
        child:const Text("")),
      )
    );

    return getXApp;
  }
}
