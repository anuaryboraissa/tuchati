// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hive/hive.dart';

import 'package:tuchati/screens/chat_room/widgets/chat_bubble.dart';

import '../../../constants/app_colors.dart';
import '../../../device_utils.dart';
import '../../../widgets/spacer/spacer_custom.dart';
import '../../services/secure_storage.dart';
import '../../utils.dart';

class ReceivedMessage extends StatelessWidget {
  final Widget child;
  final Widget? replied;
  final List? participants;
  final int userNow;
  String? sender;
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
    required this.replied_status,
    required this.time,
    required this.messag,
    this.repliedUserName,
    required this.msgId,
    required this.receivedFile,
    this.repliedId,
  }) : super(key: key);
  updateSeen(String msgId) async {
    if (userNow == 1) {
      //group
      List<dynamic> logged = await SecureStorageService().readByKeyData("user");
      String whoSee = logged[0];
      DocumentReference refs =
          FirebaseFirestore.instance.collection("GroupMessages").doc(msgId);
      refs.get().then((value) {
        List saws = value["seen"];
        List saws2 = value["seen"];
        bool see = false;
        if (saws.isEmpty) {
          saws.add(whoSee);
        } else {
          for (var s in saws) {
            if (s == whoSee) {
              //kashaona
              see = true;
            }
          }
          if (!see) {
            saws.add(whoSee);
          }
        }
        if(saws2.length!=saws.length){
        final json = {"seen": saws};
        refs.update(json).whenComplete(() async {
          print("seen updated successfully..............user $saws.......saws message ${value["msg"]}");
          List localmsgs =
              await SecureStorageService().readModalData("grpMessages");
          for (var msg = 0; msg < localmsgs.length; msg++) {
            List sawss = localmsgs[msg][7];
            if (localmsgs[msg][0] == msgId && !sawss.contains(whoSee)) {
              //perform changess
              sawss.add(whoSee);
              localmsgs[msg][7] = saws;
              Modal mysms = Modal("grpMessages", localmsgs);
              await SecureStorageService().writeModalData(mysms);
              // print("changess performed written sucesssssssfull in received");
            }
          }
        });
        }

      });
    } else {
      //normal user
      final json = {"seen": "1"};
      DocumentReference ref =
          FirebaseFirestore.instance.collection("Messages").doc(msgId);
      ref.get().then((value) {
        if (value.exists) {
          // print("message exists.............");
          ref.update(json).whenComplete(()async {
            // print("seen updated successfully........user direct  .......saws message ${value["msg"]}");
              List localmsgss =
            await SecureStorageService().readAllMsgData("messages");
            for(var msg=0;msg<localmsgss.length;msg++){
              if(localmsgss[msg][0]==msgId){
               localmsgss[msg][5]="1";
                Modal mysmss = Modal("messages", localmsgss);
              await SecureStorageService().writeModalData(mysmss);
              }
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Box<Uint8List> msgsFiles = Hive.box<Uint8List>("messagesFiles");
    if (participants != null) {
      for (var pa in participants!) {
        // print("compare sender and participants........${pa[3]}");
        if (pa[3] == sender) {
          sender = "${pa[0]} ${pa[1]}";
        }
      }
    }
    updateSeen(msgId);
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
                        minWidth: 100,
                        maxWidth: DeviceUtils.getScaledWidth(context, 0.6)),
                    child: Column(
                      children: [
                        if (sender != null)
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                Text(
                                  sender!.length > 20 ? "" : " $sender",
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,),
                                )
                              ],
                            ),
                          ),
                        if (replied_status)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, left: 8, bottom: 8),
                                      child: Container(
                                        color: Colors.green,
                                        width: 4,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          if (repliedUserName != null &&
                                              repliedUserName != "")
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 8.0, bottom: 8),
                                                  child: Text(
                                                    repliedUserName!,
                                                    style: TextStyle(
                                                       
                                                        color: AppColors.appColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (repliedId != null &&
                                              msgsFiles.get(repliedId) != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top:10.0),
                                              child: Image.memory(
                                                msgsFiles.get(repliedId)!,
                                                width: 150,
                                                height: 200,
                                                fit: BoxFit.cover,
                                                filterQuality: FilterQuality.high,
                                                errorBuilder:
                                                    (context, error, stackTrace) {
                                                  return Expanded(
                                                    child: Container(
                                                      width: 160,
                                                      height: 100,
                                                      child: PDFView(
                                                        pdfData:
                                                            msgsFiles.get(repliedId),
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
                                           Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: 10,
                                                  right: 20,
                                                  top: 10,
                                                  bottom: 10),
                                              child: replied,
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
                              left: 10, right: 20, top: 10, bottom: 10),
                          child: msgsFiles.get(msgId) != null
                              ? messag == ""
                                  ? receivedFile.contains(".pdf")
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
                                            pdfData: msgsFiles.get(msgId),
                                            enableSwipe: true,
                                            swipeHorizontal: true,
                                            autoSpacing: false,
                                            pageFling: false,
                                          ),
                                        )
                                      : Image.memory(
                                          msgsFiles.get(msgId)!,
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        )
                                  : Column(
                                      children: [
                                        receivedFile.contains(".pdf")
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
                                                  pdfData: msgsFiles.get(msgId),
                                                  enableSwipe: true,
                                                  swipeHorizontal: true,
                                                  autoSpacing: false,
                                                  pageFling: false,
                                                ),
                                              )
                                            : Image.memory(
                                                msgsFiles.get(msgId)!,
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              ),
                                        Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: child)
                                      ],
                                    )
                              : child,
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
              time,
              textAlign: TextAlign.right,
              // style: SafeGoogleFont (
              //   'SF Pro Text',
              //   fontSize: 12,
              //   fontWeight: FontWeight.w400,
              //   height: 1.2575,
              //   letterSpacing: 1,
              //   color: Color(0xff77838f),
              // ),
            ),
            Spacer(),
          ],
        )
      ],
    ));

    return Padding(
      padding: EdgeInsets.only(right: 10.0, left: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          messageTextGroup,
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
