// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'package:tuchati/device_utils.dart';
import 'package:tuchati/screens/chat_room/widgets/chat_bubble.dart';
import 'package:tuchati/utils.dart';

import '../../../constants/app_colors.dart';
import '../../services/SQLite/modelHelpers/dirMsgsHelper.dart';
import '../../services/SQLite/modelHelpers/userHelper.dart';
import '../../services/SQLite/models/user.dart';
import '../recording/src/widgets/audio_bubble.dart';

class SentMessage extends StatefulWidget {
  final Widget child;
  final String messag;
  final bool sent;
  final bool replied;
  final String msgId;
  final String? replymsg;
  final String sentFile;
  final String? repliedId;
  final String? repliedUserName;
  final String? repliedFile;
  final String seen;
  final String date;
  const SentMessage({
    Key? key,
    required this.child,
    required this.messag,
    required this.sent,
    required this.replied,
    required this.msgId,
    this.replymsg,
    required this.sentFile,
    this.repliedId,
    this.repliedUserName,
    this.repliedFile,
    required this.seen,
    required this.date,
  }) : super(key: key);

  @override
  State<SentMessage> createState() => _SentMessageState();
}

class _SentMessageState extends State<SentMessage> {
  String newReplayedSender = '';

  checkIfSeen() async {
    Box<String> msgs = Hive.box<String>("messages");
    FirebaseFirestore.instance
        .collection("GroupMessages")
        .doc(widget.msgId)
        .get()
        .then(
      (value) {
        if (value.exists) {
          List seenn = value["seen"];
          if (seenn.length > 1) {
            msgs.put(widget.msgId, "1");
          }
        }
      },
    );
    FirebaseFirestore.instance
        .collection("Messages")
        .doc(widget.msgId)
        .get()
        .then(
      (value) {
        if (value.exists) {
          if (value["seen"] == "1") {
            msgs.put(widget.msgId, "1");
          }
        }
      },
    );
  }
 late Box<String> voicePaths;
 late  Box<String> msgs;
 late Box<Uint8List> msgsFiles;
 String formattedDate="";
@override
  void initState() {

    msgs = Hive.box<String>("messages");
    voicePaths= Hive.box<String>("voice");
    msgsFiles = Hive.box<Uint8List>("messagesFiles");
    checkIfSeen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Column(
      children: [
        Align(
          alignment: Alignment
              .topRight, //Change this to Alignment.topRight or Alignment.topLeft
          child: Column(
            children: [
              CustomPaint(
                painter: ChatBubble(
                    color: AppColors.appColor, alignment: Alignment.topRight),
                child: Container(
                  constraints: BoxConstraints(
                      minWidth: 20,
                      maxWidth: DeviceUtils.getScaledWidth(context, 0.6)),
                  child: !widget.replied
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 3, right: 4, top: 3, bottom: 3),
                          child: msgsFiles.get(widget.msgId) != null
                              ? widget.messag == ""
                                  ? widget.sentFile.contains(".pdf")
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
                                        widget.sentFile.contains(".pdf")
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
                                                    : widget.child),
                                                     
                                      ],
                                    )
                              : voicePaths.get(widget.msgId) != null
                                  ? AudioBubble(
                                      filepath: voicePaths.get(widget.msgId)!,
                                    )
                                  : widget.child,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 3.0, bottom: 3, left: 3),
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
                                        if (widget.repliedUserName != null)
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 3.0, bottom: 3),
                                                child: Text(
                                                  widget.repliedUserName!,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white54),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (widget.repliedId != null &&
                                            msgsFiles.get(widget.repliedId) !=
                                                null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4.0),
                                            child: Image.memory(
                                              msgsFiles.get(widget.repliedId)!,
                                              width: 150,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Expanded(
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    width: 160,
                                                    height: 150,
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
                                            voicePaths.get(widget.repliedId) !=
                                                null)
                                          AudioBubble(
                                            filepath: voicePaths
                                                .get(widget.repliedId)!,
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4,
                                              right: 5,
                                              top: 3,
                                              bottom: 4),
                                          child: Text(
                                            "${widget.replymsg}",
                                            style: SafeGoogleFont('SF Pro Text',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                height: 1.6428571429,
                                                letterSpacing: 0.5,
                                                color: Colors.white54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (msgsFiles.get(widget.msgId) != null)
                              if (widget.sentFile != "0")
                                widget.sentFile.contains(".pdf")
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(100)),
                                        ),
                                        height: 200,
                                        width: 300,
                                        child: PDFView(
                                          pdfData: msgsFiles.get(widget.msgId),
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
                              padding: const EdgeInsets.only(
                                  left: 4, right: 5, top: 4, bottom: 4),
                              child: voicePaths.get(widget.msgId) != null
                                  ? AudioBubble(
                                      filepath: voicePaths.get(widget.msgId)!,
                                    )
                                  : widget.child,
                            ),
                          ],
                        ),
                ),
              ),
               
            ],
          ),
        ),
        // CustomHeightSpacer(
        //   size: 0.001,
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(),
            msgs.get(widget.msgId) != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.check,
                            color: msgs.get(widget.msgId) == "1"
                                ? Colors.blue
                                : Colors.black45,
                            size: 15),
                        const SizedBox(
                          width: 1,
                        ),
                        Icon(Icons.check,
                            color: msgs.get(widget.msgId) == "1"
                                ? Colors.blue
                                : Colors.black45,
                            size: 15),
                      ],
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(right: 3.0),
                    child: Icon(Icons.check, color: Colors.black45, size: 15),
                  ),
          ],
        )
      ],
    ));

    return Padding(
      padding: const EdgeInsets.only(right: 4.0, left: 4, top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 10),
          messageTextGroup,
        ],
      ),
    );
  }
}
