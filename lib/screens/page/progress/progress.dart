import 'package:flutter/material.dart';
// import 'package:progress_dialog/progress_dialog.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

class Progresshud {
  static late SimpleFontelicoProgressDialog _dialog;

  static initializeDialogue(context) {
    _dialog=SimpleFontelicoProgressDialog(context: context);
    // print("dialogue initialized...............");
  }

  static Future<void> show(String message) async {
    _dialog.show(message: message, type: SimpleFontelicoProgressDialogType.threelines);
  }


   static Future<void> dismiss() async {
       _dialog.hide();
  }
  static Future<void> mySnackBar(context,String message)async{
    ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(message),
              duration: const Duration(milliseconds: 1500),
              width: 280.0,
              behavior: SnackBarBehavior.floating,
            ),
          );
  }

}
