// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/secure_storage.dart';
import 'customTabbar/example/first_example.dart';

class GroupDocuments extends StatefulWidget {
  const GroupDocuments({
    Key? key,
    required this.groupId,
    required this.grpName,
  }) : super(key: key);
  final String groupId;
  final String grpName;
  @override
  State<GroupDocuments> createState() => _GroupDocumentsState();
}

class _GroupDocumentsState extends State<GroupDocuments> {
  late Future<List> data;
  List images = [];
  List docs = [];
  List voice = [];

  filterDocuments()  {
    data = SecureStorageService().readGrpMsgData("grpMessages", widget.groupId);
    data.then((value) {
      for (var msg in value) {
        if (msg[8].toString().isNotEmpty && msg[8].toString() != "0") {
          if (msg[8].toString().contains(".pdf")) {
            setState(() {
              docs.add(msg);
            });
          } else if (msg[8].toString().contains(".m4a")) {
           setState(() {
             voice.add(msg);
           });
          } else {
           images.add(msg);
          }
        }
      }
    });
  }

  @override
  void initState() {
    
    filterDocuments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  MyTabBar(docs: docs, images: images, voices: voice, groupName: widget.grpName,);
  }
}
