// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Animation/FadeAnimation.dart';
import 'package:tuchati/screens/chat_room/chat_room.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/groups.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class GroupDetails extends StatefulWidget {
  const GroupDetails({
    Key? key,
    required this.members,
  }) : super(key: key);
  final List members;
  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController groupName = TextEditingController();
  final TextEditingController groupDescription = TextEditingController();

  // ignore: prefer_typing_uninitialized_variables
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
    final ByteData bytes = await rootBundle.load('assets/images/group.png');
    list = bytes.buffer.asUint8List();
    groupsIcon.put("groupDefault", list);
  }

//timer
  Timer? timer;
  loadGroupDetails() {
    timer = Timer(const Duration(seconds: 10), () async {
      await GroupService().filterMyGroups();
      await FirebaseService().groupMsgsDetails();
    });
  }

 

  late Box<Uint8List> groupsIcon;
  @override
  void initState() {
    groupsIcon = Hive.box<Uint8List>("groups");
    getDefaultImage();

    super.initState();
  }

  bool attempt = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 260,
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
                          "Group details",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
                Positioned(
                  top: 110,
                  left: 100,
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: AppColors.appColor,
                    child: CircleAvatar(
                      backgroundImage: filee == null
                          ? MemoryImage(groupsIcon.get("groupDefault")!)
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
                        Icons.camera_alt_outlined,
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
                myForm(),
                Container(
                    margin: const EdgeInsets.only(top: 160), child: submit())
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget submit() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FadeAnimation(
          2,
          GestureDetector(
            onTap: () async {
              if (formkey.currentState!.validate()) {
                setState(() {
                  attempt = true;
                });

                createGroup();
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
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          )),
    );
  }

  Widget myForm() {
    return Form(
      key: formkey,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 10),
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter group name ";
                }
                return null;
              },
              controller: groupName,
              style: const TextStyle(color: Colors.black, fontSize: 14.5),
              decoration: InputDecoration(
                  prefixIconConstraints: const BoxConstraints(minWidth: 45),
                  prefixIcon: Icon(
                    Icons.people,
                    color: AppColors.appColor,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  hintText: 'Enter Group Name',
                  hintStyle:
                      TextStyle(color: AppColors.primaryColor, fontSize: 14.5),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)
                          .copyWith(bottomRight: const Radius.circular(0)),
                      borderSide: BorderSide(color: AppColors.appColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)
                          .copyWith(bottomRight: const Radius.circular(0)),
                      borderSide: const BorderSide(color: Colors.green))),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 10),
            child: TextFormField(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter group Description ";
                }
                return null;
              },
              controller: groupDescription,
              maxLines: 5,
              style: const TextStyle(color: Colors.black, fontSize: 14.5),
              decoration: InputDecoration(
                  prefixIconConstraints: const BoxConstraints(minWidth: 45),
                  prefixIcon: Icon(
                    Icons.description_outlined,
                    color: AppColors.appColor,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  hintText: 'Enter Group Description',
                  hintStyle:
                      TextStyle(color: AppColors.primaryColor, fontSize: 14.5),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)
                          .copyWith(bottomRight: const Radius.circular(0)),
                      borderSide: BorderSide(color: AppColors.appColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100)
                          .copyWith(bottomRight: const Radius.circular(0)),
                      borderSide: const BorderSide(color: Colors.green))),
            ),
          ),
        ],
      ),
    );
  }

  void createGroup() async {
    String groupId = UniqueKey().hashCode.toString();

    String groupNamee = groupName.text;
    String groupDesc = groupDescription.text;
    File icon = _iconn;
    List participants = widget.members;

    List admins = [];
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    admins.add(logged[0]);
    if (!participants.contains(logged[0])) {
      participants.add(logged[0]);
    }
    bool result = await GroupService().createGroup(
        groupId, groupNamee, groupDesc, participants, admins, icon);
    if (result) {
      setState(() {
        groupName.text = "";
        groupDescription.text = "";
        _iconn = null;
      });
      List loggedGroup = [
        groupId,
        groupNamee,
        groupDesc,
        admins,
        participants,
        icon
      ];

      setState(() {
        attempt = false;
      });
   
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) =>
            ChatRoomPage(user: loggedGroup, name: groupNamee, iam: logged[0]),
      ))
          .then((value) {
        print("loading details group now................");
        loadGroupDetails();
        print("loading details group now completeted................");
      });
         loadGroupDetails();
      print("group successfully created..........");
    } else {
      print("something went wrong.....");
    }

    //call timer
  }
}
