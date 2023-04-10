// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';

import 'package:tuchati/screens/chat_room/chat_room.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:tuchati/utils.dart';

import '../../../../constants/app_colors.dart';
import '../../../../widgets/spacer/spacer_custom.dart';

class ChatUserListCardWidget extends StatefulWidget {
  const ChatUserListCardWidget({
    Key? key,
    required this.name,
    required this.isOnline,
    required this.message,
    required this.unReadCount,
    required this.isUnReadCountShow,
    required this.time,
    required this.user,
  }) : super(key: key);

  final String name;
  final bool isOnline;
  final String message;
  final String unReadCount;
  final bool isUnReadCountShow;
  final String time;
  final List<dynamic> user;
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
  @override
  Widget build(BuildContext context) {
   Box<Uint8List> groupsIcon=Hive.box<Uint8List>("groups");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration:  BoxDecoration(
                  image: DecorationImage(
                      image: isNumeric(widget.user[0])? groupsIcon.get(widget.user[0])==null? MemoryImage(groupsIcon.get("groupDefault")!): MemoryImage(groupsIcon.get(widget.user[0])!):MemoryImage(groupsIcon.get("userDefault")!), 
                      fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
              if (widget.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.backGroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          CustomWidthSpacer(
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
                 widget.message=="you: "? Row(children: [
                  Text(widget.message),
                  const Icon(Icons.file_copy)
                 ],): Text(
                  widget.message,
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.8333333333,
                    letterSpacing: 1,
                    color: Color(0xff77838f),
                  ),
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
                widget.time,
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
