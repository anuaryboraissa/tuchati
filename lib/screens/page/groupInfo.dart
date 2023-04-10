// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Animation/FadeAnimation.dart';
import 'package:tuchati/services/secure_storage.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo({
    Key? key,
    required this.user,
    this.groupMembers,
    this.gropAdmins,
  }) : super(key: key);
  final List<dynamic> user;
  final List? groupMembers;
  final List? gropAdmins;
  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  late Uint8List list;
  bool isNumeric(String s) {
      // ignore: unnecessary_null_comparison
      if (s == null) {
        return false;
      }
      return double.tryParse(s) != null;
    }

  var _iconn;
  File? filee;
  late Box<Uint8List> groupsIcon;
  getDefaultImage() async {
    final ByteData bytes = await rootBundle.load('assets/images/user.png');
    list = bytes.buffer.asUint8List();
    groupsIcon.put("userDefault", list);
  }
  List group=[];
  List<dynamic> logged=[];
  filterGroup()async{
      logged = await SecureStorageService().readByKeyData("user");
      List mygroups = await SecureStorageService().readModalData("groups");
      for(var grp in mygroups){
        print("compare hii...........${grp[0]}...................${widget.user[0]}");
        if(grp[0]==widget.user[0]){
          setState(() {
              group=grp;
          });
        }
      }
      print("now group is       $group");
  }

  Future<void> getGroupIcon() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _iconn = File(file!.path);
      filee = File(file.path);
    });
  }

  @override
  void initState() {
    if(isNumeric(widget.user[0])){
      filterGroup();
    }
    groupsIcon = Hive.box<Uint8List>("groups");
    getDefaultImage();
    super.initState();
  }
 bool imeingia=false;
  @override
  Widget build(BuildContext context) {
  if(!imeingia && isNumeric(widget.user[0])){
    filterGroup();
       
    setState(() {
      imeingia=true;
    });
  }
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.fill)),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 60.0, left: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: FadeAnimation(
                        1,
                        const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        )),
                  ),
                ),
                Positioned(
                  left: 90,
                  top: 50,
                  width: 200,
                  height: 150,
                  child: FadeAnimation(
                      1.5,
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          isNumeric(widget.user[0])
                              ? "${widget.user[1]}"
                              : "${widget.user[1]} ${widget.user[2]}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
                Positioned(
                  top: 100,
                  left: 100,
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: AppColors.appColor,
                    child: CircleAvatar(
                      backgroundImage: filee == null
                          ? groupsIcon.get("${widget.user[0]}") == null
                              ? MemoryImage(groupsIcon.get("userDefault")!)
                              : MemoryImage(
                                  groupsIcon.get("${widget.user[0]}")!)
                          : MemoryImage(filee!.readAsBytesSync()),
                      backgroundColor: Colors.white24,
                      radius: 70,
                    ),
                  ),
                ),
                Positioned(
                  right: 110,
                  top: 190,
                  child: ClipOval(
                      child: Container(
                    padding: const EdgeInsets.all(4),
                    color: Colors.white,
                    child: IconButton(
                      onPressed: () async {
                        print("take picture...........");
                        await getGroupIcon();
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 25,
                        color: AppColors.appColor,
                      ),
                    ),
                  )),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView(
              children: [
                Container(
                    padding: const EdgeInsets.all(12),
                    alignment: Alignment.center,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Common",
                                style: AppColors.headingStyle,
                              ),
                            ],
                          ),
                          ListTile(
                            leading: const Icon(Icons.group),
                            title: Text(isNumeric(widget.user[0])
                                ? "Group Descriptions"
                                : "UserName"),
                            subtitle: Text( group.isNotEmpty?"${group[3]}":""),
                            trailing: IconButton(icon: const Icon(Icons.edit),onPressed: () {
                              print("edit description.............");
                            },)
                          ),
                          const Divider(),
                          const ListTile(
                            leading: Icon(Icons.file_copy),
                            title: Text("Media,docs,links"),
                            subtitle: Text("sample images"),
                            trailing: Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 14,
                            ),
                          ),
                       
                          widget.groupMembers!=null? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                               Text(
                                "${widget.groupMembers!.length}",
                                style: AppColors.headingStyle,
                              ),
                              const SizedBox(width: 10,),
                              Text(
                                "Participants",
                                style: AppColors.headingStyle,
                              ),
                            ],
                          ):const Text(""),
                          if (widget.groupMembers!=null) SizedBox(
                            height: 270,
                            child: Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom:28.0),
                                child: ListView.builder(
                                  itemCount: widget.groupMembers!.length,
                                  itemBuilder: (context, index) {
                                    List member=widget.groupMembers![index];
                                    print("group admins............${widget.gropAdmins}");
                                     print("group admins............${widget.groupMembers}");
                                     // ignore: unused_local_variable
                                     bool exist=false;
                                     for(var adm in widget.gropAdmins!){
                                        if(adm[0]==member[0]){
                                         exist=true;
                                        }
                                     }
                                  return ListTile(
                                    leading:const Icon(Icons.person),
                                    title:logged.isNotEmpty && logged[0]==member[3]? const Text("You"): Text("${member[0]} ${member[1]}"),
                                    subtitle: Text("${member[2]}"),
                                    trailing: TextButton(child: Text(exist?"Admin":""),onPressed: () {
                                      
                                    },),
                            
                                    );
                                },),
                              ),
                            ),
                          ) ,
                          
                        ]))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
