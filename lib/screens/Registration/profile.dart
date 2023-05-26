import "package:firebase_storage/firebase_storage.dart" as storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Animation/FadeAnimation.dart';
import 'package:tuchati/screens/main_tab_bar/main_tab_bar.dart';
import 'package:tuchati/screens/page/progress/progress.dart';
import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/secure_storage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.phone, required this.uid});

  @override
  State<Profile> createState() => _ProfileState();
  final String phone;
  final String uid;
}

class _ProfileState extends State<Profile> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool attempt = false;
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                height: 400,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/background.png'),
                        fit: BoxFit.fill)),
                child: Stack(
                  children: <Widget>[
               
                    Positioned(
                      top: 80,
                      left: 20,
                      width: 80,
                      height: 180,
                      child: FadeAnimation(
                          1,
                          Container(
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-1.png'))),
                          )),
                    ),
                    Positioned(
                      left: 140,
                      width: 80,
                      height: 150,
                      top: 40,
                      child: FadeAnimation(
                          1.3,
                          Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/profile.png'))),
                          )),
                    ),
                    Positioned(
                      right: 30,
                      top: 80,
                      width: 80,
                      height: 140,
                      child: FadeAnimation(
                          1.5,
                          Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-2.png'))),
                          )),
                    ),
                    Positioned(
                      child: FadeAnimation(
                          1.6,
                          Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text(
                                "Tuchati",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeAnimation(
                        1.8,
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(143, 148, 251, .2),
                                    blurRadius: 20.0,
                                    offset: Offset(0, 10))
                              ]),
                          child: Form(
                            key: _formkey,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Let us know about you",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom:
                                              BorderSide(color: Colors.grey))),
                                  child: TextFormField(
                                    controller: firstname,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "please enter your first name";
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "First Name",
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400])),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: lastname,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Last Name (Optional)",
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400])),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    FadeAnimation(
                        2,
                        GestureDetector(
                          onTap: () {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                attempt = true;
                              });
                              if (lastname.text != '') {
                                saveData(
                                  firstname.text,
                                  lastname.text,
                                );
                              } else {
                                saveData(
                                  firstname.text,
                                  "",
                                );
                              }
                            }
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
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    )
                                  : Text(
                                      "Continue",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  void saveData(String text, String text2) async {
    //  String? notifyToken = await CloudMessaging().getMyToken();
    //  upload profile
    await Progresshud.initializeDialogue(context);
    await Progresshud.show("Registering user....");
    final ByteData bytes = await rootBundle.load('assets/images/profile.png');
    storage.UploadTask task;
    storage.Reference ref=storage.FirebaseStorage.instance.ref().child("UserProfiles").child("/${widget.uid}");
    task=ref.putData(bytes.buffer.asUint8List());
    task.whenComplete(()async {
    String url=await ref.getDownloadURL();
    List<String> userdata = [widget.uid, text, text2, widget.phone,"Hey there i'm using tuchati"];
    StorageItem item = StorageItem("user", userdata);
    SecureStorageService().writeSecureData(item);
    // ignore: use_build_context_synchronously
    bool result = await FirebaseService()
        .postUserData(widget.uid, text, text2, widget.phone, context,url);
    if (result) {
      setState(() {
        attempt = false;
      });
         await Progresshud.dismiss();
      // ignore: use_build_context_synchronously
      Navigator.popUntil(context, (route) => route.isFirst);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MainTabBar(),
      ));
     
    }
     });
   

  }
}
