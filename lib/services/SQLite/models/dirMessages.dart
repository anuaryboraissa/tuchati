// ignore: file_names
class DirectMessage{
   int msgId;
   String fileName;
   String fileSize;
   String msg;
   String msgFile;
   String receiver;
   String replied;
   String repliedMsgId;
   String seen;
   String sender;
   String time;
   String date;
    DirectMessage({required this.msgId,required this.msg,
    required this.sender,required this.receiver,
    required this.replied,required this.repliedMsgId,
    required this.seen,required this.time,required this.date,
    required this.fileName,
    required this.msgFile,required this.fileSize
    });

}