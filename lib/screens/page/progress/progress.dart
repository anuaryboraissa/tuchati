import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Progresshud {
  static late ProgressDialog dialog;

  static Future<void> initializeDialogue(context) async {
    dialog =ProgressDialog(context,type: ProgressDialogType.Normal);
  }

  static Future<void> show(String message) async {
    dialog.show();
  }
 static Future<void> updateMessage(String message) async {
  if(await isShowing()){
     dialog.update(message: message);
  }
  }
  static Future<bool> isShowing() async {
    return dialog.isShowing();
  }

   static Future<void> dismiss() async {
          dialog.hide();
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