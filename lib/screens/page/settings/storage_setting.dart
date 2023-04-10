import 'package:tuchati/constants/app_colors.dart';
import 'package:tuchati/screens/Animation/FadeAnimation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StorageSetting extends StatefulWidget {
  const StorageSetting({super.key});

  @override
  State<StorageSetting> createState() => _StorageSettingState();
}

class _StorageSettingState extends State<StorageSetting> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 150,
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
                  left: 130,
                  top: 50,
                  width: 200,
                  height: 150,
                  child: FadeAnimation(
                      1.5,
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Storage",
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
            child: ListView(
              children: [
                   Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "common",
                        style: AppColors.headingStyle,
                      ),
                    ],
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.storage),
                  title: Text("Manage Storage"),
                  subtitle: Text("total MB"),
                 
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Media auto-download",
                        style: AppColors.headingStyle,
                      ),
                    ],
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.music_note_outlined),
                  title: Text("When using mobile data"),
                  subtitle: Text("none"),
                 
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.vibration),
                  title: Text("When connected on wifi"),
                  subtitle: Text("none"),
                 
                ),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Media upload quality", style: AppColors.headingStyle),
                    ],
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.music_note_outlined),
                  title: Text("Photo upload quality"),
                  subtitle: Text("best quality"),
               
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
