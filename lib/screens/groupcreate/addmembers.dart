import 'dart:async';

import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Animation/FadeAnimation.dart';
import 'package:tuchati/screens/groupcreate/details.dart';
import 'package:tuchati/screens/groupcreate/friendscard.dart';
import 'package:tuchati/services/contacts.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Addparticipant extends StatefulWidget {
  const Addparticipant({super.key});

  @override
  State<Addparticipant> createState() => _AddparticipantState();
}

class _AddparticipantState extends State<Addparticipant> {
  Future<List>? data;

  late Timer timer;
  loadContacts() async {
    await MyContacts().phoneContacts();
  }

  useTimer() {
    timer = Timer(
      const Duration(seconds: 55),
      () {
        loadContacts();
        setState(() {
          data = SecureStorageService().readCntactsData("contacts");
        });
      },
    );
  }

  @override
  void initState() {
    useTimer();
    super.initState();
  }

  bool attempt = false;
  List selected = [];
  List selectedUsers = [];
  @override
  Widget build(BuildContext context) {
    setState(() {
      setState(() {
        data = SecureStorageService().readCntactsData("contacts");
      });
    });
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 120,
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
                  left: 110,
                  top: 50,
                  width: 200,
                  height: 150,
                  child: FadeAnimation(
                      1.5,
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Add Participants",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FutureBuilder(
                future: data,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print("has data ${snapshot.data!.length}");

                    if (snapshot.data!.length == 0) {
                      return const Center(
                        child: Text("no contacts available"),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      itemBuilder: (context, index) {
                        List contactt = snapshot.data![index];
                        return GestureDetector(
                          onTap: () async {
                             String phone =
                                    contactt[0].toString().replaceAll(" ", "");
                                List<dynamic> user =
                                    await SecureStorageService()
                                        .readByKeyData(phone);
                            setState(()  {
                              
                              if (selected.contains(contactt[0])) {
                                print("remove ..");
                                selected.remove(contactt[0]);
                                selectedUsers.remove(user[0]);
                              } else {
                                print("add ..");
                                selectedUsers.add(user[0]);
                                selected.add(contactt[0]);
                              }
                            });
                          },
                          child: FriendCard(
                            contact: contactt,
                            selected: selected,
                          ),
                        );
                      },
                      itemCount: snapshot.data!.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 4,
                        );
                      },
                    );
                  }

                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.appColor,
                      strokeWidth: 3,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          selected.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FadeAnimation(
                      2,
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            attempt = true;
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => GroupDetails(
                              members: selectedUsers,
                            ),
                          ));
                          setState(() {
                            attempt = false;
                          });
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [
                                AppColors.appColor,
                                AppColors.primaryColor,
                              ])),
                          child: Center(
                            child: attempt
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  )
                                : const Text(
                                    "Continue",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      )),
                )
              : const Text(""),
        ],
      ),
    );
  }
}
