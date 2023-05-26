// ignore: file_names
class GroupMessage{
   int msgId;
   String fileName;
   String fileSize;
   String msg;
   String msgFile;
   String replied;
   String repliedMsgId;
   String repliedMsgSender;
   String sender;
   String date;
   String grpId;
    GroupMessage({required this.msgId,required this.msg,
    required this.sender,
    required this.replied,required this.repliedMsgId,
    required this.repliedMsgSender,required this.date,
    required this.fileName,
    required this.msgFile,required this.fileSize,required this.grpId
    });

}