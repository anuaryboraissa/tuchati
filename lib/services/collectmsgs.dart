import "dart:convert";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:http/http.dart" as http;

import "firebase.dart";

class CollectMessageData{
    storeMessage(String message,String created)async{
        String msgId=DateTime.now().microsecondsSinceEpoch.toString();
          while (await FirebaseService().checkIfMsgExist(msgId)) {
              msgId = DateTime.now().millisecondsSinceEpoch.toString();
            }
        final firebase =
        FirebaseFirestore.instance.collection("MLData").doc(msgId);

    final msg = {
      'msg_id': msgId,
      'msg': message,
      "created": created,
    };
    firebase.set(msg).whenComplete(() async {
      print(
          "this msg .................................${msg["msg"]} saved as MLData");
    });
    
  }
  Future<List> getMachineLearningData()async{
    String uri="https://v1.nocodeapi.com/mbaddy/fbsdk/SzvDUuvbwudDbsEf/firestore/allDocuments?collectionName=MLData";
    var response=await http.get(Uri.parse(uri));
     return jsonDecode(response.body);
  }
}