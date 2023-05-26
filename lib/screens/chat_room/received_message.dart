// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hive/hive.dart';
import 'package:tuchati/screens/chat_room/widgets/chat_bubble.dart';
import 'package:tuchati/services/SQLite/modelHelpers/userHelper.dart';
import 'package:tuchati/services/SQLite/models/user.dart';

import '../../../constants/app_colors.dart';
import '../../../device_utils.dart';
import '../../../widgets/spacer/spacer_custom.dart';
import '../../services/SQLite/modelHelpers/dirMsgsHelper.dart';
import '../../services/SQLite/models/dirMessages.dart';
import '../../services/secure_storage.dart';
import '../recording/src/widgets/audio_bubble.dart';

class ReceivedMessage extends StatefulWidget {
  final Widget child;
  final Widget? replied;
  final List? participants;
  final int userNow;
  String? sender;
  final String? whoIam;
  final bool replied_status;
  final String time;
  final String messag;
  final String? repliedUserName;
  final String msgId;
  final String receivedFile;
  final String? repliedId;
  ReceivedMessage({
    Key? key,
    required this.child,
    this.replied,
    this.participants,
    required this.userNow,
    this.sender,
    this.whoIam,
    required this.replied_status,
    required this.time,
    required this.messag,
    this.repliedUserName,
    required this.msgId,
    required this.receivedFile,
    this.repliedId,
  }) : super(key: key);

  @override
  State<ReceivedMessage> createState() => _ReceivedMessageState();
}

class _ReceivedMessageState extends State<ReceivedMessage> {
  updateSeen(String msgId) async {
    if (widget.userNow == 1) {
      //group
      

print("updating group seen now ####################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
      List<dynamic> logged = await SecureStorageService().readByKeyData("user");
      String whoSee = logged[0];
      DocumentReference refs =
          FirebaseFirestore.instance.collection("GroupMessages").doc(msgId);
      refs.get().then((value) {
          List saws=value["seen"];
          
          if(!saws.contains(whoSee)){
              saws.add(whoSee);
              final json={"seen":saws};
              refs.update(json).whenComplete((){
                print("this message seen completed.................)))))))))))))))");
              });
          }
      });
    } else {
      //normal user
      final json = {"seen": "1"};
      // List localmsgss =
      //     await SecureStorageService().readAllMsgData("messages");
      DocumentReference ref =
          FirebaseFirestore.instance.collection("Messages").doc(msgId);
      ref.get().then((value) {
        if (value.exists) {
          ref.update(json);
        }
      });
      DirectMessage? result = await DirMsgsHelper().queryById(int.parse(msgId));
      if (result != null) {
        result.seen = "1";
        int res2 = await DirMsgsHelper().update(result);
        if (res2 > 0) {
          DirectMessage? resultt =
              await DirMsgsHelper().queryById(int.parse(msgId));
          print("message ${resultt!.msg} seen updated to ${resultt.seen}");
        }
      }
    }
  }

  String newSender = '';
  updateSender() {
    UserHelper().queryById(widget.sender!).then((value) {
      if (value != null) {
        setState(() {
          newSender = value.firstName;
        });
      }
    });

  }
late  Box<String> voicePaths;
late Box<Uint8List> msgsFiles;
  @override
  void initState() {
    voicePaths = Hive.box<String>("voice");
     msgsFiles = Hive.box<Uint8List>("messagesFiles");
       if (widget.sender != null) {
      updateSender();
    }
    updateSeen(widget.msgId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Column(
      children: [
        Align(
          alignment: Alignment
              .topLeft, //Change this to Alignment.topRight or Alignment.topLeft
          child: Column(
            children: [
              CustomPaint(
                painter: ChatBubble(
                    color: AppColors.backChatGroundColor,
                    alignment: Alignment.topLeft),
                child: Container(
                    constraints: BoxConstraints(
                        minWidth: 20,
                        maxWidth: DeviceUtils.getScaledWidth(context, 0.6)),
                    child: Column(
                      children: [
                        if (widget.sender != null)
                          Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:8.0),
                                  child: Text(
                                    newSender.length > 20
                                        ? newSender.split(" ")[0]
                                        : newSender,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        if (widget.replied_status)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4.0, left: 10, bottom: 3),
                                      child: Container(
                                        color: Colors.green,
                                        width: 4,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 1,
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          if (widget.repliedUserName != null &&
                                              widget.repliedUserName != "")
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4.0, bottom: 4),
                                                  child: Text(
                                                    widget.repliedUserName ==
                                                            widget.whoIam
                                                        ? "you"
                                                        : widget.repliedUserName!,
                                                    style: TextStyle(
                                                        color:
                                                            AppColors.appColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (widget.repliedId != null &&
                                              msgsFiles.get(widget.repliedId) !=
                                                  null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0),
                                              child: Image.memory(
                                                msgsFiles
                                                    .get(widget.repliedId)!,
                                                width: 150,
                                                height: 200,
                                                fit: BoxFit.cover,
                                                filterQuality:
                                                    FilterQuality.high,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Expanded(
                                                    child: Container(
                                                      width: 160,
                                                      height: 100,
                                                      child: PDFView(
                                                        pdfData: msgsFiles.get(
                                                            widget.repliedId),
                                                        enableSwipe: true,
                                                        swipeHorizontal: true,
                                                        autoSpacing: false,
                                                        pageFling: false,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          if (widget.repliedId != null &&
                                              voicePaths
                                                      .get(widget.repliedId) !=
                                                  null)
                                            AudioBubble(
                                              filepath: voicePaths
                                                  .get(widget.repliedId)!,
                                            ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 5,
                                                  right: 5,
                                                  top: 2,
                                                  bottom: 5),
                                              child: widget.replied,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 4, right: 5, top: 4, bottom: 5),
                          child: msgsFiles.get(widget.msgId) != null
                              ? widget.messag == ""
                                  ? widget.receivedFile.contains(".pdf")
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                          ),
                                          height: 200,
                                          width: 300,
                                          child: PDFView(
                                            pdfData:
                                                msgsFiles.get(widget.msgId),
                                            enableSwipe: true,
                                            swipeHorizontal: true,
                                            autoSpacing: false,
                                            pageFling: false,
                                          ),
                                        )
                                      : Image.memory(
                                          msgsFiles.get(widget.msgId)!,
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        )
                                  : Column(
                                      children: [
                                        widget.receivedFile.contains(".pdf")
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(100)),
                                                ),
                                                height: 200,
                                                width: 300,
                                                child: PDFView(
                                                  pdfData: msgsFiles
                                                      .get(widget.msgId),
                                                  enableSwipe: true,
                                                  swipeHorizontal: true,
                                                  autoSpacing: false,
                                                  pageFling: false,
                                                ),
                                              )
                                            : Image.memory(
                                                msgsFiles.get(widget.msgId)!,
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                        Padding(
                                            padding: const EdgeInsets.all(3),
                                            child:
                                                voicePaths.get(widget.msgId) !=
                                                        null
                                                    ? AudioBubble(
                                                        filepath: voicePaths
                                                            .get(widget.msgId)!,
                                                      )
                                                    : widget.child)
                                      ],
                                    )
                              : voicePaths.get(widget.msgId) != null
                                  ? AudioBubble(
                                      filepath: voicePaths.get(widget.msgId)!,
                                    )
                                  : Padding(padding: const EdgeInsets.only(left: 6),child: widget.child,),
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
        CustomHeightSpacer(
          size: 0.008,
        ),
        Row(
          children: [
            Text(
              widget.time,
              textAlign: TextAlign.right,
            
            ),
            Spacer(),
          ],
        )
      ],
    ));

    return Padding(
      padding: const EdgeInsets.only(right: 4.0, left: 4, top: 3, bottom: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          messageTextGroup,
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
