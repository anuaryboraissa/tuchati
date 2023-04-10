import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileShare {
  Future<PlatformFile?> uploadFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false,allowedExtensions: ["png","jpg","jpeg","pdf"],type: FileType.custom);
    if (result == null) return null;
    final file = result.files.first;
    //File file=result.files.single.path;
    //List<File> files=result.paths.map((path)=>File(path)).toList();
    // print("picked");
    return file;
  }
}
