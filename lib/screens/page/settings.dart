import 'dart:math';

import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Animation/FadeAnimation.dart';
import 'package:tuchati/screens/page/settings/notification_setting.dart';
import 'package:tuchati/screens/page/settings/storage_setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/secure_storage.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<dynamic> user = [];

  bool lockAppSwitchVal = true;
  bool fingerprintSwitchVal = false;
  bool changePassSwitchVal = true;

  TextStyle headingStyleIOS = const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: CupertinoColors.inactiveGray,
  );
  TextStyle descStyleIOS = const TextStyle(color: CupertinoColors.inactiveGray);
  initiateUser() async {
    List logged = await SecureStorageService().readByKeyData("user");
    setState(() {
      user = logged;
    });
  }

  @override
  void initState() {
    initiateUser();
    super.initState();
  }
 bool imeingia=false;
  @override
  Widget build(BuildContext context) {
    if(!imeingia){
      initiateUser();
      setState(() {
        imeingia=true;
      });
    }
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.fill)),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 130,
                  top: 50,
                  width: 200,
                  height: 150,
                  child: FadeAnimation(
                      1.5,
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Settings",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                   padding: const EdgeInsets.only(left:8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Common",
                        style: AppColors.headingStyle,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const NotificatioSetting(),
                    ));
                  },
                  leading: const Icon(Icons.notifications),
                  title: const Text("Notifications"),
                  subtitle: const Text("group,chats"),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 14,
                  ),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const StorageSetting(),
                    ));
                  },
                  leading: const Icon(Icons.storage),
                  title: const Text("Storing data"),
                  subtitle: const Text("network usage and auto downloads"),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 14,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Account", style:  AppColors.headingStyle),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Phone Number"),
                  subtitle: Text(user.isNotEmpty?"${user[3]}":""),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 14,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.mail),
                  title: const Text("UserName"),
                  subtitle: Text( user.isNotEmpty? "${user[1]} ${user[2]}":""),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 14,
                  ),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Delete My Account"),
                  subtitle: Text("this may delete your Tuchati account"),
                  trailing: Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 14,
                  ),
                ),
                Padding(
                 padding: const EdgeInsets.only(left:8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Security", style:  AppColors.headingStyle),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.phonelink_lock_outlined),
                  title: const Text("Lock app in background"),
                  trailing: Switch(
                      value: lockAppSwitchVal,
                      activeColor: Colors.redAccent,
                      onChanged: (val) {
                        setState(() {
                          lockAppSwitchVal = val;
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Misc", style:  AppColors.headingStyle),
                    ],
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.file_open_outlined),
                  title: Text("Terms of Service"),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.file_copy_outlined),
                  title: Text("Open Source and Licences"),
                ),
                const ListTile(
                  leading: Icon(Icons.help),
                  title: Text("Help"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
