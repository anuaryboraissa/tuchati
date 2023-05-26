// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tuchati/constants/app_colors.dart';

import '../../../recording/src/widgets/audio_bubble.dart';
import '../custom_tabbar.dart';

class MyTabBar extends StatefulWidget {
  const MyTabBar({
    Key? key,
    required this.images,
    required this.docs,
    required this.voices,
    required this.groupName,
  }) : super(key: key);
  final List images;
  final List docs;
  final List voices;
  final String groupName;
  @override
  State<MyTabBar> createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar> {
  late Box<String> voicePaths;
  late Box<Uint8List> msgFiles;
  String path = "";
  initializeExternalDir(String dir) {
    
    getExternalStorageDirectory().then((value) {
      io.Directory("${value!.path}/$dir").createSync(recursive: true);
    });
  }

  getDefaultPath() async {
    getExternalStorageDirectory().then((value) {
      setState(() {
        path = value!.path;
      });
    });
  }

  saveFileInExternalStorage(
      String fileName, String msgId, String fileType) async {
    if (!io.File("$path/VoiceNotes").existsSync()) {
      initializeExternalDir("VoiceNotes");
    }
    if (!io.File("$path/Documents").existsSync()) {
      initializeExternalDir("Documents");
    }
    if (!io.File("$path/Images").existsSync()) {
      initializeExternalDir("Images");
    }

    String filePath = "$path/$fileName";
    final file = io.File(filePath);
    if (fileType == "v") {
      // print("going to write audio.........");
      //create dir

      final dirFile = io.File(voicePaths.get(msgId)!);
      if (await dirFile.exists()) {
        final bytes = dirFile.readAsBytesSync().hashCode;
        file.writeAsBytes(dirFile.readAsBytesSync()).then((value) {
          // print(
          //     "progress of file now.............${file.readAsBytesSync().hashCode} compare with $bytes");
        }).whenComplete(() {
          // print("file uploadd successfully");
        });
      }
    } else {
      // print("going to write $fileType.........");
      file.writeAsBytesSync(msgFiles.get(msgId)!);
    }
  }

  @override
  void initState() {
    getDefaultPath();
    voicePaths = Hive.box<String>("voice");
    msgFiles = Hive.box<Uint8List>("messagesFiles");
    super.initState();
  }

  TabBarLocation _tabBarLocation = TabBarLocation.top;
  final List<String> tabBarItems = [
    "Documents",
    "Images",
    "Voice",
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabViewItems = [
      DocumentsListView(
        docs: widget.docs,
        msgFiles: msgFiles,
        path: path,
        saveFile: saveFileInExternalStorage,
      ),
      ImagesListView(
        images: widget.images,
        msgFiles: msgFiles,
        path: path,
        saveFile: saveFileInExternalStorage,
      ),
      VoicesListView(
          voices: widget.voices,
          voicePaths: voicePaths,
          path: path,
          saveFile: saveFileInExternalStorage)
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.groupName),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Colors.white,
            )),
        backgroundColor: AppColors.appColor,
        elevation: 0,
        actions: [_appBarActionButton()],
      ),
      body: Column(
        children: [
          CustomTabBar(
            tabBarItems: tabBarItems,
            tabViewItems: tabViewItems,
            tabBarLocation: _tabBarLocation,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            tabBarItemHeight: MediaQuery.of(context).size.height * 0.08,
            tabViewItemHeight: MediaQuery.of(context).size.height * 0.75,
          )
        ],
      ),
    );
  }

  IconButton _appBarActionButton() {
    return IconButton(
        onPressed: () {
          setState(() {
            if (_tabBarLocation == TabBarLocation.top) {
              setState(() {
                _tabBarLocation = TabBarLocation.bottom;
              });
            } else {
              setState(() {
                _tabBarLocation = TabBarLocation.top;
              });
            }
          });
        },
        icon: AnimatedCrossFade(
            firstChild: const Icon(Icons.arrow_circle_down_outlined),
            secondChild: const Icon(Icons.arrow_circle_up_outlined),
            crossFadeState: _tabBarLocation == TabBarLocation.top
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200)));
  }
}

class DocumentsListView extends StatelessWidget {
  const DocumentsListView({
    Key? key,
    required this.docs,
    required this.saveFile,
    required this.path,
    required this.msgFiles,
  }) : super(key: key);
  final List docs;
  final Function(String fileName, String msgId, String type) saveFile;
  final String path;
  final Box<Uint8List> msgFiles;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        List mySms = docs[index];
        final mb = int.parse(mySms[9]) / (1024);
        String size = "${mb.round().toString()} MB";
        if (mb > 1024) {
          size = "${(mb / 1024).toStringAsFixed(2).toString()} GB";
        }
        return SizedBox(
          child: ListTile(
            trailing: Padding(
                padding: const EdgeInsets.all(5),
                child: !io.File("$path/Documents/${mySms[8]}").existsSync()
                    ? IconButton(
                        onPressed: () {
                          saveFile("Documents/${mySms[8]}", mySms[0], "d");
                        },
                        icon: Icon(
                          Icons.download,
                          color: AppColors.appColor,
                          size: 20,
                        ))
                    : Icon(
                        Icons.check,
                        size: 20,
                        color: AppColors.appColor,
                      )),
            leading: Container(
              width: 55,
              height: 55,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: PDFView(
                pdfData: msgFiles.get(mySms[0])!,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: false,
                pageFling: false,
              ),
            ),
            title: Text(mySms[8]),
            subtitle: Text(
              size,
              maxLines: 2,
            ),
          ),
        );
      },
    );
  }
}

class ImagesListView extends StatelessWidget {
  const ImagesListView({
    Key? key,
    required this.images,
    required this.path,
    required this.saveFile,
    required this.msgFiles,
  }) : super(key: key);
  final List images;
  final String path;
  final Function(String fileName, String msgId, String type) saveFile;
  final Box<Uint8List> msgFiles;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: images.length,
      itemBuilder: (context, index) {
        List mySms = images[index];
        final kb = int.parse(mySms[9]) / (1024);
        String size = "${kb.round().toString()} KB";
        if (kb > 1024) {
          size = "${(kb / 1024).toStringAsFixed(2).toString()} MB";
        }
        return ListTile(
          trailing: Column(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: !io.File("$path/Images/${mySms[8]}").existsSync()
                    ? IconButton(
                        onPressed: () {
                          saveFile("Images/${mySms[8]}", mySms[0], "i");
                        },
                        icon: Icon(
                          Icons.download,
                          color: AppColors.appColor,
                          size: 20,
                        ))
                    : Icon(
                        Icons.check,
                        size: 20,
                        color: AppColors.appColor,
                      ),
              ),
            )
          ]),
          leading: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: MemoryImage(msgFiles.get(mySms[0])!),
                  fit: BoxFit.fill),
              shape: BoxShape.circle,
            ),
          ),
          title: Text(mySms[8]),
          subtitle: Text(
            size,
            maxLines: 2,
          ),
        );
      },
    );
  }
}

class VoicesListView extends StatelessWidget {
  const VoicesListView({
    Key? key,
    required this.voices,
    required this.path,
    required this.voicePaths,
    required this.saveFile,
  }) : super(key: key);
  final List voices;
  final String path;
  final Box<String> voicePaths;
  final Function(String fileName, String msgId, String type) saveFile;
  
  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      itemCount: voices.length,
      itemBuilder: (context, index) {
        List mySms = voices[index];
        return ListTile(
          trailing: Padding(
            padding: const EdgeInsets.all(5),
            child: !io.File("$path/VoiceNotes/${mySms[8]}").existsSync()
                ? IconButton(
                    onPressed: () {
                      saveFile("VoiceNotes/${mySms[8]}", mySms[0], "v");
                    },
                    icon: Icon(
                      Icons.download,
                      color: AppColors.appColor,
                      size: 20,
                    ))
                : Icon(
                    Icons.check,
                    size: 20,
                    color: AppColors.appColor,
                  ),
          ),
          leading: Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.music_note_outlined,
              color: AppColors.appColor,
            ),
          ),
          title: Text(mySms[8]),
          subtitle: AudioBubble(
            filepath: voicePaths.get(mySms[0])!,
          ),
        );
      },
    );
  }
}
