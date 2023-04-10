// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/chat_room/chat_room.dart';
import 'package:tuchati/screens/message_list/widgets/header.dart';
import 'package:tuchati/screens/message_list/widgets/status_bar.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/recording.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hive/hive.dart';

import '../../../device_utils.dart';
import 'messages_view/message_view.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({
    Key? key,
  }) : super(key: key);

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  //notification

//refreshPage
  loadNewDataCallBack() {
    setState(() {
      data = SecureStorageService().readUsersSentToMe("usersToMe");
      mygroups = SecureStorageService().readUsersSentToMe("grpSmsDetails");
    });
  }

//end refreshed
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
    // await SoundRecorder().init();
    // List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    totalSms = await SecureStorageService().readSecureData("totalSms");
    SecureStorageService().readByKeyData("user").then(
      (value) {
        setState(() {
          senderr = value[0];
          sender = senderr;
        });
      },
    );
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

  deleteData() async {
    // await SecureStorageService().deleteByKeySecureData("groups");
    // await SecureStorageService().deleteByKeySecureData("grpMessages");
    // await SecureStorageService().deleteByKeySecureData("groupMembers");
    //  await SecureStorageService().deleteByKeySecureData("groupAdmins");
    await SecureStorageService().deleteByKeySecureData("grpSmsDetails");
  }

  Stream<List> _dataOfferUsers() async* {
    data = SecureStorageService().readUsersSentToMe("usersToMe");
    // mygroups = SecureStorageService().readUsersSentToMe("grpSmsDetails");
    yield* Stream.fromFuture(data!);
  }

  Stream<List> _dataOfferGroup() async* {
    mygroups = SecureStorageService().readUsersSentToMe("grpSmsDetails");
    yield* Stream.fromFuture(mygroups!);
  }

  late Box<String> simples;
  @override
  void initState() {
    // deleteData();
    simples = Hive.box<String>("simples");

    groupsIcon = Hive.box<Uint8List>("groups");

    getDefaultImage();
    findWhoIam();

    super.initState();
  }

  void updateSeen(sender) async {
    List<dynamic> logged = await SecureStorageService().readByKeyData("user");
    String receiver = logged[0];
    print(
        "waiting while update seen............. sender $sender. receiver $receiver");

    FirebaseFirestore.instance
        .collection("Messages")
        .where("sender", isEqualTo: sender)
        .where("receiver", isEqualTo: receiver)
        .get()
        .then((msg) {
      msg.docs.forEach((element) async {
        print(
            "message ${element["msg"]}................going to be updateddddd");
        if (element["seen"] == "0") {
          final json = {"msg_id": element["msg_id"], "seen": "1"};
          await FirebaseService().updateMsgs(json);
        }
      });
    });
  }

  int imepita = 0;
  int totalUserChats = 0;
  int totalGrpChats = 0;
  int imeingia = 0;
  int imeingia2 = 0;
  final TextEditingController searched = TextEditingController();
  @override
  Widget build(BuildContext context) {
    setState(() {
      if (imepita < 2) {
        data = SecureStorageService().readUsersSentToMe("usersToMe");
        mygroups = SecureStorageService().readUsersSentToMe("grpSmsDetails");

        imepita = imepita + 1;
        // loadSms();
      }
      //
    });
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
                seching: () async {
                  showSearch(
                    context: context,
                    // delegate to customize the search bar
                    delegate: CustomSearchDelegate(
                        items: activeIndex.value == 1 ? data : mygroups,
                        activeIndex: activeIndex,
                        iam: sender),
                  );
                },
                activeIndexx: activeIndex,
                refreshed: () async {
                  await FirebaseService().receiveGroupsMsgAndSaveLocal();
                  await FirebaseService().groupMsgsDetails();
                  print("refreshing contentsssssssssssss...................");
                  Navigator.pop(context);
                  loadNewDataCallBack();
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
                  totalSms: totalUserChats == 0 ? '0' : "$totalUserChats",
                  totalGrpSms: simples.get("grpMessags") == null ? '0' : "${simples.get("grpMessags")}",
                  activeIndex: activeIndex,
                ),
              ),
              Expanded(
                child: Obx(() => activeIndex.value == 1
                    ? StreamBuilder(
                        stream: _dataOfferUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                if (snapshot.data![index].length < 9) {
                                  return Container();
                                }
                                if (imeingia<2) {
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (timeStamp) {
                                      setState(() {
                                        totalUserChats =
                                            snapshot.data![index][10];
                                               print("setted.......... total user chats $totalUserChats");
                                        imeingia = imeingia+1;
                                      });
                                    },
                                  );
                                }

                                return GestureDetector(
                                  onTap: () {
                                    print(
                                        "huyu sender name ${snapshot.data![snapshot.data!.length - index - 1][0]} i yake......${snapshot.data![snapshot.data!.length - index - 1][0]}");
                                    updateSeen(snapshot.data![
                                        snapshot.data!.length - index - 1][0]);
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                        user: snapshot.data![
                                            snapshot.data!.length - index - 1],
                                        name: "",
                                        iam: senderr,
                                      ),
                                    ))
                                        .then((value) {
                                      setState(() {
                                        loadNewDataCallBack();
                                        print(
                                            "state called successfully............................................");
                                      });
                                    });
                                  },
                                  child: ChatUserListCardWidget(
                                    name:
                                        "${snapshot.data![snapshot.data!.length - index - 1][1]} ${snapshot.data![snapshot.data!.length - index - 1][2]}",
                                    isOnline: true,
                                    message: snapshot.data![
                                            snapshot.data!.length - index - 1]
                                            [7]
                                        .toString(),
                                    unReadCount: snapshot.data![
                                            snapshot.data!.length - index - 1]
                                            [6]
                                        .toString(),
                                    isUnReadCountShow: snapshot.data![
                                                snapshot.data!.length -
                                                    index -
                                                    1][6] ==
                                            0
                                        ? false
                                        : true,
                                    time: snapshot.data![
                                        snapshot.data!.length - index - 1][8],
                                    user: snapshot.data![
                                        snapshot.data!.length - index - 1],
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
                            return const Center(
                                child:
                                    Text("waiting for connection............"));
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
                               
                                return GestureDetector(
                                  onTap: () {
                                    // updateSeen(snapshot.data![
                                    //     snapshot.data!.length - index - 1][0]);
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                        user: snapshot.data![
                                            snapshot.data!.length - index - 1],
                                        name: "",
                                        iam: senderr,
                                      ),
                                    ))
                                        .then((value) {
                                      setState(() {
                                        loadNewDataCallBack();
                                        print(
                                            "state called successfully............................................");
                                      });
                                    });
                                  },
                                  child: ChatUserListCardWidget(
                                    name: snapshot.data![
                                        snapshot.data!.length - index - 1][1],
                                    isOnline: true,
                                    message:
                                        "${snapshot.data![snapshot.data!.length - index - 1][3]}",
                                    unReadCount:
                                        "${snapshot.data![snapshot.data!.length - index - 1][2]}",
                                    isUnReadCountShow: snapshot.data![
                                                snapshot.data!.length -
                                                    index -
                                                    1][2] ==
                                            0
                                        ? false
                                        : true,
                                    time: snapshot.data![snapshot.data!.length -
                                            index -
                                            1][4]
                                        .toString(),
                                    user: snapshot.data![
                                        snapshot.data!.length - index - 1],
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
                            return const Center(
                                child:
                                    Text("waiting for connection............"));
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
}

//searching
class CustomSearchDelegate extends SearchDelegate {
  // Demo list to show querying
  Future<List>? items;
  RxInt activeIndex;
  String iam;
  CustomSearchDelegate({
    required this.items,
    required this.activeIndex,
    required this.iam,
  });
  List? newItems = [];
  assignItems() async {
    newItems = await items;
    print("items assigned...$newItems");
  }

  // first overwrite to
  // clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    assignItems();

    return [
      IconButton(
        onPressed: () async {
          List? items2 = await items;
          items2 ??= [];
          for (var x in items2) {
            print("imefikaa...............sssssssssssssssssssssss....${x[0]}");
          }

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

    for (var fruit in newItems!) {
      print("my id fruit ${fruit[0]}");
      if (fruit[1].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit[1]);
        ids.add(fruit[0]);
        items3.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        print("my is.............................${ids[index]}");
        return ListTile(
          onTap: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (_) => BlogScreen(
            //               blog: blogggs[index],
            //               backgrnd: log_page,
            //               b_white: log_text,
            //             )));
          },
          leading: CircleAvatar(
            backgroundImage: MemoryImage(mygroups.get(ids[index])!),
            // backgroundColor: Colors.blue,
          ),
          title: Text(result),
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
    List<String> ids = [];
    Box<Uint8List> mygroups = Hive.box<Uint8List>("groups");
    List<String> matchQuery2 = [];
    List<String> matchQuery2msgs = [];
    List items = [];
    for (var fruit in newItems!) {
      print("my id fruit ${fruit[0]}");
      if (fruit[1].toLowerCase().contains(query.toLowerCase())) {
        matchQuery2.add(fruit[1]);
        matchQuery2msgs.add(fruit[3]);
        items.add(fruit);
        ids.add(fruit[0]);
      }
    }
    return ListView.builder(
      itemCount: matchQuery2.length,
      itemBuilder: (context, index) {
        print("my is.............................${ids[index]}");
        var result = matchQuery2[index];

        return ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatRoomPage(
                user: items[index],
                name: "",
                iam: iam,
              ),
            ));
          },
          leading: CircleAvatar(
            backgroundImage: activeIndex.value == 1
                ? mygroups.get(ids[index]) == null
                    ? MemoryImage(mygroups.get("userDefault")!)
                    : MemoryImage(mygroups.get(ids[index])!)
                : mygroups.get(ids[index]) == null
                    ? MemoryImage(mygroups.get("groupDefault")!)
                    : MemoryImage(mygroups.get(ids[index])!),
            // backgroundColor: Colors.blue,
          ),
          title: Text(result),
          subtitle: Text(matchQuery2msgs[index]),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
          ),
        );
      },
    );
  }
}
