import 'dart:async';

import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/page/models/task.dart';
import 'package:tuchati/screens/page/widgets/card.dart';
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
import '../chat_room/chat_room.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  bool user_loaded = false;
  String mobile_number = '';
  late Timer timer;
  // List<SimCard> _simcard = <SimCard>[];

  // useTimer() {
  //   timer = Timer(
  //     const Duration(seconds: 10),
  //     () {
  //       data = SecureStorageService().readCntactsData("contacts");
  //     },
  //   );
  // }
  Stream<List> _dataOfferContacts() async* {
    data = SecureStorageService().readCntactsData("contacts");
    yield* Stream.fromFuture(data!);
  }

  String senderr = '';
  findWhoIam() async {
    SecureStorageService().readByKeyData("user").then((value) {
         setState(() {
      senderr = value[0];
    });
    },);
 
  }

  List menuitems = ["Details", "Manages"];
  @override
  void initState() {
    findWhoIam();
    // useTimer();
    // MobileNumber.listenPhonePermission((isPermissionGranted) {
    //   if (isPermissionGranted) {
    //     initMobileNumberState();
    //   } else {}
    // });
    // initMobileNumberState();
    super.initState();
  }

  Future<List>? data;
  // Future<void> initMobileNumberState() async {
  //   if (!await MobileNumber.hasPhonePermission) {
  //     await MobileNumber.requestPhonePermission;
  //     return;
  //   }
  //   String mobileNumber = '';
  //   try {
  //     mobileNumber = (await MobileNumber.mobileNumber)!;
  //     _simcard = (await MobileNumber.getSimCards)!;
  //   } on PlatformException catch (e) {
  //     print("failed to get mobile number becouse of ${e.message}");
  //   }
  //   if (!mounted) return;
  //   setState(() {
  //     mobile_number = mobileNumber;
  //   });
  // }

  // Widget fillcards() {
  //   List<Widget> widgets = _simcard
  //       .map((SimCard simcard) => Text(
  //             "${simcard.number} ${simcard.displayName}",
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontSize: 13,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ))
  //       .toList();
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: widgets,
  //   );
  // }

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
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert_rounded,
                              color: Colors.white),
                          position: PopupMenuPosition.under,
                          onSelected: (value) {
                            print(value);
                          },
                          itemBuilder: (context) => menuitems
                              .map((e) =>
                                  PopupMenuItem(value: e, child: Text(e)))
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    // fillcards(),
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
                        print("has data ${snapshot.data!.length}");

                        if (snapshot.data!.isEmpty) {
                          return Center(
                              child: CircularProgressIndicator(
                            color: AppColors.appColor,
                            strokeWidth: 3,
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
                        return const Center(
                            child: Text("waiting for connection............"));
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
      print("my id fruit ${fruit[0]}");
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
        print("my is.............................${ids[index]}");
        var result = matchQuery2[index];

        return ListTile(
          onTap: () async {
            String phone = ids[index].toString().replaceAll(" ", "");
            List<dynamic> user =
                await SecureStorageService().readByKeyData(phone);
            // ignore: use_build_context_synchronously
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatRoomPage(
                user: user,
                name: result,
                iam: iam,
              ),
            ));
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
