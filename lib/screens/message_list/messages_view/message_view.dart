// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'package:tuchati/screens/chat_room/chat_room.dart';
import 'package:tuchati/services/SQLite/models/grpDetails.dart';
import 'package:tuchati/services/SQLite/models/msgDetails.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:tuchati/utils.dart';

import '../../../../constants/app_colors.dart';
import '../../../../widgets/spacer/spacer_custom.dart';

class ChatUserListCardWidget extends StatefulWidget {
  const ChatUserListCardWidget({
    Key? key,
    required this.name,
    required this.message,
    required this.unReadCount,
    required this.isUnReadCountShow,
    required this.time,
    this.user,
    this.group,
  }) : super(key: key);

  final String name;
  final String message;
  final String unReadCount;
  final bool isUnReadCountShow;
  final String time;
  final DirMsgDetails? user;
  final GroupMsgDetails? group;
  @override
  State<ChatUserListCardWidget> createState() => _ChatUserListCardWidgetState();
}

class _ChatUserListCardWidgetState extends State<ChatUserListCardWidget> {
  bool isNumeric(String s) {
    // ignore: unnecessary_null_comparison
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
 String formattedDate="";
 late Box<Uint8List> groupsIcon;
 late Box<Uint8List> myProfile;
  @override
  void initState() {
    DateTime now = DateTime.now();
    myProfile= Hive.box<Uint8List>("myProfile");
    groupsIcon= Hive.box<Uint8List>("groups");
    setState(() {
    formattedDate = DateFormat('yyyy-MM-dd').format(now);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: widget.user==null
                          ? groupsIcon.get(widget.group!.grpId.toString()) == null
                              ? MemoryImage(groupsIcon.get("groupDefault")!)
                              : MemoryImage(groupsIcon.get(widget.group!.grpId.toString())!)
                          : myProfile.get(widget.user!.userId) == null
                              ? MemoryImage(groupsIcon.get("userDefault")!)
                              : MemoryImage(myProfile.get(widget.user!.userId)!),
                      fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const CustomWidthSpacer(
            size: 0.03,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: Color(0xff1e2022),
                  ),
                ),
                   Row(
                        children: [
                         if(widget.group!=null) Text("${widget.group!.lastSender}: ",style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400,
                          height: 1.8333333333,
                          letterSpacing: 1,),),
                          Text(widget.message,
                          style: SafeGoogleFont(
                          'SF Pro Text',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.8333333333,
                          letterSpacing: 1,
                          color: Color(0xff77838f),
                        ),),
                        
                        ],
                      )
                   
              ],
            ),
          ),
          CustomWidthSpacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
               widget.time.split(" ")[0]==formattedDate?widget.time.split(" ")[1]: widget.time.split(" ")[0],
                textAlign: TextAlign.right,
                style: SafeGoogleFont(
                  'SF Pro Text',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.2575,
                  letterSpacing: 1,
                  color: Color(0xff77838f),
                ),
              ),
              CustomHeightSpacer(),
              if (widget.isUnReadCountShow)
                Container(
                  // notificationMxt (0:34)
                  width: 43,
                  height: 25,
                  decoration: BoxDecoration(
                    color: AppColors.appColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      widget.unReadCount,
                      textAlign: TextAlign.center,
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.2575,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
