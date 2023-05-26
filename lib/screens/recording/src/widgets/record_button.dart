// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:tuchati/constants/app_colors.dart';

import '../../../../services/SQLite/modelHelpers/dirMsgsHelper.dart';
import '../../../../services/SQLite/models/dirMessages.dart';
import '../../../../services/SQLite/updateDetails.dart';
import '../../../../services/firebase.dart';
import '../../../../services/groups.dart';
import '../../../../services/secure_storage.dart';
import '../globals.dart';
import 'flow_shader.dart';
import 'lottie_animation.dart';

class RecordButton extends StatefulWidget {
  RecordButton({
    Key? key,
    required this.controller,
    required this.receiver,
    required this.refresh,
    required this.repliedMsg,
    required this.repliedMsgId,
    this.repliedMsgSender,
  }) : super(key: key);

  final AnimationController controller;
  final String receiver;
  final Function() refresh;
  final String repliedMsg;
  final String repliedMsgId;
  final String? repliedMsgSender;
  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  static const double size = 55;

  final double lockerHeight = 220;
  double timerWidth = 0;

  late Animation<double> buttonScaleAnimation;
  late Animation<double> timerAnimation;
  late Animation<double> lockerAnimation;

  DateTime? startTime;
  Timer? timer;
  String recordDuration = "00:00";
  // late Record record;

  bool isLocked = false;
  bool showLottie = false;

  @override
  void initState() {
    super.initState();
    buttonScaleAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticInOut),
      ),
    );
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timerWidth = MediaQuery.of(context).size.width - 2 * Globals.defaultPadding;
    timerAnimation =
        Tween<double>(begin: timerWidth + Globals.defaultPadding, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
    lockerAnimation =
        Tween<double>(begin: lockerHeight + Globals.defaultPadding + 10, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
  }

//sendMessage
  bool isNumeric(String s) {
    // ignore: unnecessary_null_comparison
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  String msgidd = "";
  sendVoiceNote(filePath, recordDuration) async {
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    String sender = logged[0];

    File file = File(filePath);
    DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
    var nowDate = format.format(DateTime.now());
    var now = DateFormat.Hm().format(DateTime.now());

    String msgId = DateTime.now().millisecondsSinceEpoch.toString();
    if (isNumeric(widget.receiver)) {
      while (await FirebaseService().checkIfMsgExist(msgId)) {
        // print("msg existssssssssssss ipo ");
        msgId = DateTime.now().millisecondsSinceEpoch.toString();
      }
      //grp message
      sendGrpVoiceNote(sender, msgId, file, nowDate, recordDuration, filePath);
    } else {
      while (await FirebaseService().checkIfMsgIdExist(msgId)) {
        msgId = DateTime.now().millisecondsSinceEpoch.toString();
      }
//direct user
      sendDirectVoiceNote(
          sender, msgId, file, nowDate, now, recordDuration, filePath);
    }
  }

  sendGrpVoiceNote(sender, msgId, File audio, nowDate, duration, path) async {
    Box<String> voicePaths = Hive.box<String>("voice");
    voicePaths.put(msgId, path);
    List attributes = [
      msgId,
      "",
      sender,
      widget.repliedMsg,
      nowDate,
      widget.receiver,
      "0",
      [],
      "0",
      "$msgId.m4a",
      duration,
      widget.repliedMsgId,
      widget.repliedMsgSender ?? ""
    ];
    print("attributes length now.................${attributes.length}");
    List grpMsgs = await SecureStorageService().readModalData("grpMessages");
    attributes.removeAt(8);
    grpMsgs.add(attributes);
    Modal modal = Modal("grpMessages", grpMsgs);
    await SecureStorageService().writeModalData(modal);
  
    attributes.insert(8, "0");
    print("attributes length firebase.................${attributes.length}");
    await GroupService().saveGrpMessages(attributes, audio);
    setState(() {});
  }

  sendDirectVoiceNote(
      sender, msgId, File audio, nowDate, now, duration, path) async {
    Box<String> voicePaths = Hive.box<String>("voice");
    voicePaths.put(msgId, path);
    List attributes = [
      msgId,
      "",
      sender,
      widget.receiver,
      widget.repliedMsg,
      "0",
      nowDate,
      now,
      "$msgId.m4a",
      duration,
      widget.repliedMsgId
    ];
    List msgs = [];
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
      DirectMessage? result2 =
          await DirMsgsHelper().queryById(int.parse(msgId));
      if (result2 != null) {
        UpdateDetails().updateUserDetails(
            result2.msg, result2.time, result2.date, attributes[3]);
        print(
            "data inserted is ${result2.msg}...with id ${result2.msgId}.......");
      
      }
    }
    attributes.insert(8, "0");
    attributes.insert(9, "0");
    // ignore: use_build_context_synchronously
    await FirebaseService()
        .sendFiletofirebase(msgId, audio, attributes, context);
    setState(() {
      msgidd = "";
    });
  }

  @override
  void dispose() {
    Record().dispose();
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        lockSlider(),
        cancelSlider(),
        audioButton(),
        if (isLocked) timerLocked(),
      ],
    );
  }

  Widget lockSlider() {
    return Positioned(
      bottom: -lockerAnimation.value,
      child: Container(
        height: lockerHeight,
        width: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: AppColors.appColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.only(right: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const FaIcon(FontAwesomeIcons.lock, size: 20, color: Colors.white),
            const SizedBox(height: 8),
            FlowShader(
              direction: Axis.vertical,
              child: Column(
                children: const [
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                  ),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                  Icon(Icons.keyboard_arrow_up, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cancelSlider() {
    return Positioned(
      right: -timerAnimation.value,
      child: Container(
        height: 60,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: AppColors.appColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              showLottie ? const LottieAnimation() : Text(recordDuration),
              const SizedBox(width: size),
              FlowShader(
                child: Row(
                  children: const [
                    Icon(Icons.keyboard_arrow_left),
                    Text("Slide to cancel")
                  ],
                ),
                duration: const Duration(seconds: 3),
                flowColors: const [Colors.white, Colors.grey],
              ),
              const SizedBox(width: size),
            ],
          ),
        ),
      ),
    );
  }

  Widget timerLocked() {
    return Positioned(
      right: 0,
      child: Container(
        height: size,
        width: timerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: AppColors.appColor,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 25),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              Vibrate.feedback(FeedbackType.success);
              timer?.cancel();
              timer = null;
              startTime = null;

              var filePath = await Record().stop();
              sendVoiceNote(filePath, recordDuration);
              recordDuration = "00:00";
              setState(() {
                isLocked = false;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(recordDuration),
                FlowShader(
                  duration: const Duration(seconds: 3),
                  flowColors: const [Colors.white, Colors.grey],
                  child: const Text("Tap lock to stop"),
                ),
                const Center(
                  child: FaIcon(
                    FontAwesomeIcons.lock,
                    size: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget audioButton() {
    return GestureDetector(
      onLongPressDown: (_) {
        debugPrint("onLongPressDown");
        widget.controller.forward();
      },
      onLongPressUp: widget.refresh,
      onLongPressEnd: (details) async {
        debugPrint("onLongPressEnd");

        if (isCancelled(details.localPosition, context)) {
          Vibrate.feedback(FeedbackType.heavy);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          setState(() {
            showLottie = true;
          });

          Timer(const Duration(milliseconds: 1440), () async {
            widget.controller.reverse();
            debugPrint("Cancelled recording");
            var filePath = await Record().stop();
            debugPrint(filePath);
            File(filePath!).delete();
            debugPrint("Deleted $filePath");
            showLottie = false;
          });
        } else if (checkIsLocked(details.localPosition)) {
          widget.controller.reverse();

          Vibrate.feedback(FeedbackType.heavy);
          debugPrint("Locked recording");
          debugPrint(details.localPosition.dy.toString());
          setState(() {
            isLocked = true;
          });
        } else {
          widget.controller.reverse();

          Vibrate.feedback(FeedbackType.success);

          timer?.cancel();
          timer = null;
          startTime = null;

          var filePath = await Record().stop();
          //send mesag
          print("file path is of ..............$filePath");
          sendVoiceNote(filePath, recordDuration);
          recordDuration = "00:00";
          // AudioState.files.add(filePath!);
          // Globals.audioListKey.currentState!
          //     .insertItem(AudioState.files.length - 1);
          // debugPrint(filePath);
        }
      },
      onLongPressCancel: () {
        debugPrint("onLongPressCancel");
        widget.controller.reverse();
      },
      onLongPress: () async {
        debugPrint("onLongPress start.............");
        Vibrate.feedback(FeedbackType.success);
        if (await Record().hasPermission()) {
          // record = Record();
          print("start recording........................");
          await Record().start(
            path:
                "${Globals.documentPath}audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
            encoder: AudioEncoder.AAC,
            bitRate: 128000,
            samplingRate: 44100,
          );
          startTime = DateTime.now();
          timer = Timer.periodic(const Duration(seconds: 1), (_) {
            final minDur = DateTime.now().difference(startTime!).inMinutes;
            final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
            String min = minDur < 10 ? "0$minDur" : minDur.toString();
            String sec = secDur < 10 ? "0$secDur" : secDur.toString();
            setState(() {
              recordDuration = "$min:$sec";
              // msgidd = msgId;
            });
          });
        }
      },
      child: Transform.scale(
        scale: buttonScaleAnimation.value,
        child: Container(
          height: size,
          width: size,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  bool checkIsLocked(Offset offset) {
    return (offset.dy < -35);
  }

  bool isCancelled(Offset offset, BuildContext context) {
    return (offset.dx < -(MediaQuery.of(context).size.width * 0.2));
  }
}
