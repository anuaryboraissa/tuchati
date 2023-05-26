// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/chat_room/chat_room.dart';
import 'package:tuchati/screens/message_list/widgets/header.dart';
import 'package:tuchati/screens/message_list/widgets/status_bar.dart';
import 'package:tuchati/screens/page/dialogue/dialogueBoxes.dart';
import 'package:tuchati/services/SQLite/groups/admins/adminHelper.dart';
import 'package:tuchati/services/SQLite/groups/group.dart';
import 'package:tuchati/services/SQLite/groups/groupHelper.dart';
import 'package:tuchati/services/SQLite/models/grpDetails.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/secure_storage.dart';

import '../../../device_utils.dart';
import '../../main.dart';
import '../../services/SQLite/databaseHelper/grpSmsdetails.dart';
import '../../services/SQLite/databaseHelper/logout.dart';
import '../../services/SQLite/groups/participants/participantHelper.dart';
import '../../services/SQLite/modelHelpers/directsmsdetails.dart';
import '../../services/SQLite/modelHelpers/grpDetailsHelper.dart';
import '../../services/SQLite/modelHelpers/grpMsgsHelper.dart';
import '../../services/SQLite/modelHelpers/userHelper.dart';
import '../../services/SQLite/models/msgDetails.dart';
import '../page/progress/progress.dart';
import 'messages_view/message_view.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({
    Key? key,
  }) : super(key: key);

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  RxInt activeIndex = 1.obs;
  late Timer timer;
  List userMsgs = [];
  List userMsgsIdentities = [];
  var sender = '';
  String? totalSms;

  Future<List>? data;
  Future<List>? mygroups;
  String senderr = '';
  findWhoIam() async {
    SecureStorageService().readByKeyData("user").then(
      (value) {
        setState(() {
          senderr = value[0];
          sender = senderr;
        });
      },
    );
  }

  deleteGroup(String id) async {
    GroupMsgDetails? group = await GroupSmsDetailsHelper().queryById(id);
    if (group != null) {
      int d = await GroupSmsDetailsHelper().delete(group.grpId);
      if (d > 0) {
        print("next level..______");
        GroupModel? grp = await GroupHelper().queryById(group.grpId);
        if (grp != null) {
          int d2 = await GroupHelper().delete(grp.grpId);
          if (d2 > 0) {
            print("next level. two.______");
            Box<Uint8List> grpIcon = Hive.box<Uint8List>("groups");
            grpIcon.delete(grp.grpId.toString());
            DocumentReference ref =
                FirebaseFirestore.instance.collection("Groups").doc(id);
            ref.get().then((value) {
              List participants = value["participants"];
              List admins = value["admins"];
              if (participants.contains(senderr)) {
                participants.remove(senderr);
                if (admins.contains(senderr)) {
                  admins.remove(senderr);
                }
                final json = {"participants": participants, "admins": admins};
                ref.update(json).whenComplete(() async {
                  _dataOfferGroup();
                  queryTotalChats();
                  await Progresshud.mySnackBar(
                      context, "Successfully delete the group");
                });
              }
            });
          }
        }
      }
    }
  }

  popupDialogue(String message, String groupId, GroupMsgDetails? group) async {
    await DialogueBox.showInOutDailog(
        context: context,
        yourWidget: Text(message),
        secondButton: ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.appColor),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatRoomPage(
                  group: group,
                  name: group!.name,
                  iam: senderr,
                  fromDetails: false,
                ),
              ));
            },
            child: const Text("no")),
        firstButton: ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.appColor),
            onPressed: () {
              deleteGroup(groupId);
              Navigator.pop(context);
            },
            child: const Text("yes")));
  }

  @override
  void dispose() {
    super.dispose();
  }

  late Box<Uint8List> groupsIcon;
  late Uint8List list;
  late Uint8List list2;

  getDefaultImage() async {
    final ByteData bytes = await rootBundle.load('assets/images/profile.png');
    final ByteData bytes2 = await rootBundle.load('assets/images/group.png');
    setState(() {
      list = bytes.buffer.asUint8List();
      list2 = bytes2.buffer.asUint8List();
      groupsIcon.put("userDefault", list);
      groupsIcon.put("groupDefault", list2);
    });
  }

  int counter = 0;
  bool? start;
  Stream<List<DirMsgDetails?>> _userDetails() async* {
    yield* Stream.fromFuture(DirectSmsDetailsHelper().queryAll());
  }

  Stream<List<GroupMsgDetails?>> _dataOfferGroup() async* {
    yield* Stream.fromFuture(GroupSmsDetailsHelper().queryAll());
  }

  late Box<String> simples;
  @override
  void initState() {
    simples = Hive.box<String>("simples");
    groupsIcon = Hive.box<Uint8List>("groups");
    getDefaultImage();
    findWhoIam();
    // checkGroupChats();
    super.initState();
  }

  void updateSeen(sender) async {
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    String receiver = logged[0];

    FirebaseFirestore.instance
        .collection("Messages")
        .where("sender", isEqualTo: sender)
        .where("receiver", isEqualTo: receiver)
        .get()
        .then((msg) {
      msg.docs.forEach((element) async {
        if (element["seen"] == "0") {
          final json = {"msg_id": element["msg_id"], "seen": "1"};
          await FirebaseService().updateMsgs(json);
        }
      });
    });
  }

  queryTotalChats() {
    DirectSmsDetailsHelper().queryChats().then((value) {
      setState(() {
        totalUserChats = value.length;
      });
    });
    GroupSmsDetailsHelper().queryChats().then((value) {
      setState(() {
        totalGrpChats = value.length;
      });
    });
  }

  int imepita = 0;
  int totalUserChats = 0;
  int totalGrpChats = 0;
  late Box<List<String>> grpLetfs;
  final TextEditingController searched = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (imepita < 2) {
      queryTotalChats();
      grpLetfs = Hive.box<List<String>>("lefts");
      setState(() {
        imepita = imepita + 1;
      });
    }
    return Scaffold(
        body: Container(
          height: DeviceUtils.getScaledHeight(context, 1),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.backGroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //header
              HeaderWithSearchBar(
                starting: start,
                seching: () async {
                  showSearch(
                    context: context,
                    // delegate to customize the search bar
                    delegate: CustomSearchDelegate(
                        itemsGroup: activeIndex.value == 2
                            ? GroupSmsDetailsHelper().queryAll()
                            : null,
                        itemsUser: activeIndex.value == 1
                            ? DirectSmsDetailsHelper().queryAll()
                            : null,
                        iam: sender),
                  );
                },
                activeIndexx: activeIndex,
                refreshed: () async {
                  // refreshContext();
                },
                controller: searched,
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
                child: StatusBarWidget(
                  callback: (index) {
                    activeIndex.value = index;
                  },
                  totalSms: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chats"),
                      const SizedBox(
                        width: 50,
                      ),
                      totalUserChats == 0
                          ? const Text("")
                          : CircleAvatar(
                              backgroundColor: AppColors.appColor,
                              child: Text(
                                  totalUserChats == 0 ? '0' : "$totalUserChats",
                                  style: const TextStyle(color: Colors.white)))
                    ],
                  ),
                  totalGrpSms: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Groups"),
                      const SizedBox(
                        width: 50,
                      ),
                      totalGrpChats == 0
                          ? const Text("")
                          : CircleAvatar(
                              backgroundColor: AppColors.appColor,
                              child: Text(
                                totalGrpChats.toString(),
                                style: const TextStyle(color: Colors.white),
                              ))
                    ],
                  ),
                  activeIndex: activeIndex,
                ),
              ),
              Expanded(
                child: Obx(() => activeIndex.value == 1
                    ? StreamBuilder(
                        stream: _userDetails(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                // if (snapshot.data![index].length < 9) {
                                //   return Container();
                                // }
                                DirMsgDetails detail = snapshot
                                    .data![snapshot.data!.length - index - 1]!;
                                return GestureDetector(
                                  onTap: () {
                                    // print(
                                    //     "huyu sender name ${snapshot.data![snapshot.data!.length - index - 1][0]} i yake......${snapshot.data![snapshot.data!.length - index - 1][0]}");
                                    // updateSeen(detail.);
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                        user: snapshot.data![
                                            snapshot.data!.length - index - 1]!,
                                        name: "",
                                        iam: senderr,
                                        fromDetails: false,
                                      ),
                                    ))
                                        .then((value) {
                                      setState(() {
                                        _userDetails();
                                        queryTotalChats();
                                      });
                                    });
                                  },
                                  child: ChatUserListCardWidget(
                                    name: detail.name,
                                    message: detail.lastMessage.toString(),
                                    unReadCount: detail.unSeen.toString(),
                                    isUnReadCountShow:
                                        detail.unSeen == 0 ? false : true,
                                    time: detail.date,
                                    user: detail,
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.connectionState ==
                                  ConnectionState.active ||
                              snapshot.connectionState ==
                                  ConnectionState.done) {
                            return const Text(
                                "connection is active can be done any time");
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.appColor,
                                strokeWidth: 3,
                              ),
                            ));
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.appColor,
                                strokeWidth: 3,
                              ),
                            );
                          }
                        })
                    : StreamBuilder(
                        stream: _dataOfferGroup(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                GroupMsgDetails? group = snapshot
                                    .data![snapshot.data!.length - index - 1];

                                return GestureDetector(
                                  onLongPress: () {
                                    // removeGroup(snapshot.data![
                                    //     snapshot.data!.length - index - 1][1]);
                                  },
                                  onTap: () {
                                    // updateSeen(snapshot.data![
                                    //     snapshot.data!.length - index - 1][0]);

                                    if (grpLetfs.get(senderr) != null &&
                                        grpLetfs
                                            .get(senderr)!
                                            .contains(group.grpId.toString())) {
                                      //already lefts
                                      popupDialogue(
                                          "You have already lefts this group ${group.name} \n Are yo want do delete it ?",
                                          group.grpId.toString(),
                                          group);
                                    } else {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => ChatRoomPage(
                                          group: group,
                                          name: group.name,
                                          iam: senderr,
                                          fromDetails: false,
                                        ),
                                      ))
                                          .then((value) {
                                        setState(() {
                                          _dataOfferGroup();
                                          queryTotalChats();
                                        });
                                      });
                                    }
                                  },
                                  child: ChatUserListCardWidget(
                                    name: group!.name,
                                    message: group.lastMessage,
                                    unReadCount: group.unSeen.toString(),
                                    isUnReadCountShow:
                                        group.unSeen == 0 ? false : true,
                                    time: group.date.toString(),
                                    group: group,
                                  ),
                                );
                              },
                            );
                          } else if (snapshot.connectionState ==
                                  ConnectionState.active ||
                              snapshot.connectionState ==
                                  ConnectionState.done) {
                            return const Text(
                                "connection is active can be done any time");
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.appColor,
                                strokeWidth: 3,
                              ),
                            ));
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.appColor,
                                strokeWidth: 3,
                              ),
                            );
                          }
                        })),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Obx(() => activeIndex.value == 1
            ? SizedBox(
                width: 45,
                height: 45,
                child: FittedBox(
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: AppColors.appColor,
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  ),
                ),
              )
            : const SizedBox()));
  }

  removeGroup(String groupName) async {
    await DialogueBox.showInOutDailog(
        context: context,
        yourWidget: Padding(
          padding: const EdgeInsets.all(10),
          child: Text("Do you want to delete $groupName"),
        ),
        firstButton: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("yes")),
        secondButton: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("no")));
  }
}

//searching
class CustomSearchDelegate extends SearchDelegate {
  // Demo list to show querying
  Future<List<DirMsgDetails?>>? itemsUser;
  Future<List<GroupMsgDetails?>>? itemsGroup;
  String iam;
  CustomSearchDelegate({required this.iam, this.itemsGroup, this.itemsUser});
  List<DirMsgDetails?>? newItemsUser = [];
  List<GroupMsgDetails?>? newItemsGroup = [];
  assignItems() async {
    newItemsUser = await itemsUser;
    newItemsGroup = await itemsGroup;
  }

  // first overwrite to
  // clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    assignItems();

    return [
      IconButton(
        onPressed: () async {
          // List? items2 = await items;
          // items2 ??= [];
          // for (var x in items2) {
          //   // print("imefikaa...............sssssssssssssssssssssss....${x[0]}");
          // }

          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  // second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back_ios_new),
    );
  }

  // third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    List<String> ids = [];
    Box<Uint8List> mygroups = Hive.box<Uint8List>("groups");
    List items3 = [];
    print(itemsGroup == null
        ? "total group search ${newItemsGroup!.length}"
        : "total user search ${newItemsUser!.length}.......");
    return ListView.builder(
      itemCount: itemsGroup != null
          ? query.isEmpty
              ? newItemsGroup!.length
              : newItemsGroup!
                  .where((element) =>
                      element!.name.toLowerCase().contains(query.toLowerCase()))
                  .toList()
                  .length
          : query.isEmpty
              ? newItemsUser!.length
              : newItemsUser!
                  .where((element) =>
                      element!.name.toLowerCase().contains(query.toLowerCase()))
                  .toList()
                  .length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        print("my is indexesss.............................$index");
        return ListTile(
          onTap: () {},
          title: Text(itemsGroup == null
              ? newItemsUser!
                  .where((element) =>
                      element!.name.toLowerCase().contains(query.toLowerCase()))
                  .toList()[index]!
                  .name
              : newItemsGroup!
                  .where((element) =>
                      element!.name.toLowerCase().contains(query.toLowerCase()))
                  .toList()[index]!
                  .name),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
          ),
        );
      },
    );
  }

  // last overwrite to show the
  // querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView.builder(
      itemCount: itemsGroup != null
          ? newItemsGroup!
              .where((element) =>
                  element!.name.toLowerCase().contains(query.toLowerCase()))
              .toList()
              .length
          : newItemsUser!
              .where((element) =>
                  element!.name.toLowerCase().contains(query.toLowerCase()))
              .toList()
              .length,
      itemBuilder: (context, index) {
        // var result = matchQuery[index];
        return ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatRoomPage(
                user: itemsGroup == null
                    ? newItemsUser!
                        .where((element) => element!.name
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList()[index]
                    : null,
                group: itemsGroup != null
                    ? newItemsGroup!
                        .where((element) => element!.name
                            .toLowerCase()
                            .contains(query.toLowerCase()))
                        .toList()[index]
                    : null,
                name: "",
                iam: iam,
                fromDetails: false,
              ),
            ));
          },
          title: Text(itemsGroup == null
              ? newItemsUser!
                  .where((element) =>
                      element!.name.toLowerCase().contains(query.toLowerCase()))
                  .toList()[index]!
                  .name
              : newItemsGroup!
                  .where((element) =>
                      element!.name.toLowerCase().contains(query.toLowerCase()))
                  .toList()[index]!
                  .name),
          subtitle: Text(itemsGroup == null
              ? newItemsUser!
                  .where((element) =>
                      element!.name.toLowerCase().contains(query.toLowerCase()))
                  .toList()[index]!
                  .lastMessage
              : newItemsGroup!
                  .where((element) =>
                      element!.name.toLowerCase().contains(query.toLowerCase()))
                  .toList()[index]!
                  .lastMessage),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
          ),
        );
      },
    );
  }
}
