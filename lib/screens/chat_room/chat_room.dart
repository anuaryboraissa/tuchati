// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
// / import 'package:emoji_picker/emoji_picker.dart';
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
import 'package:tuchati/screens/page/groupInfo.dart';
import 'package:tuchati/screens/recording/src/widgets/audio_bubble.dart';
import 'package:tuchati/screens/recording/src/widgets/record_button.dart';
import 'package:tuchati/services/fileshare.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/groups.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:tuchati/utils.dart';
import 'package:tuchati/widgets/spacer/spacer_custom.dart';

import '../../../constants/app_colors.dart';
import '../../../device_utils.dart';

// class ChatMessage {
//   String messageContent;
//   String messageType;
//   ChatMessage({required this.messageContent, required this.messageType});
// }

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    Key? key,
    required this.user,
    required this.name,
    required this.iam,
  }) : super(key: key);
  final List<dynamic> user;
  final String name;
  final String iam;
  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage>
    with SingleTickerProviderStateMixin {
  //
  late AnimationController controller;
  Box<String>? voicePaths;
  // Timer

////////////////////////////////////////////////////////////////

  final TextEditingController message = TextEditingController();
  String voiceNoteMsg = "";
  late Timer timer;
  String sender = '';
  String receiver = '';
  bool sent = false;
  Future<List>? data;
  List groupMemb = [];
  List groupAdm = [];
  bool initScroll = false;

  bool isNumeric(String s) {
    // ignore: unnecessary_null_comparison
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  String senderName = '';
  void loadSms() async {
    SecureStorageService().readByKeyData("user").then(
      (value) {
        setState(() {
          sender = value[0];
          senderName = value[1];
          receiver = widget.user[0];
        });
      },
    );
    timer = Timer(
      const Duration(seconds: 5),
      () {},
    );
  }

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
    if (isNumeric(widget.user[0])) {
      data =
          SecureStorageService().readGrpMsgData("grpMessages", widget.user[0]);
      yield* Stream.fromFuture(data!);
    } else {
      data = SecureStorageService()
          .readMsgData("messages", widget.iam, widget.user[0]);
      yield* Stream.fromFuture(data!);
    }
  }

  late Stream<Future<List>> dataa;
  String reply_to_msg = "";
  String msgSender = "";
  String replied_msg = "";
  String repliedFile = "";
  bool isAdmnin = false;
  late Box<Uint8List> groupsIcon;
  @override
  void initState() {
    voicePaths = Hive.box<String>("voice");
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    groupsIcon = Hive.box<Uint8List>("groups");
    loadSms();
    // recorder.init();
    super.initState();
    _scrollcontroller = ScrollController();
  }

  void bottomScroll() {
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

  int imeingia = 0;
  @override
  Widget build(BuildContext context) {
    //heyy

    // print("yeah is focus node ${focusNode.hasFocus}....");
    if (imeingia < 2) {
      GroupService().getGroupparticipants(widget.user[0]).then(
        (value) {
          setState(() {
            groupMemb = value;
          });
        },
      );
      GroupService().getGroupAdmins(widget.user[0]).then(
        (value) {
          groupAdm = value;
        },
      );
      setState(() {
        if (isNumeric(widget.user[0])) {
          data = SecureStorageService()
              .readGrpMsgData("grpMessages", widget.user[0]);
        } else {
          data = SecureStorageService()
              .readMsgData("messages", widget.iam, widget.user[0]);
        }
        imeingia = imeingia + 1;
      });
    }

    for (var x in groupAdm) {
      if (x[0] == senderName) {
        setState(() {
          // print("yeah is admin hereeeeeeeeeeeeeeeee.........");
          isAdmnin = true;
        });
      }
    }

    List<String> menuitems = isNumeric(widget.user[0])
        ? ["clear", isAdmnin ? "edit" : "exit", "achieve"]
        : ["achieve", "clear"];
    // print("file send now....$filesend file bytes ${fileBytes == null}");
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
                                      Navigator.pop(context);
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
                                          image: isNumeric(widget.user[0])
                                              ? MemoryImage(groupsIcon.get(
                                                          "${widget.user[0]}") ==
                                                      null
                                                  ? groupsIcon
                                                      .get("groupDefault")!
                                                  : groupsIcon.get(
                                                      "${widget.user[0]}")!)
                                              : MemoryImage(groupsIcon
                                                  .get("userDefault")!),
                                          fit: BoxFit.fill),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (isNumeric(widget.user[0])) {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => GroupInfo(
                                          user: widget.user,
                                          groupMembers: groupMemb,
                                          gropAdmins: groupAdm,
                                        ),
                                      ));
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
                                                isNumeric(widget.user[0])
                                                    ? "${widget.user[1]} "
                                                    : "${widget.user[1]} ${widget.user[2]}",
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0, left: 8),
                                              child: isNumeric(widget.user[0])
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
                                                          List member =
                                                              groupMemb[index];
                                                          return Text(
                                                            sender == member[3]
                                                                ? "you,"
                                                                : "${member[0]} ${member[1]},",
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
                                                      child: const Text(
                                                        "Last seen 08:00 AM",
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
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert_rounded,
                                color: Colors.white),
                            onSelected: (value) {
                              switch (value) {
                                case "achieve":
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
                            stream: _dataOfferSwitch(),
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
                                      List my_sms = snapshot.data![index];
                                      // print("all attr 2 ${my_sms[2]} ");
                                      if (isNumeric(widget.user[0])) {
                                        if (my_sms[2] != sender) {
                                          if (my_sms[8]
                                              .toString()
                                              .contains(".m4a")) {
                                                   return AudioBubble(
                                                filepath: voicePaths!
                                                    .get(my_sms[0])!, sent: false,);
                                              }
                                          return SwipeTo(
                                            onRightSwipe: () {
                                              setState(() {
                                                //apaaaaaaaaaaaaaaaaaaaaa
                                                bottomScroll();
                                                focusNode.requestFocus();
                                                focusNode.canRequestFocus =
                                                    true;
                                                isReplaying = true;
                                                msgSender = my_sms[2];
                                                reply_to_msg = my_sms[0];
                                                replied_msg = my_sms[1];
                                                repliedFile = my_sms[8];
                                              });
                                            },
                                            child: my_sms[10] == ""
                                                ? ReceivedMessage(
                                                    repliedUserName: my_sms[11],
                                                    receivedFile: my_sms[8],
                                                    sender: my_sms[2],
                                                    participants: groupMemb,
                                                    child: Text(
                                                      "${my_sms[1]}",
                                                      style: SafeGoogleFont(
                                                        'SF Pro Text',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.64,
                                                        letterSpacing: 0.5,
                                                        color:
                                                            const Color(0xff323643),
                                                      ),
                                                    ),
                                                    time: my_sms[4],
                                                    replied_status: false,
                                                    messag: my_sms[1],
                                                    msgId: my_sms[0],
                                                    userNow: 1,
                                                  )
                                                : ReceivedMessage(
                                                    repliedUserName: my_sms[11],
                                                    repliedId: my_sms[10],
                                                    sender: my_sms[2],
                                                    participants: groupMemb,
                                                    messag: my_sms[1],
                                                    msgId: my_sms[0],
                                                    child: Text(
                                                      my_sms[1],
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
                                                    time: my_sms[4],
                                                    replied_status: true,
                                                    replied: Column(
                                                      children: [
                                                        Text(
                                                          "${my_sms[3]}",
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
                                                    receivedFile: my_sms[8],
                                                    userNow: 1,
                                                  ),
                                          );
                                        } else {
                                          if (my_sms[8]
                                              .toString()
                                              .contains(".m4a")) {
                                            return AudioBubble(
                                                filepath: voicePaths!
                                                    .get(my_sms[0])!, sent: true,);
                                          } else {
                                            if (my_sms[10].isNotEmpty &&
                                                my_sms[10] != "0") {
                                              print(
                                                  "replied user name for ${my_sms[1]} is ${my_sms[11]}");
                                              return SentMessage(
                                                child: Text(
                                                  my_sms[1],
                                                  style: SafeGoogleFont(
                                                    'SF Pro Text',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.6428571429,
                                                    letterSpacing: 0.5,
                                                    color:
                                                        const Color(0xffffffff),
                                                  ),
                                                ),
                                                sent: sent,
                                                replied: true,
                                                replymsg: my_sms[3],
                                                msgId: my_sms[0],
                                                messag: my_sms[1],
                                                sentFile: my_sms[8],
                                                repliedId: my_sms[10],
                                                repliedUserName: my_sms[11],
                                              );
                                            }
                                            return SentMessage(
                                              sentFile: my_sms[8],
                                              child: Text(
                                                "${my_sms[1]}",
                                                style: SafeGoogleFont(
                                                  'SF Pro Text',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.6428571429,
                                                  letterSpacing: 0.5,
                                                  color:
                                                      const Color(0xffffffff),
                                                ),
                                              ),
                                              replied: false,
                                              sent: sent,
                                              msgId: "${my_sms[0]}",
                                              messag: my_sms[1],
                                            );
                                          }
                                        }
                                        //end group.................
                                      } else {
                                        if (my_sms[2] == widget.user[0]) {
                                              if (my_sms[8]
                                              .toString()
                                              .contains(".m4a")) {
                                                   return AudioBubble(
                                                filepath: voicePaths!
                                                    .get(my_sms[0])!, sent: false,);
                                              }
                                          return SwipeTo(
                                            onRightSwipe: () {
                                              setState(() {
                                                bottomScroll();
                                                focusNode.requestFocus();
                                                focusNode.canRequestFocus =
                                                    true;
                                                isReplaying = true;
                                                reply_to_msg = my_sms[0];
                                                replied_msg = my_sms[1];
                                              });
                                            },
                                            child: my_sms[10] == "" ||
                                                    my_sms[10] == "0"
                                                ? ReceivedMessage(
                                                    receivedFile: my_sms[8],
                                                    messag: my_sms[1],
                                                    msgId: my_sms[0],
                                                    child: Text(
                                                      "${my_sms[1]}",
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
                                                    time: "${my_sms[7]} PM",
                                                    replied_status: false,
                                                    userNow: 0,
                                                  )
                                                : ReceivedMessage(
                                                    repliedId: my_sms[10],
                                                    receivedFile: my_sms[8],
                                                    messag: my_sms[1],
                                                    msgId: my_sms[0],
                                                    child: Text(
                                                      "${my_sms[1]}",
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
                                                    time: "${my_sms[7]} PM",
                                                    replied_status: true,
                                                    replied: Column(
                                                      children: [
                                                        Text(
                                                          "${my_sms[4]}",
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
                                                    userNow: 0,
                                                  ),
                                          );
                                        } else {
                                          if (my_sms[8]
                                              .toString()
                                              .contains(".m4a")) {
                                            return AudioBubble(
                                                filepath: voicePaths!
                                                            .get(my_sms[0]) ==
                                                        null
                                                    ? ""
                                                    : voicePaths!
                                                        .get(my_sms[0])!, sent: true,);
                                          } else {
                                            if (my_sms[10] != "" &&
                                                my_sms[10] != "0") {
                                              return SentMessage(
                                                repliedId: my_sms[10],
                                                sentFile: my_sms[8],
                                                child: Text(
                                                  "${my_sms[1]}",
                                                  style: SafeGoogleFont(
                                                    'SF Pro Text',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.6428571429,
                                                    letterSpacing: 0.5,
                                                    color: Color(0xffffffff),
                                                  ),
                                                ),
                                                sent: sent,
                                                replied: true,
                                                replymsg: my_sms[4],
                                                msgId: '${my_sms[0]}',
                                                messag: my_sms[1],
                                              );
                                            }
                                            return SentMessage(
                                              sentFile: my_sms[8],
                                              child: Text(
                                                "${my_sms[1]}",
                                                style: SafeGoogleFont(
                                                  'SF Pro Text',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.6428571429,
                                                  letterSpacing: 0.5,
                                                  color:
                                                      const Color(0xffffffff),
                                                ),
                                              ),
                                              replied: false,
                                              sent: sent,
                                              msgId: '${my_sms[0]}',
                                              messag: my_sms[1],
                                            );
                                          }
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
                                          "Once Start conversation with ${widget.user[1]} chats will be appeared here"),
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
                                return const Center(
                                    child: Text(
                                        "waiting for connection............"));
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
                                  boxShadow: [
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
                                            if (await data != null) {
                                              bottomScroll();
                                            }
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
                                              // print("changed $unique");

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
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10, right: 0, left: 0),
                              child: (isTyping && message.text.isNotEmpty) ||
                                      myfile != null
                                  ? FloatingActionButton(
                                      onPressed: () async {
                                        if (await data != null) {
                                          // print(
                                          //     "data zipoooooooooooo banaaaaaaaaaaaaaaaaaaaa");
                                          bottomScroll();
                                        }
                                        if ((isTyping && message.text != '') ||
                                            myfile != null) {
                                          if (isNumeric(widget.user[0])) {
                                            sendGroupMessage(message.text);
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
                                          print("record audio");
                                        }
                                      },
                                      elevation: 10,
                                      child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: AppColors.appColor,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: const Center(
                                            child: Icon(
                                              Icons.send,
                                              color: Colors.white,
                                            ),
                                          )),
                                    )
                                  : RecordButton(
                                      controller: controller,
                                      receiver: widget.user[0],
                                      refresh: () {
                                        print(
                                            "refresh called success...........");
                                        setState(() {
                                          if (isNumeric(widget.user[0])) {
                                            data = SecureStorageService()
                                                .readGrpMsgData("grpMessages",
                                                    widget.user[0]);
                                          } else {
                                            data = SecureStorageService()
                                                .readMsgData("messages",
                                                    widget.iam, widget.user[0]);
                                          }

                                          bottomScroll();
                                        });
                                      },
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
          if (pa[3] == msgSender) {
            setState(() {
              msgSender = "${pa[0]} ${pa[1]}";
            });
          }
        }
      }
    }
    return Container(
      width: 500,
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8, bottom: 8),
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
                SizedBox(
                  height: 8,
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
          print(emoji);
        },
      ),
    );
  }

  void sendMessage(messag) async {
    print(message.text);
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
    List localAttr = attributes;
    print("apaaaaaaaaaaaaaaaaa attributes $attributes");
    setState(() {
      imeingia = 0;
      isReplaying = false;
      reply_to_msg = "";
      replied_msg = "";
      filesend = false;
      // myfile = null;

      fileSize = 0;
      filename = "";
      focusNode.canRequestFocus = false;
    });
    print("apaaaaaaaaaaaaaaaaa aftere state   attributes $attributes");
    // sends!.put(msgId, attributes);
    List msgs = [];

    List messgs = await SecureStorageService().readAllMsgData("messages");
    if (messgs.isNotEmpty) {
      for (var x = 0; x < messgs.length; x++) {
        msgs.add(messgs[x]);
      }

      msgs.add(attributes);

      Message mysms = Message("messages", msgs);
      await SecureStorageService().writeMsgData(mysms);
      setState(() {
        data = SecureStorageService().readMsgData("messages", sender, receiver);
      });
    } else {
      msgs.add(attributes);

      Message mysms = Message("messages", msgs);
      await SecureStorageService().writeMsgData(mysms);
      setState(() {
        data = SecureStorageService().readMsgData("messages", sender, receiver);
      });
    }
    attributes.insert(8, "0");
    attributes.insert(9, "0");
    if (myfile != null && fileBytes != null) {
      print(
          "now going to send file to firebase...........,,,,,,,,,,sssssssssssssshhhhhhhhhhssssssssssssss..");
      // ignore: use_build_context_synchronously
      await FirebaseService()
          .sendFiletofirebase(msgId, myfile!, attributes, context);
      setState(() {
        myfile = null;
        fileBytes = null;
      });
    } else {
      print(
          "now going to send normal text to firebase...........,,sssssssssssssshhhhhhhhhhssssssssssssss...");

      await FirebaseService().sendMessage(attributes);
    }

    setState(() {
      data = SecureStorageService()
          .readMsgData("messages", widget.iam, widget.user[0]);
    });
    setState(() {
      bottomScroll();
    });
    // if (reply_to_msg != "" || isReplaying) {
    //   print("return defaults");
    //   setState(() {
    //     imeingia = 0;
    //     isReplaying = false;
    //     reply_to_msg = "";
    //     replied_msg = "";
    //     filesend = false;
    //     myfile = null;
    //     fileBytes = null;
    //     fileSize = 0;
    //     filename = "";
    //     focusNode.canRequestFocus = false;
    //   });
    // }
    // loadUsersMsgs();
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
      print("file btes setted........");
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
    String groupId = widget.user[0];
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

    List grpMsgs = await SecureStorageService().readModalData("grpMessages");
    attributes.removeAt(8);
    grpMsgs.add(attributes);
    Modal modal = Modal("grpMessages", grpMsgs);
    await SecureStorageService().writeModalData(modal);
    File? myfile2 = myfile;

    setState(() {
      filesend = false;
      myfile = null;
      fileBytes = null;
    });
    setState(() {
      data =
          SecureStorageService().readGrpMsgData("grpMessages", widget.user[0]);
    });
    setState(() {
      bottomScroll();
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
        focusNode.canRequestFocus = false;
      });
    }
    // loadGrpMsgs();

    attributes.insert(8, "0");
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