import 'package:tuchati/services/firebase.dart';
import 'package:tuchati/services/secure_storage.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class MyContacts {
  //make back ground task work manager
  Future<void> phoneContacts() async {
    print(await SecureStorageService().readSecureData("loaded"));
    if (await FlutterContacts.requestPermission()) {
      print("imeingia contacts");
      List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true, withAccounts: true, withPhoto: true);

List<dynamic> logged = await SecureStorageService().readByKeyData("user");
if(logged.isNotEmpty){
  String logedUser=logged[3];
  contacts.forEach((element) async {
         List savedContacts =
          await SecureStorageService().readCntactsData("contacts");
        String phone = '';
        if (element.phones[0].number.toString().startsWith("0")) {
          phone = element.phones[0].number.toString().replaceFirst("0", "+255");
        } else {
          phone = element.phones[0].number;
        }
          List phoneName = [];

        bool contains =
            await SecureStorageService().containsKey(phone.replaceAll(" ", ""));
         
        if (contains && phone.replaceAll(" ", "")!=logedUser) {
             print("After compare hii contacts................${phone.replaceAll(" ", "")} and       $logedUser and contains $contains");
          bool isEmptyy=false;
          bool ckecker=false;
          phoneName.add(phone);
          phoneName.add(element.displayName);
          phoneName.add("Hey there im using Tuchati");
          if (savedContacts.isEmpty) {
            
            savedContacts.add(phoneName);
            isEmptyy=true;
              Contactt contactt = Contactt("contacts", savedContacts);
          await SecureStorageService().writeContactsData(contactt);
          } else {
      
            for (var cont = 0; cont < savedContacts.length; cont++) {
             
              if (phone == savedContacts[cont][0]) {
                ckecker=true;
              }
            }
          }
          if (!ckecker && !isEmptyy) {
            savedContacts.add(phoneName);
           Contactt contactt = Contactt("contacts", savedContacts);
          await SecureStorageService().writeContactsData(contactt);
          }
         
        }
      });

      await FirebaseService().storeFirebaseUsersInLocal();
}
     
      
    }
  }
}
