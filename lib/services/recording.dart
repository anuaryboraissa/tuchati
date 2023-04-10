// import 'dart:io';
import 'dart:io';
// import "package:flutter_sound_lite/flutter_sound.dart";
// import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:chat/services/secure_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
// import 'package:hive/hive.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';

// class AudioRecord{
//     late FlutterAudioRecorder2 audioRecorder ;
//   bool isNumeric(String s) {
//     // ignore: unnecessary_null_comparison
//     if (s == null) {
//       return false;
//     }
//     return double.tryParse(s) != null;
//   }

//     Future<void> recordVoice(message) async {
//     final hasPermission = await FlutterAudioRecorder2.hasPermissions;
//     if (hasPermission ?? false) {
//       await _initRecorder(message);

//       await _startRecording();

//     } else {
//     print("record permisiion..............");
//     }
//   }
//     _initRecorder(message) async {
//     Directory appDirectory = await getApplicationDocumentsDirectory();
//     String filePath = '${appDirectory.path}/$message.wav';

//     //  var dataOffset = 74; // parse the WAV header or determine from a hex dump
//     //  var shorts = bytes.buffer.asInt16List(dataOffset);

//     Box<String> audioPath=Hive.box<String>("voiceNotesPaths");

//     audioPath.put(message, filePath);
//      audioRecorder =
//         FlutterAudioRecorder2(filePath, audioFormat: AudioFormat.WAV);
//     await audioRecorder.initialized;
//   }

//   _startRecording() async {
//     await audioRecorder.start();
//     // await audioRecorder.current(channel: 0);
//   }

//   stopRecording(message,receiver) async {
//     await audioRecorder.stop();

//     //sendMessage
//     sendVoiceMessage(message,receiver);

//   }
//   sendVoiceMessage(message,receiver)async{
//   Box<String> audioPaths=Hive.box<String>("voiceNotesPaths");
//   String? audioPath=audioPaths.get(message);
//   if(audioPath!=null){
//       Box<Uint8List> audio=Hive.box<Uint8List>("voiceNotes");
//        File file=File(audioPath);
//         Uint8List bytes=file.readAsBytesSync();
//         audio.put(message, bytes);

//        //
//        //
//         List<dynamic> logged = await SecureStorageService().readByKeyData("user");

//         DateFormat format = DateFormat("yyyy-MM-dd HH:mm");
//          var nowDate = format.format(DateTime.now());
//         var now = DateFormat.Hm().format(DateTime.now());
//         if(isNumeric(receiver)){
//           //grp
//         }
//         else{
//           sendDirectMessage(message, receiver, logged[0],nowDate,now);
//         }

//   }

//   }
//  sendDirectMessage(msg,receiver,sender,nowDate,now)async{
//  List attributes = [
//       msg,
//       "",
//       sender,
//       receiver,
//       "",
//       "0",
//       nowDate,
//       now,
//     ];
//     // if (myfile != null && fileBytes != null) {
//     //   Box<Uint8List> msgFiles = Hive.box<Uint8List>("messagesFiles");
//     //   msgFiles.put(msgId, fileBytes!);

//     //   attributes.add(filename);
//     //   attributes.add(fileSize.toString());
//     // } else {
//     //   attributes.add("0");
//     //   attributes.add("0");
//     // }
//     // attributes.add(repliedMsgId);
//  }
//  timerCounter(){

//  }
// }

class SoundRecorder {
  // bool isInit=false;
  // FlutterSoundRecorder? _audiorecorder;
  // Future record(messsage)async{
  //        Directory? appDirectory = await getExternalStorageDirectory();
  //   String filePath = '${appDirectory!.path}/$messsage.wav';
  //   await _audiorecorder!.startRecorder(toFile: filePath);

  // }
  //   Future stop()async{
  //   await _audiorecorder!.stopRecorder();

  // }
  //    Future toggleRecord(path)async{
  //   // await init();
  //   if(_audiorecorder!.isStopped){
  //     await record(path);
  //   }
  //   else{
  //     await stop();
  //   }

  // }
  //   Future init()async{
  //   _audiorecorder=FlutterSoundRecorder();
  //   // if(PermissionStatus.gr)
  //   final status=Permission.microphone.request();
  //   // ignore: unrelated_type_equality_checks
  //   if(status != PermissionStatus.granted){
  //     throw RecordingPermissionException("microphone permission required");
  //   }
  //   await _audiorecorder!.openAudioSession();
  //   isInit=true;
  // }
  // Future dispose()async{
  //    _audiorecorder!.closeAudioSession();
  //    _audiorecorder=null;
  //    isInit=false;
  // }

  // FlutterSoundRecorder? _myrecorder;

  Future<bool> openSessionRecorder() async {
    // _myrecorder = FlutterSoundRecorder();
    // bool result = await _myrecorder!.openAudioSession().then((value) {
    //   return true;
    // });
    return false;
  }

  disposeSession() {
    // _myrecorder!.closeAudioSession();
    // _myrecorder = null;
  }

  Future startRecord(message) async {
    // Directory? directory = await getExternalStorageDirectory();
    // String filePath = "${directory!.path}/$message.aac";
    // await _myrecorder!.startRecorder(toFile: filePath, codec: Codec.aacADTS);
  }

  Future stopRecord() async {
    // await _myrecorder!.stopRecorder();
    // disposeSession();
  }
}

class PlaySound{
  
}
