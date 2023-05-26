// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
// import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:path/path.dart' as path;
import 'package:swipe_to/swipe_to.dart';
import 'package:tuchati/screens/chat_room/received_message.dart';
import 'package:tuchati/screens/chat_room/sent_message.dart';
import 'package:tuchati/screens/page/dialogue/dialogueBoxes.dart';
import 'package:tuchati/screens/page/groupInfo.dart';
import 'package:tuchati/screens/recording/src/widgets/audio_bubble.dart';
import 'package:tuchati/screens/recording/src/widgets/record_button.dart';
import 'package:tuchati/services/SQLite/modelHelpers/userHelper.dart';
import 'package:tuchati/services/SQLite/models/groupMessages.dart';
import 'package:tuchati/services/SQLite/models/user.dart';
import 'package:tuchati/services/fileshare.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/groups.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:tuchati/utils.dart';
import 'package:tuchati/widgets/spacer/spacer_custom.dart';

import '../../../constants/app_colors.dart';
import '../../../device_utils.dart';
import '../../services/SQLite/modelHelpers/dirMsgsHelper.dart';
import '../../services/SQLite/modelHelpers/directsmsdetails.dart';
import '../../services/SQLite/modelHelpers/grpMsgsHelper.dart';
import '../../services/SQLite/models/dirMessages.dart';
import '../../services/SQLite/models/grpDetails.dart';
import '../../services/SQLite/models/msgDetails.dart';
import '../../services/SQLite/updateDetails.dart';
import '../page/progress/progress.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    Key? key,
    this.user,
    this.group,
    required this.name,
    required this.iam,
    required this.fromDetails,
  }) : super(key: key);
  final DirMsgDetails? user;
  final GroupMsgDetails? group;
  final String name;
  final String iam;
  final bool fromDetails;
  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage>
    with SingleTickerProviderStateMixin {
  //
  late AnimationController controller;
  Box<String>? voicePaths;
  // Timer
  String newSender = '';
  updateSender(String id) {
    UserHelper().queryById(id).then((value) {
      if (value != null) {
        setState(() {
          newSender = value.firstName;
        });
      }
    });
  }

  late Box<List<String>> grpLetfs;

  final TextEditingController message = TextEditingController();
  String voiceNoteMsg = "";
  late Timer timer;
  String sender = '';
  String receiver = '';
  bool sent = false;
  Future<List>? data;
  List<MyUser?> groupMemb = [];
  List<MyUser?> groupAdm = [];
  bool initScroll = false;
  bool isOnline = false;
  String lastSeen = "";
  isUserOnline() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.user!.userId)
        .get()
        .then((value) {
      if (value["online_status"]) {
        setState(() {
          isOnline = true;
        });
      } else {
        setState(() {
          isOnline = false;
          lastSeen = value["last_seen"];
        });
      }
    });
  }

  bool stopOnlineCheck = false;

  String senderName = '';
  String myName = "";
  List log = [];
  void loadSms() {
    SecureStorageService().readByKeyData("user").then(
      (value) {
        setState(() {
          log = value;
          sender = value[0];
          senderName = value[1];
          if (widget.user != null) {
            receiver = widget.user!.userId;
          }
          myName = "${value[1]} ${value[2]}";
        });
      },
    );
  }

  List<String> participants = [];

  bool isTyping = false;
  var heightt = 50;
  bool isReplaying = false;
  bool filesend = false;
  var padd = 0;
  bool shoemoji = false;
  final focusNode = FocusNode();
  late ScrollController _scrollcontroller;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    _scrollcontroller.dispose();
  }

  Stream<List> _dataOfferSwitch() async* {
    yield* Stream.fromFuture(
        GrpMsgsHelper().queryByGrp(widget.group!.grpId.toString()));
  }

  clearNormalChat() {
    DirMsgsHelper().queryByFields(widget.user!.userId, sender).then((value) {
      value.forEach((element) {
        DirMsgsHelper().delete(element!.msgId).then((value) {
          if (value > 0) {
            print("message ${element.msg} delete successfully............");
          }
        });
      });
    });
  }

  clearGroupChat() {
    GrpMsgsHelper().queryByGrp(widget.group!.grpId.toString()).then((value) {
      value.forEach((element) {
        GrpMsgsHelper().delete(element!.msgId).then((value) {
          if (value > 0) {
            print("message ${element.msg} delete successfully............");
            // DocumentReference ref = FirebaseFirestore.instance
            //     .collection("Clear")
            //     .doc(widget.group!.grpId.toString());
            // ref.get().then((value) {
            //   DateTime now = DateTime.now();
            //   String formattedDate =
            //       DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
            //   if (value.exists) {
            //     List users = value["users"];
            //     if (users.contains(sender)) {
            //       final json = {sender: formattedDate};
            //       ref.update(json).whenComplete(() {
            //         print("uset clear date updated__________________");
            //       });
            //     } else {
            //       users.add(sender);
            //       final json = {"users": users, sender: formattedDate};
            //       ref.update(json).whenComplete(() {
            //         print("user clear updated successfully____________________");
            //       });
            //     }
            //   } else {
            //     List users = [];
            //     users.add(sender);
            //     final json = {"users": users, sender: formattedDate};
            //     ref.set(json).whenComplete(() {
            //       print("user clear setted successfully____________________");
            //     });
            //   }
            // });
          }
        });
      });
    });
  }

  leftGroup() async {
    Box<List<String>> grpLetfs = Hive.box<List<String>>("lefts");
    List<String>? lefts = grpLetfs.get(sender);
    if (lefts != null) {
      if (!lefts.contains(widget.group!.grpId.toString())) {
        lefts.add(widget.group!.grpId.toString());
        grpLetfs.put(sender, lefts);
      }
    } else {
      List<String> groups = [];
      groups.add(widget.group!.grpId.toString());
      grpLetfs.put(sender, groups);
    }
    clearGroupChat();

    DocumentReference ref = FirebaseFirestore.instance
        .collection("GroupLefts")
        .doc(widget.group!.grpId.toString());
    ref.get().then((value) {
      List users = [];
      if (value.exists) {
        users = value["users"];
        if (!users.contains(sender)) {
          users.add(sender);
          final json = {"users": users};
          ref.set(json).whenComplete(() {
            print("Left group ${widget.group!.name} completed____________");
            Navigator.pop(context);
          });
        }
      } else {
        List users = [];
        users.add(sender);
        final json = {"users": users};
        ref.set(json).whenComplete(() {
          print("Left group ${widget.group!.name} completed____________");
          Navigator.pop(context);
        });
      }
    });
    await Progresshud.mySnackBar(
        context, "you have successfully left ${widget.group!.name}");
  }

  Stream<List<DirectMessage?>> directChats() async* {
    yield* Stream.fromFuture(
        DirMsgsHelper().queryByFields(widget.user!.userId, sender));
  }

  // late Stream<Future<List>> dataa;
  String reply_to_msg = "";
  String msgSender = "";
  String replied_msg = "";
  String repliedFile = "";
  bool isAdmnin = false;
  late Box<Uint8List> groupsIcon;
  // loadGroupMessagesDetails() async {
  //   await FirebaseService().groupMsgsDetails();
  // }

  @override
  void initState() {
    grpLetfs = Hive.box<List<String>>("lefts");
    if (widget.user != null) {
      isUserOnline();
    }
    voicePaths = Hive.box<String>("voice");
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    groupsIcon = Hive.box<Uint8List>("groups");
    loadSms();
    if (widget.user == null) {
      filterGroupDetails();
    }
    // recorder.init();
    super.initState();
    _scrollcontroller = ScrollController();
  }

  void bottomScroll() {
    print("bottom scroll caled^^^^^^^^^^^^^^^");
    final bottomoffset = _scrollcontroller.position.maxScrollExtent;
    _scrollcontroller.animateTo(bottomoffset,
        duration: const Duration(microseconds: 1000), curve: Curves.easeInOut);
  }

  var camera_image;
  Future getCameraImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: double.infinity);
    setState(() {
      myfile = File(photo!.path);
    });
    setState(() {
      fileBytes = myfile!.readAsBytesSync();
      String basename = path.basename(photo!.path);
      final bytes = camera_image.readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
// final mb = kb / 1024;
      fileSize = kb;
      filename = basename;
    });
    // print(
    //     "file send is .....$filesend and...............file bytes .${myfile == null}");
  }

  filterGroupDetails() {
    UserHelper().queryAdmins(widget.group!.grpId).then((value) {
      setState(() {
        groupAdm = value;
      });
    });
    UserHelper().queryParticipants(widget.group!.grpId).then((value) {
      setState(() {
        groupMemb = value;
      });
    });
  }

  int imeingia = 0;
  @override
  Widget build(BuildContext context) {
    if (imeingia < 2) {
      if (widget.user == null) {
        print("total participants $participants...............");
        for (var x in groupAdm) {
          if (x!.id == sender) {
            setState(() {
              imeingia = imeingia + 1;
              isAdmnin = true;
            });
          }
        }
      }
    }
    List<String> menuitems = widget.user == null
        ? ["clear", isAdmnin ? "manage" : "exit"]
        : ["", "clear"];
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          focusNode.canRequestFocus = false;
        });
        return true;
      },
      child: Scaffold(
        body: Container(
          height: DeviceUtils.getScaledHeight(context, 1),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.backChatGroundColor,
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    child: Container(
                      padding: const EdgeInsets.only(top: 38),
                      color: AppColors.appColor,
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: Row(children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        stopOnlineCheck = true;
                                      });
                                      if (widget.fromDetails) {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    icon: const Icon(
                                        Icons.arrow_back_ios_new_outlined,
                                        color: Colors.white)),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: widget.user == null
                                              ? MemoryImage(groupsIcon.get(
                                                          widget.group!.grpId
                                                              .toString()) ==
                                                      null
                                                  ? groupsIcon
                                                      .get("groupDefault")!
                                                  : groupsIcon.get(widget
                                                      .group!.grpId
                                                      .toString())!)
                                              : MemoryImage(groupsIcon
                                                  .get("userDefault")!),
                                          fit: BoxFit.fill),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (groupMemb.isNotEmpty) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => GroupInfo(
                                          isAdmin: isAdmnin,
                                          grpId: widget.group!.grpId.toString(),
                                        ),
                                      ))
                                          .then((value) {
                                        //update chat room
                                        setState(() {
                                          // filterGroupDetails();
                                          groupsIcon =
                                              Hive.box<Uint8List>("groups");
                                        });
                                      });
                                    }

                                    // print("header tapped.....................");
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.58,
                                              height: 18,
                                              child: Text(
                                                widget.user == null
                                                    ? "${widget.group!.name} "
                                                    : "${widget.user!.name}",
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0, left: 8),
                                              child: widget.user == null
                                                  ? SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.58,
                                                      height: 18,
                                                      child: ListView.builder(
                                                        itemCount:
                                                            groupMemb.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          MyUser? member =
                                                              groupMemb[index];

                                                          return Text(
                                                            sender == member!.id
                                                                ? "you,"
                                                                : "${member.firstName},",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12),
                                                          );
                                                        },
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 15,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.58,
                                                      child: Text(
                                                        isOnline
                                                            ? "online"
                                                            : "last seen $lastSeen",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])),
                              widget.group != null &&
                                    grpLetfs.get(sender) != null &&
                                    grpLetfs.get(sender)!.contains(
                                        widget.group!.grpId.toString())?
                                        const Text(""):
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert_rounded,
                                color: Colors.white),
                            onSelected: (value) async {
                              switch (value) {
                                case "exit":
                                  await DialogueBox.showInOutDailog(
                                      context: context,
                                      yourWidget: Text(
                                          "Are you sure you want to left ${widget.name}"),
                                      secondButton: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.appColor),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("no")),
                                      firstButton: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.appColor),
                                          onPressed: () async {
                                            leftGroup();
                                            Navigator.pop(context);
                                          },
                                          child: const Text("yes")));
                                  break;
                                case "clear":
                                  if (widget.user == null) {
                                    //can clear group chat
                                  } else {
                                    clearNormalChat();
                                  }

                                  break;
                              }
                            },
                            itemBuilder: (context) => menuitems
                                .map((e) =>
                                    PopupMenuItem(value: e, child: Text(e)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: DeviceUtils.getScaledHeight(context, 0.87),
                  width: DeviceUtils.getScaledWidth(context, 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: padd.toDouble()),
                          child: StreamBuilder(
                            stream: widget.user == null
                                ? _dataOfferSwitch()
                                : directChats(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  controller: _scrollcontroller,
                                  itemCount: focusNode.canRequestFocus
                                      ? snapshot.data!.length + 1
                                      : snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    if (index == snapshot.data!.length ||
                                        filesend ||
                                        isReplaying) {
                                      return Container(
                                        height: 70,
                                      );
                                    } else {
                                      // print("all attr 2 ${my_sms[2]} ");
                                      // if (index == 1) {
                                      //   bottomScroll();
                                      // }
                                      DateTime now = DateTime.now();
                                      String formattedDate =
                                          DateFormat('yyyy-MM-dd').format(now);
                                      if (widget.user == null) {
                                        GroupMessage? my_sms =
                                            snapshot.data![index];

                                        if (my_sms!.sender != sender) {
                                          if (index ==
                                              snapshot.data!.length - 1) {
                                            print(
                                                "now updating @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@..");
                                            // updateSender(my_sms.sender);
                                            UpdateDetails().updateGroupDetails(
                                                my_sms.msg,
                                                newSender,
                                                my_sms.date,
                                                my_sms.grpId,
                                                0);
                                          }
                                          return SwipeTo(
                                            onRightSwipe: () {
                                              setState(() {
                                                //apaaaaaaaaaaaaaaaaaaaaa
                                                bottomScroll();
                                                updateSender(my_sms.sender);
                                                focusNode.requestFocus();
                                                focusNode.canRequestFocus =
                                                    true;
                                                isReplaying = true;
                                                msgSender = newSender;
                                                reply_to_msg =
                                                    my_sms.msgId.toString();
                                                replied_msg = my_sms.msg;
                                                repliedFile = my_sms.fileName;
                                              });
                                            },
                                            child: my_sms.replied == ""
                                                ? ReceivedMessage(
                                                    whoIam: myName,
                                                    repliedUserName:
                                                        my_sms.repliedMsgSender,
                                                    receivedFile:
                                                        my_sms.fileName,
                                                    sender: my_sms.sender,
                                                    participants: groupMemb,
                                                    child: Text(
                                                      my_sms.msg,
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color: const Color(
                                                            0xff323643),
                                                      ),
                                                    ),
                                                    time: my_sms.date,
                                                    replied_status: false,
                                                    messag: my_sms.msg,
                                                    msgId:
                                                        my_sms.msgId.toString(),
                                                    userNow: 1,
                                                  )
                                                : ReceivedMessage(
                                                    whoIam: myName,
                                                    repliedUserName:
                                                        my_sms.repliedMsgSender,
                                                    repliedId:
                                                        my_sms.repliedMsgId,
                                                    sender: my_sms.sender,
                                                    participants: groupMemb,
                                                    messag: my_sms.msg,
                                                    msgId:
                                                        my_sms.msgId.toString(),
                                                    child: Text(
                                                      my_sms.msg,
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color:
                                                            Color(0xff323643),
                                                      ),
                                                    ),
                                                    time: my_sms.date,
                                                    replied_status: true,
                                                    replied: Column(
                                                      children: [
                                                        Text(
                                                          "${my_sms.replied}",
                                                          style: SafeGoogleFont(
                                                            'SF Pro Text',
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            height: 1.64,
                                                            letterSpacing: 0.5,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    receivedFile:
                                                        my_sms.fileName,
                                                    userNow: 1,
                                                  ),
                                          );
                                        } else {
                                          if (my_sms.replied.isNotEmpty &&
                                              my_sms.replied != "0") {
                                            return SentMessage(
                                              seen: "1",
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4.0,
                                                            right: 5),
                                                    child: Text(
                                                      my_sms.msg,
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.6428571429,
                                                        letterSpacing: 0.5,
                                                        color: const Color(
                                                            0xffffffff),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 5,
                                                            left: 6,
                                                            right: 4),
                                                    child: Text(
                                                        my_sms.date.split(
                                                                    " ")[0] ==
                                                                formattedDate
                                                            ? my_sms.date
                                                                .split(" ")[1]
                                                            : my_sms.date
                                                                .split(" ")[0],
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white70,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.8333333333,
                                                          letterSpacing: 1,
                                                        )),
                                                  ),
                                                ],
                                              ),
                                              sent: sent,
                                              replied: true,
                                              replymsg: my_sms.replied,
                                              msgId: my_sms.msgId.toString(),
                                              messag: my_sms.msg,
                                              sentFile: my_sms.fileName,
                                              repliedId: my_sms.repliedMsgId,
                                              repliedUserName:
                                                  my_sms.repliedMsgSender,
                                              date: my_sms.date,
                                            );
                                          }
                                          return SentMessage(
                                            date: my_sms.date,
                                            seen: "1",
                                            sentFile: my_sms.fileName,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 4.0, left: 4),
                                                  child: Text(
                                                    "${my_sms.msg}",
                                                    style: SafeGoogleFont(
                                                      'SF Pro Text',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.6428571429,
                                                      letterSpacing: 0.5,
                                                      color: const Color(
                                                          0xffffffff),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 6,
                                                            left: 10,
                                                            right: 3),
                                                    child: Text(
                                                        my_sms.date.split(
                                                                    " ")[0] ==
                                                                formattedDate
                                                            ? my_sms.date
                                                                .split(" ")[1]
                                                            : my_sms.date
                                                                .split(" ")[0],
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white70,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.8333333333,
                                                          letterSpacing: 1,
                                                        ))),
                                              ],
                                            ),
                                            replied: false,
                                            sent: sent,
                                            msgId: "${my_sms.msgId}",
                                            messag: my_sms.msg,
                                          );
                                        }
                                        //end group.................
                                      } else {
                                        DirectMessage userMsg =
                                            snapshot.data![index];

                                        if (userMsg.sender ==
                                            widget.user!.userId) {
                                          if (index ==
                                              snapshot.data!.length - 1) {
                                            UpdateDetails().updateUserDetails(
                                                userMsg.msg,
                                                userMsg.time,
                                                userMsg.date,
                                                widget.user!.userId);
                                            // bottomScroll();
                                          }
                                          return SwipeTo(
                                            onRightSwipe: () {
                                              setState(() {
                                                bottomScroll();
                                                focusNode.requestFocus();
                                                focusNode.canRequestFocus =
                                                    true;
                                                isReplaying = true;
                                                reply_to_msg =
                                                    userMsg.msgId.toString();
                                                replied_msg = userMsg.msg;
                                              });
                                            },
                                            child: userMsg.repliedMsgId == "" ||
                                                    userMsg.repliedMsgId == "0"
                                                ? ReceivedMessage(
                                                    receivedFile:
                                                        userMsg.fileName,
                                                    messag: userMsg.msg,
                                                    msgId: userMsg.msgId
                                                        .toString(),
                                                    child: Text(
                                                      "${userMsg.msg}",
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color:
                                                            Color(0xff323643),
                                                      ),
                                                    ),
                                                    time: "${userMsg.time} PM",
                                                    replied_status: false,
                                                    userNow: 0,
                                                  )
                                                : ReceivedMessage(
                                                    repliedId:
                                                        userMsg.repliedMsgId,
                                                    receivedFile:
                                                        userMsg.fileName,
                                                    messag: userMsg.msg,
                                                    msgId: userMsg.msgId
                                                        .toString(),
                                                    child: Text(
                                                      "${userMsg.msg}",
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color:
                                                            Color(0xff323643),
                                                      ),
                                                    ),
                                                    time: "${userMsg.time} PM",
                                                    replied_status: true,
                                                    replied: Text(
                                                      "${userMsg.replied}",
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    userNow: 0,
                                                  ),
                                          );
                                        } else {
                                          if (userMsg.repliedMsgId != "" &&
                                              userMsg.repliedMsgId != "0") {
                                            return SentMessage(
                                              date: userMsg.date,
                                              repliedId: userMsg.repliedMsgId,
                                              sentFile: userMsg.fileName,
                                              child: Column(
                                                children: [
                                                  Text(
                                                    userMsg.msg,
                                                    style: SafeGoogleFont(
                                                      'SF Pro Text',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.6428571429,
                                                      letterSpacing: 0.5,
                                                      color: Color(0xffffffff),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 6, left: 10),
                                                      child: Text(
                                                          userMsg.date.split(
                                                                      " ")[0] ==
                                                                  formattedDate
                                                              ? userMsg.date
                                                                  .split(" ")[1]
                                                              : userMsg.date
                                                                  .split(
                                                                      " ")[0],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.white70,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            height:
                                                                1.8333333333,
                                                            letterSpacing: 1,
                                                          ))),
                                                ],
                                              ),
                                              sent: sent,
                                              replied: true,
                                              replymsg: userMsg.replied,
                                              msgId: userMsg.msgId.toString(),
                                              messag: userMsg.msg,
                                              seen: userMsg.seen,
                                            );
                                          }
                                          return SentMessage(
                                            date: userMsg.date,
                                            seen: userMsg.seen,
                                            sentFile: userMsg.fileName,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4.0, right: 4),
                                                  child: Text(
                                                    "${userMsg.msg}",
                                                    style: SafeGoogleFont(
                                                      'SF Pro Text',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.6428571429,
                                                      letterSpacing: 0.5,
                                                      color: const Color(
                                                          0xffffffff),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 6,
                                                            left: 5,
                                                            right: 3),
                                                    child: Text(
                                                        userMsg.date.split(
                                                                    " ")[0] ==
                                                                formattedDate
                                                            ? userMsg.date
                                                                .split(" ")[1]
                                                            : userMsg.date
                                                                .split(" ")[0],
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          height: 1.8333333333,
                                                          letterSpacing: 1,
                                                        ))),
                                              ],
                                            ),
                                            replied: false,
                                            sent: sent,
                                            msgId: userMsg.msgId.toString(),
                                            messag: userMsg.msg,
                                          );
                                        }
                                      }
                                    }
                                  },
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(13.0),
                                    child: Card(
                                      child: Text(
                                          "Once Start conversation with ${widget.user == null ? widget.group!.name : widget.user!.name} chats will be appeared here"),
                                    ),
                                  ),
                                );
                              } else if (snapshot.connectionState ==
                                      ConnectionState.active ||
                                  snapshot.connectionState ==
                                      ConnectionState.done) {
                                return const Text(
                                    "connection is active can be done any time");
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.appColor,
                                    strokeWidth: 3,
                                  ),
                                ));
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.appColor,
                                    strokeWidth: 3,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      if (isReplaying)
                        Expanded(child: replayContainer(replied_msg)),
                      if (filesend && fileBytes != null)
                        Expanded(child: sendFileContainer(fileBytes!)),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 60,
                              height: message.text != ''
                                  ? message.text.length.toDouble() + 50
                                  : 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.grey[700],
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color(0xffF3F3F3),
                                        blurRadius: 15,
                                        spreadRadius: 1.5),
                                  ]),
                              child: Row(children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          focusNode: focusNode,
                                          onTap: () async {
                                            bottomScroll();
                                            setState(() {
                                              isTyping = true;
                                              shoemoji = false;
                                              focusNode.requestFocus();
                                              focusNode.addListener(() {
                                                if (shoemoji) {
                                                  focusNode.unfocus();
                                                  focusNode.canRequestFocus =
                                                      false;
                                                }
                                              });
                                            });
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              int unique = UniqueKey().hashCode;
                                              focusNode.addListener(() {
                                                if (shoemoji) {
                                                  focusNode.unfocus();
                                                  focusNode.canRequestFocus =
                                                      false;
                                                }
                                              });
                                              isTyping = true;
                                            });
                                          },
                                          controller: message,
                                          style: SafeGoogleFont(
                                            'SF Pro Text',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400,
                                            height: 1.64,
                                            letterSpacing: 0.5,
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      top: 6, left: 20),
                                              prefixIcon: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0,
                                                          left: 5,
                                                          right: 5),
                                                  child: GestureDetector(
                                                    child: IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            shoemoji = true;
                                                            focusNode.unfocus();
                                                            focusNode
                                                                    .canRequestFocus =
                                                                false;
                                                          });
                                                          // print("emojiii");
                                                        },
                                                        icon: const Icon(
                                                            Icons
                                                                .emoji_emotions,
                                                            color: Colors
                                                                .white70)),
                                                  )),
                                              suffixIcon: message.text != '' ||
                                                      isReplaying
                                                  ? IconButton(
                                                      onPressed: () async {
                                                        setState(() {
                                                          bottomScroll();
                                                          focusNode
                                                              .requestFocus();
                                                          filesend = true;
                                                        });

                                                        pickFiles();
                                                      },
                                                      icon: const Icon(
                                                        Icons.file_present,
                                                        color: Colors.white70,
                                                      ))
                                                  : Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                bottomScroll();
                                                                focusNode
                                                                    .requestFocus();
                                                                filesend = true;
                                                              });
                                                              getCameraImage();
                                                              // print("camera");
                                                            },
                                                            icon: const Icon(
                                                              Icons.camera_alt,
                                                              color: Colors
                                                                  .white70,
                                                            )),
                                                        IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                bottomScroll();
                                                                focusNode
                                                                    .requestFocus();
                                                                filesend = true;
                                                              });
                                                              pickFiles();
                                                            },
                                                            icon: const Icon(
                                                              Icons
                                                                  .file_present,
                                                              color: Colors
                                                                  .white70,
                                                            )),
                                                      ],
                                                    ),
                                              hintText: "Send message.....",
                                              hintStyle: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                              border: InputBorder.none),
                                          maxLines: 35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                            widget.group != null &&
                                    grpLetfs.get(sender) != null &&
                                    grpLetfs.get(sender)!.contains(
                                        widget.group!.grpId.toString())
                                ? const Text("already left this group")
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, right: 0, left: 0),
                                    child: (isTyping &&
                                                message.text.isNotEmpty) ||
                                            myfile != null
                                        ? FloatingActionButton(
                                            onPressed: () async {
                                              if (await data != null) {
                                                // print(
                                                //     "data zipoooooooooooo banaaaaaaaaaaaaaaaaaaaa");
                                                bottomScroll();
                                              }
                                              if ((isTyping &&
                                                      message.text != '') ||
                                                  myfile != null) {
                                                if (widget.user == null) {
                                                  sendGroupMessage(
                                                      message.text);
                                                  // print(
                                                  //     "send group message...............");
                                                } else {
                                                  // print(
                                                  //     "send direct message...............");
                                                  sendMessage(message.text);
                                                }
                                                message.clear();
                                                setState(() {
                                                  isReplaying = false;
                                                  filesend = false;
                                                });
                                              } else {
                                                // print("record audio");
                                              }
                                            },
                                            elevation: 10,
                                            child: Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                    color: AppColors.appColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.send,
                                                    color: Colors.white,
                                                  ),
                                                )),
                                          )
                                        : RecordButton(
                                            controller: controller,
                                            receiver: widget.user == null
                                                ? widget.group!.grpId.toString()
                                                : widget.user!.userId,
                                            refresh: () {
                                              // print(
                                              //     "refresh called success...........");
                                              int period = 0;

                                              Timer.periodic(
                                                  const Duration(seconds: 1),
                                                  (timer) {
                                                print(
                                                    "after milliseconds................$period");
                                                setState(() {
                                                  period = period + 1;
                                                  replied_msg = "";
                                                  reply_to_msg = "";
                                                  isReplaying = false;

                                                  if (period == 4) {
                                                    timer.cancel();
                                                  }

                                                  bottomScroll();
                                                });
                                              });
                                            },
                                            repliedMsg: replied_msg,
                                            repliedMsgId: reply_to_msg,
                                            repliedMsgSender:
                                                widget.user == null
                                                    ? msgSender
                                                    : null,
                                          ),
                                  )
                          ],
                        ),
                      ),
                      shoemoji ? emojiPicker() : Container()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget replayContainer(msg) {
    Box<Uint8List> msgFiles = Hive.box<Uint8List>("messagesFiles");
    if (msgSender != "") {
      if (groupMemb.isNotEmpty) {
        for (var pa in groupMemb) {
          // print("compare sender and participants........${pa[3]}");
          if (pa!.id == msgSender) {
            setState(() {
              msgSender = pa.firstName;
            });
          }
        }
      }
    }
    return Container(
      width: 500,
      margin: const EdgeInsets.only(top: 4, left: 4, right: 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3.0, left: 3, bottom: 3),
              child: Container(
                color: Colors.green,
                width: 4,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (msgSender != "")
                      Expanded(
                        child: Text(
                          msgSender,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.appColor),
                        ),
                      ),
                    GestureDetector(
                      onTap: () {
                        //cancel reply
                        setState(() {
                          isReplaying = false;
                          focusNode.unfocus();
                          message.clear();
                        });
                      },
                      child: const Icon(Icons.cancel),
                    )
                  ],
                ),
                if (reply_to_msg != "")
                  if (msgFiles.get(reply_to_msg) != null)
                    repliedFile.contains(".pdf")
                        ? Expanded(
                            child: Container(
                              height: 150,
                              width: 260,
                              child: PDFView(
                                pdfData: msgFiles.get(reply_to_msg),
                                enableSwipe: true,
                                swipeHorizontal: true,
                                autoSpacing: false,
                                pageFling: false,
                              ),
                            ),
                          )
                        : Expanded(
                            child: Image.memory(
                              msgFiles.get(reply_to_msg)!,
                              height: 150,
                              width: 260,
                              fit: BoxFit.cover,
                            ),
                          ),
                if (voicePaths!.get(reply_to_msg) != null)
                  AudioBubble(
                    filepath: voicePaths!.get(reply_to_msg)!,
                  ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  "$msg",
                  style: const TextStyle(color: Colors.blue),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget sendFileContainer(Uint8List file) {
    setState(() {
      focusNode.requestFocus();
      focusNode.canRequestFocus = true;
    });
    if (extensions == "pdf") {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        height: 200,
        width: MediaQuery.of(context).size.width * 0.90,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                //cancel reply
                setState(() {
                  filesend = false;
                  focusNode.unfocus();
                  message.clear();
                });
              },
              child: const Icon(Icons.cancel),
            ),
            PDFView(
              pdfData: file,
              enableSwipe: false,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: false,
            ),
          ],
        ),
      );
    }
    return Container(
        width: 500,
        height: 500,
        margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          image: DecorationImage(image: MemoryImage(file)),
          color: Colors.grey.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                //cancel reply
                setState(() {
                  filesend = false;
                  focusNode.unfocus();
                  message.clear();
                });
              },
              child: const Icon(Icons.cancel),
            )
          ],
        ));
  }

  Widget emojiPicker() {
    return SizedBox(
      height: 250,
      width: MediaQuery.of(context).size.width,
      child: EmojiPicker(
        textEditingController: message,
        onBackspacePressed: () {},
        onEmojiSelected: (emoji, category) {
          setState(() {
            shoemoji = false;
            focusNode.requestFocus();
          });
          // print(emoji);
        },
      ),
    );
  }

  void sendMessage(messag) async {

    // print(message.text);
    String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    while (await FirebaseService().checkIfMsgExist(msgId)) {
      // print("msg existssssssssssss ipo ");
      msgId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    String grpTest = UniqueKey().hashCode.toString();
    print(grpTest);
    String messageReplied = replied_msg;
    String repliedMsgId = reply_to_msg;
    String seen = "0";
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
    var nowDate = format.format(DateTime.now());
    var now = DateFormat.Hm().format(DateTime.now());

    List attributes = [
      msgId,
      messag,
      sender,
      receiver,
      messageReplied,
      seen,
      nowDate,
      now,
    ];
    if (myfile != null && fileBytes != null) {
      Box<Uint8List> msgFiles = Hive.box<Uint8List>("messagesFiles");
      msgFiles.put(msgId, fileBytes!);

      attributes.add(filename);
      attributes.add(fileSize.toString());
    } else {
      attributes.add("0");
      attributes.add("0");
    }
    attributes.add(repliedMsgId);
    List msgs = [];

    msgs.add(attributes);
    DirectMessage directMsg = DirectMessage(
        msgId: int.parse(attributes[0]),
        msg: attributes[1],
        sender: attributes[2],
        receiver: attributes[3],
        replied: attributes[4],
        repliedMsgId: attributes[10],
        seen: attributes[5],
        time: now,
        date: nowDate,
        fileName: attributes[8],
        msgFile: "0",
        fileSize: attributes[9]);
    int result = await DirMsgsHelper().insert(directMsg);
    if (result > 0) {
      print("data inserted successfully..........");
      bottomScroll();
      DirectMessage? result2 =
          await DirMsgsHelper().queryById(int.parse(msgId));
      if (result2 != null) {
        UpdateDetails().updateUserDetails(
            result2.msg, result2.time, result2.date, widget.user!.userId);
        print(
            "data inserted is ${result2.msg}...with id ${result2.msgId}.......");
        setState(() {
          bottomScroll();
          imeingia = 0;
          isReplaying = false;
          reply_to_msg = "";
          replied_msg = "";
          filesend = false;
          // myfile = null;
          fileSize = 0;
          filename = "";
          focusNode.canRequestFocus = true;
        });
      }
    }

    attributes.insert(8, "0");
    attributes.insert(9, "0");
    if (myfile != null && fileBytes != null) {
      File? file2 = myfile;
      Uint8List? bytesZake = fileBytes;
      setState(() {
        myfile = null;
        fileBytes = null;
      });
      FirebaseService()
          .sendFiletofirebase(msgId, file2!, attributes, context)
          .then((value) {});
    } else {
      // await FirebaseService().usersSentMsgsToMe();
      await FirebaseService().sendMessage(attributes);
      isUserOnline();
    }
  }

  File? myfile;
  Uint8List? fileBytes;
  String filename = "";
  int fileSize = 0;
  String extensions = '';
  void pickFiles() async {
    PlatformFile? file = await FileShare().uploadFile();
    setState(() {
      myfile = File(file!.path.toString());
      fileBytes = myfile!.readAsBytesSync();
      filename = file.name;
      fileSize = file.size;
      extensions = file.extension!;
      focusNode.requestFocus();
      focusNode.canRequestFocus = true;
      if (file.extension == "pdf") {}
      // print("file btes setted........");
    });
  }

  void checkSeen(mysm) async {
    bool sents = await SecureStorageService().containsKey(mysm);
    setState(() {
      sent = sents;
    });
  }

  void sendGroupMessage(String msg) async {
    String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    while (await FirebaseService().checkIfMsgIdExist(msgId)) {
      msgId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    String mysms = msg;

    DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
    var nowDate = format.format(DateTime.now());
    String groupId = widget.group!.grpId.toString();
    List seen = [];
    List userMsg = [];
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");

    List attributes = [
      msgId,
      mysms,
      sender,
      replied_msg,
      nowDate,
      groupId,
      "0",
      seen
    ];
    if (myfile != null && fileBytes != null) {
      Box<Uint8List> msgFiles = Hive.box<Uint8List>("messagesFiles");
      msgFiles.put(msgId, fileBytes!);

      attributes.add("0");
      attributes.add(filename);
      attributes.add(fileSize.toString());
    } else {
      attributes.add("0");
      attributes.add("0");
      attributes.add("0");
    }
    attributes.add(reply_to_msg);
    attributes.add(msgSender);

    attributes.removeAt(8);
    GroupMessage grpMsg = GroupMessage(
        msgId: int.parse(attributes[0]),
        msg: attributes[1],
        sender: attributes[2],
        grpId: groupId,
        replied: replied_msg,
        repliedMsgId: reply_to_msg,
        date: nowDate,
        fileName: attributes[8],
        msgFile: "0",
        fileSize: attributes[9],
        repliedMsgSender: msgSender);
    int result = await GrpMsgsHelper().insert(grpMsg);
    if (result > 0) {
      bottomScroll();
      print("grp msg inserted successfully..........");
      UpdateDetails().updateGroupDetails(
          attributes[1], "you", nowDate, widget.group!.grpId.toString(), 0);
      setState(() {
        bottomScroll();
        imeingia = 0;
        isReplaying = false;
        reply_to_msg = "";
        replied_msg = "";
        filesend = false;
        fileSize = 0;
        filename = "";
        focusNode.canRequestFocus = true;
      });
    }
    File? myfile2 = myfile;

    setState(() {
      filesend = false;
      myfile = null;
      fileBytes = null;
    });
    if (replied_msg != "" || isReplaying) {
      setState(() {
        imeingia = 1;
        isReplaying = false;
        reply_to_msg = "";
        replied_msg = "";
        filesend = false;
        myfile = null;
        fileBytes = null;
        fileSize = 0;
        filename = "";
        focusNode.canRequestFocus = true;
      });
    }
    // loadGrpMsgs();

    attributes.insert(8, "0");
    // await FirebaseService().groupMsgsDetails();
    await GroupService().saveGrpMessages(attributes, myfile2);
  }
}

class DummyWaveWithPlayIcon extends StatelessWidget {
  const DummyWaveWithPlayIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleoSY (0:592)
          width: 3,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglejqz (0:578)
          width: 3,
          height: 14,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangle5ex (0:581)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleRD2 (0:585)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        //     ],
        //   ),
        // ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectanglexye (0:590)
          width: 3,
          height: 26,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        const SizedBox(
          width: 2,
        ),

        Container(
          // rectangleSP2 (0:587)
          width: 3,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleyNx (0:582)
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        Container(
          // rectangleJg8 (0:579)
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleEpg (0:593)
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectanglez3A (0:586)
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangle8QG (0:589)
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleHHA (0:584)
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangle2Ve (0:598)
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        SizedBox(
          width: 2,
        ),
        Container(
          // rectanglenUp (0:591)
          width: 3,
          height: 26,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleGPz (0:588)
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleoep (0:583)
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        SizedBox(
          width: 2,
        ),
        Container(
          // rectangle9Tn (0:580)
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleHZz (0:594)
          width: 3,
          height: 12,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleRw6 (0:595)
          width: 3,
          height: 10,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectanglea3J (0:596)
          width: 3,
          height: 8,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          // rectangleifJ (0:597)
          width: 3,
          height: 6,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
          ),
        ),

        CustomWidthSpacer(
          size: 0.05,
        ),

        Text(
          '01:3',
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.2575,
            letterSpacing: 1,
            color: Color(0xffffffff),
          ),
        ),

        CustomWidthSpacer(
          size: 0.01,
        ),

        Image.asset(
          "assets/images/play-icon.png",
          width: 25,
          height: 25,
        )
      ],
    );
  }
}

class DateDevider extends StatelessWidget {
  const DateDevider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: 100, // OK
        height: 35, // OK
        decoration: BoxDecoration(
          color: Color(0xffF2F3F6),
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: Center(
            child: Text(
          'Today',
          style: SafeGoogleFont(
            'SF Pro Text',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.193359375,
            letterSpacing: 1,
            color: Color(0xff77838f),
          ),
        )),
      ),
    );
  }
}

// 