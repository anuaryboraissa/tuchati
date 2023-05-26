// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import "package:firebase_storage/firebase_storage.dart" as storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Animation/FadeAnimation.dart';
import 'package:tuchati/screens/page/dialogue/dialogueBoxes.dart';
import 'package:tuchati/screens/page/groupDocs.dart';
import 'package:tuchati/services/SQLite/groups/groupHelper.dart';
import 'package:tuchati/services/SQLite/models/msgDetails.dart';
import 'package:tuchati/services/SQLite/models/user.dart';
import 'package:tuchati/services/secure_storage.dart';

import '../../services/SQLite/groups/group.dart';
import '../../services/SQLite/modelHelpers/userHelper.dart';
import '../../services/groups.dart';
import 'addNewMembers.dart';
import 'newAdmins.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo({
    Key? key,
    required this.isAdmin,
    required this.grpId,
  }) : super(key: key);
  final bool isAdmin;
  final String grpId;
  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  late Uint8List list;
  var _iconn;
  File? filee;
  late Box<Uint8List> groupsIcon;
  getDefaultImage() async {
    final ByteData bytes = await rootBundle.load('assets/images/user.png');
    list = bytes.buffer.asUint8List();
    groupsIcon.put("userDefault", list);
  }

  String groupName = "";
  String groupDesc = "";
  List<dynamic> logged = [];
  filterGroup() {
    print("filter group %%%%%%%%%%%%%");
    SecureStorageService().readByKeyData("user").then((value) {
      setState(() {
        logged = value;
      });
    });
    GroupHelper().queryById(int.parse(widget.grpId)).then((value) {
      setState(() {
        groupName = value!.name;
        groupDesc = value.description;
      });
    });
  }

  List<MyUser?> notAdmins = [];

  getNotAdmins() {
    setState(() {
      notAdmins = groupMembers.where((element) {
        bool niAdmin = true;
        for (var admin in groupAdmins) {
          if (element!.firstName == admin!.firstName &&
              element.created == admin.created) {
            niAdmin = false;
            break;
          }
        }

        return niAdmin;
      }).toList();
    });
  }

  List<MyUser?> notMembers = [];
  getNotMembers() {
    // var seen=<MyUser?>{};
    print("get not membersssssss...........");
    UserHelper().queryAll().then((value) {
      setState(() {
        notMembers = value
            .where((element) {
              bool isNotMember = true;
              for (var memb in groupMembers) {
                print(
                    "trying to compare with ${element!.firstName}... and ${memb!.firstName}.. and ${element.phone}.with ${memb.phone}  @@@@@@@@@@@@@");
                if (element.firstName == memb.firstName &&
                    element.phone == memb.phone) {
                  isNotMember = false;
                  print("${element.firstName} if member %%%%%%%");
                  break;
                }
              }

              return isNotMember;
            })
            .toSet()
            .toList();
      });
    });
  }

  Future<void> getGroupIcon() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _iconn = File(file!.path);
      filee = File(file.path);
    });
    Uint8List bytes = filee!.readAsBytesSync();
    //save file to firestora
    groupsIcon.put(widget.grpId, bytes);
    storage.FirebaseStorage.instance
        .ref()
        .child("groupIcons")
        .child("/${widget.grpId}")
        .putFile(filee!)
        .whenComplete(() {
      // print("group Icon Updated successfully............");
    });
  }

  // bool isNumeric(String s) {
  //   // ignore: unnecessary_null_comparison
  //   if (s == null) {
  //     return false;
  //   }
  //   return double.tryParse(s) != null;
  // }

  List<MyUser?> groupAdmins = [];
  List<MyUser?> groupMembers = [];
  getDetails() {
     print("group details group %%%%%%%%%%%%%");
    UserHelper().queryAdmins(int.parse(widget.grpId)).then((value) {
      setState(() {
        groupAdmins = value;
      });
    });
    UserHelper().queryParticipants(int.parse(widget.grpId)).then((value) {
      groupMembers = value;
    });
  }

  late Box<Uint8List> myProfile;
  @override
  void initState() {
    myProfile = Hive.box<Uint8List>("myProfile");

    filterGroup();
    getDetails();
    getNotAdmins();
    groupsIcon = Hive.box<Uint8List>("groups");
    getDefaultImage();
    getNotMembers();
    super.initState();
  }

  bool imeingia = false;
  @override
  Widget build(BuildContext context) {
    if (!imeingia) {
      filterGroup();
      print(
          "now ********************************        group members are $groupMembers");
      setState(() {
        imeingia = true;
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
                  left: 90,
                  top: 50,
                  width: 200,
                  height: 150,
                  child: FadeAnimation(
                      1.5,
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          groupName,
                          style: const TextStyle(
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
                          ? groupsIcon.get(widget.grpId) == null
                              ? MemoryImage(groupsIcon.get("userDefault")!)
                              : MemoryImage(groupsIcon.get(widget.grpId)!)
                          : MemoryImage(filee!.readAsBytesSync()),
                      backgroundColor: Colors.white24,
                      radius: 70,
                    ),
                  ),
                ),
                if (widget.isAdmin)
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
                              title: const Text("Group Name"),
                              subtitle: Text(groupName),
                              trailing: widget.isAdmin
                                  ? IconButton(
                                      icon: Icon(Icons.edit,
                                          color: AppColors.appColor),
                                      onPressed: () async {
                                        await DialogueBox.showInOutDailog(
                                            context: context,
                                            yourWidget: await editDescription(
                                                groupName, "1"),
                                            firstButton: await saveButton("1"));
                                        // print(
                                        //     "edit name.........for group....");
                                      },
                                    )
                                  : const Text("")),
                          const Divider(),
                          ListTile(
                              leading: const Icon(Icons.group),
                              title: const Text("Group Descriptions"),
                              subtitle: Text(groupDesc),
                              trailing: widget.isAdmin
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: AppColors.appColor,
                                      ),
                                      onPressed: () async {
                                        await DialogueBox.showInOutDailog(
                                            context: context,
                                            yourWidget: await editDescription(
                                                groupDesc, "2"),
                                            firstButton: await saveButton("2"));
                                        // print(
                                        //     "edit description.........for group....");
                                      },
                                    )
                                  : const Text("")),
                          const Divider(),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => GroupDocuments(
                                        groupId: widget.grpId,
                                        grpName: groupName,
                                      )));
                            },
                            leading: const Icon(Icons.file_copy),
                            title: const Text("Media,docs,links"),
                            subtitle: const Text("sample images"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined,
                                size: 14, color: AppColors.appColor),
                          ),
                          groupMembers.isNotEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${groupMembers.length}",
                                      style: AppColors.headingStyle,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Participants",
                                      style: AppColors.headingStyle,
                                    ),
                                  ],
                                )
                              : const Text(""),
                          if (groupMembers.isNotEmpty)
                            SizedBox(
                              height: 250,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: groupMembers.length,
                                      itemBuilder: (context, index) {
                                        MyUser? member = groupMembers[index];
                                        print(
                                            "&&&&&&&&&&&& member not admins $notAdmins");
                                        bool exist = false;
                                        for (var adm in groupAdmins) {
                                          if (adm!.firstName ==
                                                  member!.firstName &&
                                              adm.phone == member.phone &&
                                              adm.created == member.created) {
                                            exist = true;
                                          }
                                        }
                                        return ListTile(
                                          leading: Stack(
                                            children: [
                                              Container(
                                                width: 55,
                                                height: 55,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: MemoryImage(
                                                          groupsIcon.get(
                                                              "userDefault")!),
                                                      fit: BoxFit.fill),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          title: logged.isNotEmpty &&
                                                  logged[1] == member!.firstName
                                              ? const Text("You")
                                              : Text(member!.firstName),
                                          subtitle: Text(member.phone),
                                          trailing: TextButton(
                                            child: Text(exist ? "Admin" : ""),
                                            onPressed: () {},
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.isAdmin)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => NewMember(
                                                groupId: widget.grpId,
                                                participants: notMembers,
                                              )))
                                      .then((value) {
                                    setState(() {
                                      filterGroup();
                                      getDetails();
                                      notAdmins = [];
                                      getNotAdmins();
                                      getNotMembers();
                                    });
                                  });
                                },
                                leading: Icon(
                                  Icons.add,
                                  color: AppColors.appColor,
                                ),
                                title: const Text("Add Members"),
                                // subtitle: const Text("sample images"),
                              ),
                            ),
                          if (widget.isAdmin)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => NewAdmins(
                                                groupId: widget.grpId,
                                                participants: groupMembers
                                                    .where((element) {
                                                  bool niAdmin = true;
                                                  groupAdmins
                                                      .forEach((element2) {
                                                    if (element!.firstName ==
                                                            element2!
                                                                .firstName &&
                                                        element.created ==
                                                            element2.created) {
                                                      niAdmin = false;
                                                    }
                                                  });
                                                  return niAdmin;
                                                }).toList(),
                                              )))
                                      .then((value) {
                                    setState(() {
                                      filterGroup();
                                      getDetails();
                                      notAdmins = [];
                                      getNotAdmins();
                                    });
                                  });
                                },
                                leading: Icon(
                                  Icons.add,
                                  color: AppColors.appColor,
                                ),
                                title: const Text("Add Admins"),
                                // subtitle: const Text("sample images"),
                              ),
                            ),
                        ]))
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextEditingController desc = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  Future<Widget> editDescription(previous, which) async {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(which == "1"
              ? "Edit $groupName Name"
              : "Edit $groupName description"),
        ),
        Form(
          key: _formkey,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: TextFormField(
              controller: desc,
              validator: (value) {
                if (value!.isEmpty || value == previous) {
                  return which == "1"
                      ? "please enter Name"
                      : "please enter Desciption";
                }
                return null;
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: previous,
                  hintStyle: TextStyle(color: Colors.grey[400])),
            ),
          ),
        ),
      ],
    );
  }

  Future<Widget> saveButton(which) async {
    return ElevatedButton(
         style: ElevatedButton.styleFrom(backgroundColor: AppColors.appColor),
        onPressed: () async {
          if (_formkey.currentState!.validate()) {
            //save in local
            GroupModel? grp =
                await GroupHelper().queryById(int.parse(widget.grpId));
            if (grp != null) {
             which != "1"? grp.description = desc.text:grp.name = desc.text;
              int i = await GroupHelper().update(grp);
              if (i > 0) {
                print("group updated successfully........");
              }
            }
            filterGroup();

            FirebaseFirestore.instance
                .collection("Groups")
                .doc(widget.grpId)
                .update(which == "1"
                    ? {"name": desc.text}
                    : {"decription": desc.text});
            // ignore: use_build_context_synchronously
            desc.clear();
            Navigator.pop(context);
          }
        },
        child: const Text("Save"));
  }
}
