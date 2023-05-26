// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuchati/services/SQLite/groups/participants/participantHelper.dart';

import '../../constants/app_colors.dart';
import '../../services/SQLite/groups/participants/participant.dart';
import '../../services/SQLite/models/user.dart';
import '../../services/secure_storage.dart';
import '../Animation/FadeAnimation.dart';
import '../groupcreate/friendscard.dart';

class NewMember extends StatefulWidget {
  const NewMember({
    Key? key,
    required this.groupId,
    required this.participants,
  }) : super(key: key);
  final String groupId;
  final List<MyUser?> participants;
  @override
  State<NewMember> createState() => _NewMemberState();
}

class _NewMemberState extends State<NewMember> {
  bool attempt = false;
  List selected = [];
  List selectedUsers = [];
  Future<List>? data;

  // late Timer timer;
  // useTimer() {
  //   timer = Timer(
  //     const Duration(seconds: 55),
  //     () {
  //       setState(() {
  //         data = SecureStorageService().readCntactsData("contacts");
  //       });
  //     },
  //   );
  // }

  // List friendsToAdd = [];
  // filterContactsNotInGrp() {
  //   SecureStorageService().readCntactsData("contacts").then((value) {
  //     MyUser? grpMembers = widget.participants;
  //     for (var c in value) {
  //       bool contactExist = false;
  //       for (var memb in grpMembers) {
  //         print(
  //             "compare contact as .......${c[0]} and member contact as ${memb[2]}");
  //         if (memb[2] == c[0].toString().replaceAll(" ", "")) {
  //           contactExist = true;
  //         }
  //       }
  //       if (!contactExist && !friendsToAdd.contains(c)) {
  //         setState(() {
  //           friendsToAdd.add(c);
  //         });
  //       }
  //     }
  //   });
  // }

  @override
  void initState() {
    // filterContactsNotInGrp();
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
                          "Add Participants",
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
                          MyUser? contact = widget.participants[index];
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                if (selected.contains(contact!.phone)) {
                                  print("remove ..${contact.id}");
                                  selected.remove(contact.phone);
                                  selectedUsers.remove(contact.id);
                                } else {
                                  print("add ..${contact.id}");
                                  selectedUsers.add(contact.id);
                                  selected.add(contact.phone);
                                }
                              });
                            },
                            child: FriendCard(
                              contact: contact,
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
                          if (selectedUsers.isNotEmpty) {
                            addMembers();
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

  void addMembers() async {
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    DocumentReference ref =
        FirebaseFirestore.instance.collection("Groups").doc(widget.groupId);
    ref.get().then((value) async {
      if (value.exists) {
        List members = value["participants"];
        for (var s in selectedUsers) {
          ParticipantHelper()
              .queryByUserGroup(s, widget.groupId)
              .then((value2) async {
            if (value2 == null) {
              //insert new admin
              ParticipantModel partModel = ParticipantModel(
                  grpId: widget.groupId.toString(),
                  userId: s,
                  addedByUserId: logged[0]);
              int b = await ParticipantHelper().insert(partModel);
              if (b > 0) {
                print("participant served successfully..%%%%%%%%%%%%%.............");
              }
              if (!members.contains(s)) {
                members.add(s);
                ref.update({"participants": members}).whenComplete(() {
                  print(
                      " %%%%%%%%%%%%%%%% participants updated successfully.................");
                });
              }
            }
          });
        }
      }
      // print("group deosn't exist............");
    }).whenComplete(() {
      setState(() {
        attempt = false;
      });
      Navigator.pop(context);
    });
  }
}
