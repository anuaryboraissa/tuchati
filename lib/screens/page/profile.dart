import 'dart:io';

import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/main.dart';
import 'package:tuchati/screens/Registration/phone.dart';
import 'package:tuchati/screens/page/progress/progress.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

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
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _iconn = File(file!.path);
      filee = File(file.path);
    });
  }

  late Uint8List list;
  getDefaultImage() async {
    final ByteData bytes = await rootBundle.load('assets/images/user.png');
    list = bytes.buffer.asUint8List();
    groupsIcon.put("userDefault", list);
  }

  initProgressDialogue() async {
    await Progresshud.initializeDialogue(context);
  }

  late Box<Uint8List> groupsIcon;
  @override
  void initState() {
    initProgressDialogue();
    groupsIcon = Hive.box<Uint8List>("groups");
    getDefaultImage();
    initiateUser();
    super.initState();
  }

  initUsers() {}
  List user = [];
  List groupss = [];
  List activeUsers = [];
  initiateUser()  {
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
    SecureStorageService().readUsersSentToMe("usersToMe").then((value) {
      setState(() {
        activeUsers = value;
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
                          ? MemoryImage(groupsIcon.get("userDefault")!)
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
                        print("take picture...........");
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
                            subtitle: Text(
                                groupss.isNotEmpty ? "${groupss.length}" : ""),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.people_alt),
                            title: const Text("Active Friends"),
                            subtitle: Text(activeUsers.isNotEmpty
                                ? "${activeUsers.length}"
                                : ""),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.warning_rounded),
                            title: const Text("About"),
                            subtitle: const Text("Hey there i'm using Tuchati"),
                            trailing: IconButton(
                                onPressed: () {
                                  print("edit about.....");
                                },
                                icon: const Icon(Icons.edit)),
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
                            subtitle: Text(user.isNotEmpty ? "${user[3]}" : ""),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text("Username"),
                            subtitle: Text(
                                user.isNotEmpty ? "${user[1]} ${user[2]}" : ""),
                          ),
                          ListTile(
                            onTap: () {
                              loggingOut();
                            },
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

  deleteData() async {
    Box<String> simples = Hive.box<String>("simples");
    Box<String> voiceNotesPaths = Hive.box<String>("voiceNotesPaths");
    Box<List<dynamic>> sents = Hive.box<List<dynamic>>("sents");
    Box<String> msgs = Hive.box<String>("messages");
    Box<Uint8List> files = Hive.box<Uint8List>("messagesFiles");
    Box<Uint8List> groupsIcon = Hive.box<Uint8List>("groups");
    Box<int> channels = Hive.box<int>("channels");
    //delete all keys
    simples.deleteAll(simples.keys);
    msgs.deleteAll(msgs.keys);
    files.deleteAll(files.keys);
    groupsIcon.deleteAll(groupsIcon.keys);
    sents.deleteAll(sents.keys);
    channels.deleteAll(channels.keys);
    voiceNotesPaths.deleteAll(voiceNotesPaths.keys);
    await SecureStorageService().deleteByKeySecureData("groups");
    await SecureStorageService().deleteByKeySecureData("grpMessages");
    await SecureStorageService().deleteByKeySecureData("groupMembers");
    await SecureStorageService().deleteByKeySecureData("grpSmsDetails");
    await SecureStorageService().deleteByKeySecureData("user");
    await SecureStorageService().deleteByKeySecureData("messages");
    await SecureStorageService().deleteByKeySecureData("totalSms");
    await SecureStorageService().deleteByKeySecureData("usersToMe");
    await SecureStorageService().deleteByKeySecureData("groupLefts");
    await SecureStorageService().deleteByKeySecureData("groupAdmins");
    List savedContacts =
        await SecureStorageService().readCntactsData("contacts");
    for (var cont in savedContacts) {
      print("deleting ...........contact  ${cont[0]}");
      await SecureStorageService()
          .deleteByKeySecureData(cont[0].toString().replaceAll(" ", ""));
    }
    await SecureStorageService().deleteByKeySecureData("contacts");
  }

  void loggingOut() async {
    //login out with firebase
    await Progresshud.show("logging out.....");
    if (!await Progresshud.isShowing()) {
      // ignore: use_build_context_synchronously
      await Progresshud.mySnackBar(context, "logging out..");
    }
    try {
      // ignore: use_build_context_synchronously
      await Progresshud.mySnackBar(context, "deleting contacts.....");
      deleteData();
      FirebaseAuth.instance.signOut();

      // ignore: use_build_context_synchronously
      Navigator.popUntil(context, (route) => route.isFirst);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Phone(),
      ));
      if (await Progresshud.isShowing()) {
        await Progresshud.dismiss();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously

      if (await Progresshud.isShowing()) {
        await Progresshud.dismiss();
      }
    }
    //clear user data
  }
}
