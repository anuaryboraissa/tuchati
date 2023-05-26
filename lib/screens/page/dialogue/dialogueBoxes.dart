import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogueBox{
    static Future showInOutDailog({
    required BuildContext context,
    required Widget yourWidget,
    Widget? icon,
    Widget? title,
    required Widget firstButton,
    Widget? secondButton,
  }) {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.7),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.fastOutSlowIn.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: title,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if(icon!=null)
                     icon,
                    Container(
                      height: 10,
                    ),
                    yourWidget
                  ],
                ),
                actions: <Widget>[firstButton, if(secondButton!=null)secondButton],
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return const Text("data");
        });
  }
   Widget successWiget(message){
  return Column(children: [
    Padding(padding: const EdgeInsets.all(10),child: Text(message),),
  ],);
 }
}