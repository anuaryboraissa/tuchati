import 'dart:async';

import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/page/models/task.dart';
import 'package:tuchati/screens/page/widgets/card.dart';
import 'package:tuchati/services/SQLite/modelHelpers/userHelper.dart';
import 'package:tuchati/services/SQLite/models/dirMessages.dart';
import 'package:tuchati/services/SQLite/models/msgDetails.dart';
import 'package:tuchati/services/SQLite/models/user.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:mobile_number/mobile_number.dart';
import 'package:tuchati/services/contacts.dart';
import 'package:flutter/material.dart';
import 'package:tuchati/widgets/spacer/spacer_custom.dart';
import 'package:tuchati/utils.dart';
import '../../../../device_utils.dart';
import '../../services/SQLite/modelHelpers/dirMsgsHelper.dart';
import '../../services/SQLite/modelHelpers/directsmsdetails.dart';
import '../chat_room/chat_room.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool user_loaded = false;
  String mobile_number = '';

  bool syncs = false;
  Stream<List> _dataOfferContacts() async* {
    data = SecureStorageService().readCntactsData("contacts");
    yield* Stream.fromFuture(data!);
  }

  String senderr = '';
  findWhoIam() {
    SecureStorageService().readByKeyData("user").then(
      (value) {
        setState(() {
          senderr = value[0];
        });
      },
    );
  }

  List menuitems = ["Details", "Manages"];
  @override
  void initState() {
    findWhoIam();
    // usersToMimi();
    super.initState();
  }

  Future<List>? data;

  bool imeingia = false;
  @override
  Widget build(BuildContext context) {
    if (!imeingia) {
      setState(() {
        data = SecureStorageService().readCntactsData("contacts");
        imeingia = true;
      });
    }

    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            Positioned(
              child: Container(
                width: size.width,
                height: size.height / 3,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(10),
                    right: Radius.circular(10),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.appColor,
                      AppColors.primaryColor,
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          'Contacts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                syncs = true;
                              });
                              synchronizeContacts();
                            },
                            icon: const Icon(
                              Icons.sync,
                              color: Colors.white,
                            )),
                        IconButton(
                            onPressed: () {
                              showSearch(
                                context: context,
                                // delegate to customize the search bar
                                delegate: CustomSearchDelegateFriends(
                                    items: data, iam: senderr),
                              );
                            },
                            icon: const Icon(
                              Icons.search,
                              color: Colors.white,
                            )),
                        // PopupMenuButton(
                        //   icon: const Icon(Icons.more_vert_rounded,
                        //       color: Colors.white),
                        //   position: PopupMenuPosition.under,
                        //   onSelected: (value) {
                        //     print(value);
                        //   },
                        //   itemBuilder: (context) => menuitems
                        //       .map((e) =>
                        //           PopupMenuItem(value: e, child: Text(e)))
                        //       .toList(),
                        // ),
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    if (syncs)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: LinearProgressIndicator(
                              value: progress,
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                              color: AppColors.appColor,
                              backgroundColor: Colors.blue,
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(5),
                                child: Text("Fetched ",
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  "$fetched",
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.all(5),
                            child: Text("Analysing contacts......",
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: size.height / 4.5,
              left: 16,
              child: Container(
                width: size.width - 32,
                height: size.height / 1.4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(10),
                    right: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: StreamBuilder(
                    stream: _dataOfferContacts(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        // print("has data ${snapshot.data!.length}");

                        if (snapshot.data!.isEmpty) {
                          return Center(
                              child: Row(
                            children: const [
                              Text("Tap The"),
                              Icon(Icons.sync),
                              Text(" To synchronize your contacts"),
                            ],
                          ));
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.only(
                            top: 8,
                          ),
                          itemBuilder: (context, index) {
                            List contactt = snapshot.data![index];
                            return CardWidget(
                              contact: contactt,
                              iam: senderr,
                            );
                          },
                          itemCount: snapshot.data!.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 4,
                            );
                          },
                        );
                      } else if (snapshot.connectionState ==
                              ConnectionState.active ||
                          snapshot.connectionState == ConnectionState.done) {
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
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double progress = 0;
  int fetched = 0;
  void synchronizeContacts() async {
    await FirebaseService().storeFirebaseUsersInLocal();
    if (await FlutterContacts.requestPermission()) {
      List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true, withAccounts: true, withPhoto: true);

      List<dynamic> logged = await SecureStorageService().readByKeyData("user");
      if (logged.isNotEmpty) {
        String logedUser = logged[3];
        for (var x = 1; x <= contacts.length; x++) {
          setState(() {
            progress = (x / contacts.length);
          });
          List savedContacts =
              await SecureStorageService().readCntactsData("contacts");
          String phone = '';
          if (contacts[x - 1].phones[0].number.toString().startsWith("0")) {
            phone = contacts[x - 1]
                .phones[0]
                .number
                .toString()
                .replaceFirst("0", "+255");
          } else {
            phone = contacts[x - 1].phones[0].number;
          }
          List phoneName = [];

          bool contains = await SecureStorageService()
              .containsKey(phone.replaceAll(" ", ""));
          print("fetch contact............");
          if (contains && phone.replaceAll(" ", "") != logedUser) {
            List userData = await SecureStorageService()
                .readByKeyData(phone.replaceAll(" ", ""));
            print(
                "After compare hii contacts................${phone.replaceAll(" ", "")} and       $logedUser and contains $contains");
            bool isEmptyy = false;
            bool ckecker = false;
            phoneName.add(phone);
            phoneName.add(contacts[x - 1].displayName);
            phoneName.add("Hey there im using Tuchati");
            phoneName.add(userData[0]);
            if (savedContacts.isEmpty) {
              setState(() {
                fetched = fetched + 1;
              });
              //update name with id o
              MyUser? user = await UserHelper().queryById(userData[0]);
              if (user != null) {
                user.firstName = contacts[x - 1].displayName;
                int newUser = await UserHelper().update(user);
                if (newUser > 0) {
                  print("user name updated successfully..............");
                }
              }
              savedContacts.add(phoneName);
              isEmptyy = true;
              Contactt contactt = Contactt("contacts", savedContacts);
              await SecureStorageService().writeContactsData(contactt);
            } else {
              for (var cont = 0; cont < savedContacts.length; cont++) {
                if (phone == savedContacts[cont][0]) {
                  ckecker = true;
                }
              }
            }
            if (!ckecker && !isEmptyy) {
              setState(() {
                fetched = fetched + 1;
              });
              savedContacts.add(phoneName);
              Contactt contactt = Contactt("contacts", savedContacts);
              await SecureStorageService().writeContactsData(contactt);
            }
          }
        }
      }
    }
    setState(() {
      syncs = false;
    });
  }
}

//searchin friends
class CustomSearchDelegateFriends extends SearchDelegate {
  // Demo list to show querying
  Future<List>? items;
  String iam;
  CustomSearchDelegateFriends({
    required this.items,
    required this.iam,
  });
  List? newItems = [];
  assignItems() async {
    newItems = await items;
    // print("items assigned...$newItems");
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
            // print("imefikaa...............sssssssssssssssssssssss....${x[0]}");
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
      // print("my id fruit ${fruit[0]}");
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
        // print("my is.............................${ids[index]}");
        return ListTile(
          onTap: () {},
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
      // print("my id fruit ${fruit[0]}");
      if (fruit[1].toLowerCase().contains(query.toLowerCase())) {
        matchQuery2.add(fruit[1]);
        matchQuery2msgs.add(fruit[2]);
        items.add(fruit);
        ids.add(fruit[0]);
      }
    }
    return ListView.builder(
      itemCount: matchQuery2.length,
      itemBuilder: (context, index) {
        // print("my is.............................${ids[index]}");
        var result = matchQuery2[index];

        return ListTile(
          onTap: () async {
            String phone = ids[index].toString().replaceAll(" ", "");
            List<dynamic> user =
                await SecureStorageService().readByKeyData(phone);
            print("user is ${user[0]}.....");
            DirMsgDetails? detail =
                await DirectSmsDetailsHelper().queryById(user[0]);
            if (detail == null) {
              DirMsgDetails detail2 = DirMsgDetails(
                  name: user[1],
                  userId: user[0],
                  lastMessage: "",
                  date: "",
                  time: "",
                  unSeen: 0);
              int det = await DirectSmsDetailsHelper().insert(detail2);
              if (det > 0) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatRoomPage(
                    user: detail2,
                    name: result,
                    iam: iam,
                    fromDetails: false,
                  ),
                ));
              }
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatRoomPage(
                  user: detail,
                  name: result,
                  iam: iam,
                  fromDetails: false,
                ),
              ));
            }
            // ignore: use_build_context_synchronously
          },
          leading: CircleAvatar(
            backgroundImage: mygroups.get(ids[index]) == null
                ? MemoryImage(mygroups.get("userDefault")!)
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
