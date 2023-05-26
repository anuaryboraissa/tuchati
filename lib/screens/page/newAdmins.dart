// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tuchati/services/SQLite/groups/admins/adminHelper.dart';
import 'package:tuchati/services/SQLite/modelHelpers/userHelper.dart';
import 'package:tuchati/services/SQLite/models/user.dart';

import '../../constants/app_colors.dart';
import '../../services/SQLite/groups/admins/admin.dart';
import '../../services/groups.dart';
import '../../services/secure_storage.dart';
import '../Animation/FadeAnimation.dart';
import '../groupcreate/friendscard.dart';

class NewAdmins extends StatefulWidget {
  const NewAdmins({
    Key? key,
    required this.groupId,
    required this.participants,
  }) : super(key: key);
  final String groupId;
  final List<MyUser?> participants;
  @override
  State<NewAdmins> createState() => _NewAdminsState();
}

class _NewAdminsState extends State<NewAdmins> {
  List selected = [];
  bool attempt = false;
  late Box<Uint8List> myProfile;
  late Box<Uint8List> groupsIcon;
  @override
  void initState() {
    groupsIcon = Hive.box<Uint8List>("groups");
    myProfile = Hive.box<Uint8List>("myProfile");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.fill)),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 60.0, left: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: FadeAnimation(
                        1,
                        const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        )),
                  ),
                ),
                Positioned(
                  left: 110,
                  top: 50,
                  width: 200,
                  height: 150,
                  child: FadeAnimation(
                      1.5,
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Add Admins",
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
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: widget.participants.isEmpty
                    ? const Center(
                        child: Text("No members Available To add"),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 8,
                        ),
                        itemBuilder: (context, index) {
                          MyUser? contactt = widget.participants[index];
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                if (selected.contains(contactt!.phone)) {
                                  selected.remove(contactt.phone);
                                } else {
                                  selected.add(contactt.phone);
                                }
                              });
                            },
                            child: FriendCard(
                              contact: contactt,
                              selected: selected,
                            ),
                          );
                        },
                        itemCount: widget.participants.length,
                      )),
          ),
          const SizedBox(
            height: 10,
          ),
          selected.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FadeAnimation(
                      2,
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            attempt = true;
                          });
                          //navigate
                          if (selected.isNotEmpty) {
                            addAdmins();
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [
                                AppColors.appColor,
                                AppColors.primaryColor,
                              ])),
                          child: Center(
                            child: attempt
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  )
                                : const Text(
                                    "Continue",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      )),
                )
              : const Text(""),
        ],
      ),
    );
  }

  void addAdmins() {
    DocumentReference ref =
        FirebaseFirestore.instance.collection("Groups").doc(widget.groupId);
    ref.get().then((value) async {
      if (value.exists) {
        // print("now going to save in local storage............");

        List admins = value["admins"];
        for (var s in selected) {
          //select id

          UserHelper().queryByPhone(s).then((value) {
            if (value != null) {
//update local
              AdminHelper()
                  .queryByUserGroup(value.id, widget.groupId)
                  .then((value2) async {
                if (value2 == null) {
                  //insert new admin
                  AdminModel adminModel =
                      AdminModel(grpId: widget.groupId, userId: value.id);
                  int a = await AdminHelper().insert(adminModel);
                  if (a > 0) {
                    print(
                        "hey  ${value.firstName}  %%%%% admin saved locally success");
                  }
                  print("all admins $admins compares with ${value.id}...........");
                  if (!admins.contains(value.id)) {
                    admins.add(value.id);
                    ref.update({"admins": admins}).whenComplete(() {
                      print(
                          " %%%%%%%%%%%%%%%% admins updated successfully.................");
                    });
                  }
                }
              });

            }
          });
        }
       
      }
      // print("group deosn't exist............");
    }).whenComplete(() {
      setState(() {
        attempt = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    });
  }
}
