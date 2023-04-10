// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hive/hive.dart';

import 'package:tuchati/device_utils.dart';
import 'package:tuchati/screens/chat_room/widgets/chat_bubble.dart';
import 'package:tuchati/utils.dart';

import '../../../constants/app_colors.dart';

class SentMessage extends StatelessWidget {
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
  }) : super(key: key);
  checkIfSeen() async {
    Box<String> msgs = Hive.box<String>("messages");
    FirebaseFirestore.instance
        .collection("GroupMessages")
        .doc(msgId)
        .get()
        .then(
      (value) {
        if (value.exists) {
          List seenn = value["seen"];
          if (seenn.length > 1) {
            msgs.put(msgId, "1");
          }
        }
      },
    );
    FirebaseFirestore.instance.collection("Messages").doc(msgId).get().then(
      (value) {
        if (value.exists) {
          if (value["seen"] == "1") {
            msgs.put(msgId, "1");
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // print("${repliedUserName==null} for $messag...................................");
    checkIfSeen();
    Box<String> msgs = Hive.box<String>("messages");
    Box<Uint8List> msgsFiles = Hive.box<Uint8List>("messagesFiles");

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
                      minWidth: 100,
                      maxWidth: DeviceUtils.getScaledWidth(context, 0.6)),
                  child: !replied
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 20, top: 10, bottom: 10),
                          child: msgsFiles.get(msgId) != null
                              ? messag == ""
                                  ? sentFile.contains(".pdf")
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
                                        sentFile.contains(".pdf")
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
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8, left: 8),
                                    child: Container(
                                      color: Colors.green,
                                      width: 4,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 2,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        if (repliedUserName != null)
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0, bottom: 8),
                                                child: Text(
                                                  repliedUserName!,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white54),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (repliedId != null &&
                                            msgsFiles.get(repliedId) != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
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
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    width: 160,
                                                    height: 150,
                                                    child: PDFView(
                                                      pdfData: msgsFiles
                                                          .get(repliedId),
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
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          child: Text(
                                            "$replymsg",
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
                            if (msgsFiles.get(msgId) != null)
                              if (sentFile != "0")
                                sentFile.contains(".pdf")
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          borderRadius: const BorderRadius.all(
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
                              padding: const EdgeInsets.only(
                                  left: 10, right: 20, top: 10, bottom: 10),
                              child: child,
                            )
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
            msgs.get(msgId) != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.check,
                            color: msgs.get(msgId) == "1"
                                ? Colors.blue
                                : Colors.black45,
                            size: 15),
                        const SizedBox(
                          width: 1,
                        ),
                        Icon(Icons.check,
                            color: msgs.get(msgId) == "1"
                                ? Colors.blue
                                : Colors.black45,
                            size: 15),
                      ],
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.check, color: Colors.black45, size: 15),
                  ),
          ],
        )
      ],
    ));

    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 30),
          messageTextGroup,
        ],
      ),
    );
  }
}
