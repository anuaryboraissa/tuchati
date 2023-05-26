import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:firebase_storage/firebase_storage.dart" as storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Registration/phone.dart';
import 'package:tuchati/screens/page/dialogue/dialogueBoxes.dart';
import 'package:tuchati/screens/page/progress/progress.dart';
import 'package:tuchati/services/SQLite/modelHelpers/userHelper.dart';
import 'package:tuchati/services/secure_storage.dart';

import '../../main.dart';
import '../../services/SQLite/databaseHelper/logout.dart';
import '../../services/SQLite/modelHelpers/directsmsdetails.dart';
import '../../services/SQLite/modelHelpers/grpDetailsHelper.dart';
import '../Animation/FadeAnimation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _iconn;
  File? filee;
  Future<void> getGroupIcon() async {
    ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
      setState(() {
        _iconn = File(value!.path);
        filee = File(value.path);
      });
      //
      editProfile(filee);
    });
  }

  int activeGroups = 0;
  getActives() {
    var format = DateFormat("yyyy-MM-dd HH:mm");
    var now = format.format(DateTime.now());
    DirectSmsDetailsHelper().queryAll().then((value) {
      setState(() {
        activeUsers = value
            .where((element) =>
                DateTime.parse(now)
                    .difference(DateTime.parse(element!.date))
                    .inDays <=
                2)
            .toList()
            .length;
      });
    });
    GroupSmsDetailsHelper().queryAll().then((value) {
      setState(() {
        activeGroups = value
            .where((element) =>
                DateTime.parse(now)
                    .difference(DateTime.parse(element!.date))
                    .inDays <=
                2)
            .toList()
            .length;
      });
    });
  }

  editProfile(File? file) async {
    //save local
    initProgressDialogue();
    await Progresshud.show("Updating profile..");
    Uint8List photo = file!.readAsBytesSync();
    profiles.put("photo", photo);
    //save to firebase
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    storage.UploadTask task;
    storage.Reference ref = storage.FirebaseStorage.instance
        .ref()
        .child("UserProfiles")
        .child("/${logged[0]}");
    task = ref.putFile(file);
    task.whenComplete(() async {
      await Progresshud.dismiss();
      // ignore: use_build_context_synchronously
      await DialogueBox.showInOutDailog(
          context: context,
          yourWidget: DialogueBox().successWiget("profile updated"),
          firstButton: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.appColor),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("ok")));
    });
  }

  TextEditingController about = TextEditingController();
  editAbout() async {
    await DialogueBox.showInOutDailog(
        context: context,
        yourWidget: editAboutWidget(),
        firstButton: ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.appColor),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                FirebaseFirestore.instance
                    .collection("Users")
                    .doc(userId)
                    .update({"about": about.text});
                getUserAboutTuchati();
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                await Progresshud.mySnackBar(
                    context, "you need to fill the field");
              }
            },
            child: const Text("save")));
  }

  signOut() async {
    await DialogueBox.showInOutDailog(
        context: context,
        yourWidget: confirmSignOutWidget(),
        firstButton: ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.appColor),
            onPressed: () {
              Navigator.pop(context);
              loggingOut();
            },
            child: const Text("yes")),
        secondButton: ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.appColor),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("no")));
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Widget editAboutWidget() {
    return Column(
      children: [
        const Padding(
            padding: EdgeInsets.all(10),
            child: Text("updating User Tuchati Description")),
        Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter about Tuchati";
                }
                return null;
              },
              keyboardType: TextInputType.text,
              controller: about,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: aboutTuchati,
                  hintStyle: TextStyle(color: Colors.grey[400])),
            ),
          ),
        ),
      ],
    );
  }

  //confirm signout
  Widget confirmSignOutWidget() {
    return Column(
      children: const [
        Padding(
            padding: EdgeInsets.all(10),
            child: Text("Are you sure you want to sign out from this app!!!")),
      ],
    );
  }

  // List<String> userdata = [widget.uid, text, text2, widget.phone,""];

  String aboutTuchati = "";
  String userId = "";
  getUserAboutTuchati() {
    SecureStorageService().readByKeyData("user").then((value1) {
      print("value $value1");
      setState(() {
        aboutTuchati = value1[4];
      });
      FirebaseFirestore.instance
          .collection("Users")
          .doc(value1[0])
          .get()
          .then((value) {
        setState(() {
          userId = value1[0];

          if (value["about"] != value1[4]) {
            aboutTuchati = value["about"];
            value1[4] = value["about"];
            StorageItem item = StorageItem("user", value1);
            SecureStorageService().writeSecureData(item);
          }
        });
      });
    });
  }

  initProgressDialogue() async {
    await Progresshud.initializeDialogue(context);
  }

  late Box<Uint8List> groupsIcon;
  late Box<Uint8List> profiles;
  @override
  void initState() {
    getUserAboutTuchati();
    profiles = Hive.box<Uint8List>("myProfile");
    groupsIcon = Hive.box<Uint8List>("groups");
    initiateUser();
    getActives();
    super.initState();
  }

  initUsers() {}
  int activeUsers = 0;
  List user = [];
  List groupss = [];

  initiateUser() {
    SecureStorageService().readByKeyData("user").then((value) {
      setState(() {
        user = value;
      });
    });
    SecureStorageService().readModalData("groups").then((value) {
      setState(() {
        groupss = value;
      });
    });
  }

  int imeigia = 0;
  @override
  Widget build(BuildContext context) {
    if (imeigia < 2) {
      initiateUser();
      setState(() {
        imeigia = imeigia + 1;
      });
    }
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.fill)),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 120,
                  top: 50,
                  width: 200,
                  height: 150,
                  child: FadeAnimation(
                      1.5,
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "My Profile",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
                Positioned(
                  top: 100,
                  left: 100,
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: AppColors.appColor,
                    child: CircleAvatar(
                      backgroundImage: filee == null
                          ? MemoryImage(profiles.get("photo") ??
                              groupsIcon.get("userDefault")!)
                          : MemoryImage(filee!.readAsBytesSync()),
                      backgroundColor: Colors.white24,
                      radius: 70,
                    ),
                  ),
                ),
                Positioned(
                  right: 110,
                  top: 190,
                  child: ClipOval(
                      child: Container(
                    padding: const EdgeInsets.all(4),
                    color: Colors.white,
                    child: IconButton(
                      onPressed: () async {
                        // print("take picture...........");
                        await getGroupIcon();
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 25,
                        color: AppColors.appColor,
                      ),
                    ),
                  )),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView(
              children: [
                Container(
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.center,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Common",
                                style: AppColors.headingStyle,
                              ),
                            ],
                          ),
                          ListTile(
                            leading: const Icon(Icons.group),
                            title: const Text("Groups"),
                            trailing: Text(activeGroups.toString(),
                                style: TextStyle(
                                    color: AppColors.appColor,
                                    fontWeight: FontWeight.bold)),
                            subtitle: const Text("For last 2 days"),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.people_alt),
                            title: const Text("Active Friends"),
                            trailing: Text(
                              activeUsers.toString(),
                              style: TextStyle(
                                  color: AppColors.appColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text("For last 2 days"),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.warning_rounded),
                            title: const Text("About"),
                            subtitle: Text(aboutTuchati,
                                style: TextStyle(color: AppColors.appColor)),
                            trailing: IconButton(
                                onPressed: () {
                                  editAbout();
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.appColor,
                                )),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Accounts",
                                style: AppColors.headingStyle,
                              ),
                            ],
                          ),
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: const Text("Phone Number"),
                            subtitle: Text(user.isNotEmpty ? "${user[3]}" : "",
                                style: TextStyle(color: AppColors.appColor)),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text("Username"),
                            subtitle: Text(
                                user.isNotEmpty ? "${user[1]} ${user[2]}" : "",
                                style: TextStyle(color: AppColors.appColor)),
                          ),
                          ListTile(
                            onTap: signOut,
                            leading: const Icon(Icons.logout),
                            title: const Text("Logout"),
                            subtitle:
                                const Text("logging out from your account"),
                          ),
                        ]))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future deleteData() async {
    Box<String> simples = Hive.box<String>("simples");
    Box<String> voiceNotesPaths = Hive.box<String>("voiceNotesPaths");
    Box<List<dynamic>> sents = Hive.box<List<dynamic>>("sents");
    Box<String> msgs = Hive.box<String>("messages");
    Box<Uint8List> files = Hive.box<Uint8List>("messagesFiles");
    Box<String> voice = Hive.box<String>("voice");
    Box<Uint8List> myProfile = Hive.box<Uint8List>("myProfile");
    Box<Uint8List> groupsIcon = Hive.box<Uint8List>("groups");
    Box<int> channels = Hive.box<int>("channels");

    //delete all keys
    print("deleting keys.........^^^^^^^^^^^");
    voice.deleteAll(voice.keys);
    myProfile.deleteAll(myProfile.keys);
    simples.deleteAll(simples.keys);
    msgs.deleteAll(msgs.keys);
    files.deleteAll(files.keys);
    groupsIcon.deleteAll(groupsIcon.keys);
    sents.deleteAll(sents.keys);
    channels.deleteAll(channels.keys);
    voiceNotesPaths.deleteAll(voiceNotesPaths.keys);
    print(" keys....deleted           .....^^^^^^^^^^^");
  }

  loggingOut() async {
    Progresshud.initializeDialogue(context);
    await Progresshud.show("logging out.....");
    FirebaseAuth.instance.signOut().whenComplete(() async {
      await deleteData();
      await SecureStorageService().deleteByKeySecureData("user");
      await SecureStorageService().deleteByKeySecureData("groups");
      await SecureStorageService().deleteByKeySecureData("grpMessages");
      await SecureStorageService().deleteByKeySecureData("groupMembers");
      await SecureStorageService().deleteByKeySecureData("grpSmsDetails");
      await SecureStorageService().deleteByKeySecureData("messages");
      await SecureStorageService().deleteByKeySecureData("totalSms");
      await SecureStorageService().deleteByKeySecureData("usersToMe");
      await SecureStorageService().deleteByKeySecureData("groupLefts");
      await SecureStorageService().deleteByKeySecureData("groupAdmins");
      List savedContacts =
          await SecureStorageService().readCntactsData("contacts");
      for (var cont in savedContacts) {
        // print("deleting ...........contact  ${cont[0]}");
        await SecureStorageService()
            .deleteByKeySecureData(cont[0].toString().replaceAll(" ", ""));
      }
      await SecureStorageService().deleteByKeySecureData("contacts");
      LogoutHelper().database;
      await AndroidAlarmManager.periodic(
          const Duration(minutes: 1), 0, allowMessaging);
      await Progresshud.dismiss();
      Navigator.popUntil(context, (route) => route.isFirst);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Phone(),
      ));
    });
    // ignore: use_build_context_synchronously

    //   // ignore: use_build_context_synchronously
  }
}
