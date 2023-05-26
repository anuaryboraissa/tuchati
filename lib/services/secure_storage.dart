import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _secureStorage = const FlutterSecureStorage();
  //write data
  Future<void> writeSecureData(StorageItem item) async {
    await _secureStorage.write(
        key: item.key,
        value: jsonEncode(item.value),
        aOptions: _getAndroidOptions());
  }

  Future<void> writeMsgData(Message message) async {
    await _secureStorage.write(
        key: message.key,
        value: jsonEncode(message.value),
        aOptions: _getAndroidOptions());
  }

  

  Future<void> writeUserSentToMe(Userr user) async {
    await _secureStorage.write(
        key: user.key,
        value: jsonEncode(user.value),
        aOptions: _getAndroidOptions());
  }

  Future<void> writeContactsData(Contactt contact) async {
    await _secureStorage.write(
        key: contact.key,
        value: jsonEncode(contact.value),
        aOptions: _getAndroidOptions());
  }

  ///simplified modal data
  Future<void> writeModalData(Modal modal) async {
    await _secureStorage.write(
        key: modal.key,
        value: jsonEncode(modal.value),
        aOptions: _getAndroidOptions());
  }

  Future<List> readModalData(String key) async {
    var data =
        await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
    if (data == null) {
      return [];
    }
    return jsonDecode(data);
  }
  Future<List> readCntactsData(String key) async {
    var data =
        await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
    if (data == null) {
      return [];
    }
    List mydata = jsonDecode(data);
    return mydata;
  }

  Future<List<dynamic>> readByKeyData(String key) async {

    var data =
        await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
     if(data==null){
      return [];
     }
    return jsonDecode(data);
  }

  Future<List> readMsgData(String key, String sender, String receiver) async {
    var data =
        await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
    if (data == null) {
      return [];
    }
    var newdata = [];
    var datanew = jsonDecode(data);
    for (var d = 0; d < datanew.length; d++) {
      if ((datanew[d][2] == sender || datanew[d][2] == receiver) &&
          (datanew[d][3] == receiver || datanew[d][3] == sender)) {
        newdata.add(datanew[d]);
      }
    }

    return newdata;
  }
  Future<List> readGrpMsgData(String key,String grpId) async {
    var data =
        await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
    if (data == null) {
      return [];
    }
    var newdata = [];
    var datanew = jsonDecode(data);
    for (var d = 0; d < datanew.length; d++) {
      if(datanew[d][5]==grpId){
       newdata.add(datanew[d]);
      }
    
    }

    return newdata;
  }

  Future<List> readUsersSentToMe(String key) async {
    var data =
        await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
    if (data == null) {
      return [];
    }

    return jsonDecode(data);
  }


  Future<List> readAllMsgData(String key) async {
    var data =
        await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
    if (data == null) {
      return [];
    }

    return jsonDecode(data);
  }

  Future<void> writeKeyValueData(String key, String item) async {
    await _secureStorage.write(
        key: key, value: item, aOptions: _getAndroidOptions());
  }

  //read by key
  Future<String?> readSecureData(String key) async {
    var readData =
        await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
    return readData;
  }
  //delete by key
  Future<void> deleteSecureData(StorageItem item) async {
    await _secureStorage.delete(key: item.key, aOptions: _getAndroidOptions());
  }

  Future<void> deleteByKeySecureData(String key) async {
    await _secureStorage.delete(key: key, aOptions: _getAndroidOptions());
    // print(
    //     "deleted......................................................... $key");
  }

  //checkif key exists
  Future<bool> containsKey(String key) async {
    bool containKey = await _secureStorage.containsKey(
        key: key, aOptions: _getAndroidOptions());
    return containKey;
  }

//read all data
  Future<List<StorageItem>> readAllData() async {

    var allData = await _secureStorage.readAll(aOptions: _getAndroidOptions());
    List<StorageItem> list = allData.entries
        .map((e) => StorageItem(e.key, jsonDecode(e.value)))
        .toList();

    return list;
  }

  //delete all data
  Future<void> deleteAllData() async {
    await _secureStorage.deleteAll(aOptions: _getAndroidOptions());
  }

  AndroidOptions _getAndroidOptions() {
    return const AndroidOptions(encryptedSharedPreferences: true);
  }
}

class StorageItem {
  final String key;
  final List value;

  StorageItem(this.key, this.value);
}

class Message {
  final String key;
  final List value;

  Message(this.key, this.value);
}

class Userr {
  final String key;
  final List value;

  Userr(this.key, this.value);
}

class Contactt {
  final String key;
  final List value;

  Contactt(this.key, this.value);
}

class Modal {
  final String key;
  final List value;

  Modal(this.key, this.value);
}
