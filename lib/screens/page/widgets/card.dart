// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'package:tuchati/screens/chat_room/chat_room.dart';
import 'package:tuchati/screens/page/models/task.dart';
import 'package:tuchati/services/secure_storage.dart';

import '../../../services/SQLite/modelHelpers/directsmsdetails.dart';
import '../../../services/SQLite/models/msgDetails.dart';

class CardWidget extends StatelessWidget {
  final List contact;
  final String iam;
  const CardWidget({
    Key? key,
    required this.contact,
    required this.iam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print("contacts...............$contact");
    Box<Uint8List> groupsIcon = Hive.box<Uint8List>("groups");
    Box<Uint8List> myProfile = Hive.box<Uint8List>("myProfile");
    return Card(
      elevation: 8,
      shadowColor: const Color(0xff2da9ef),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: ListTile(
        onTap: () async {
          // print("weit");
          String phone = contact[0].toString().replaceAll(" ", "");
          List<dynamic> user =
              await SecureStorageService().readByKeyData(phone);
          // print("complete");
          DirMsgDetails? detail =
              await DirectSmsDetailsHelper().queryById(user[0]);
          if (detail == null) {
            DirMsgDetails detail2 = DirMsgDetails(
                name: contact[1].toString(),
                userId: user[0],
                lastMessage: '',
                date: "",
                time: "",
                unSeen: 0);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatRoomPage(
                user: detail2,
                name: contact[1].toString(),
                iam: iam,
                fromDetails: false,
              ),
            ));
          } else {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatRoomPage(
                user: detail,
                name: contact[1].toString(),
                iam: iam,
                fromDetails: false,
              ),
            ));
          }

          // print(user[0]);
        },
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        minLeadingWidth: 2,
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: myProfile.get(contact[3]) != null
                    ? MemoryImage(myProfile.get(contact[3])!)
                    : MemoryImage(groupsIcon.get("userDefault")!),
                fit: BoxFit.fill),
            shape: BoxShape.circle,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            contact[1].toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: Text(
          contact[2].toString(),
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 15,
          ),
        ),
        trailing: Text(
          "",
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
