class GroupMsgDetails{
  String name;
  int grpId;
  String lastMessage;
  String lastSender;
  String date;
  int unSeen;
  GroupMsgDetails({
    required this.name,required this.grpId,
    required this.lastMessage,required this.date,
    required this.lastSender,
    required this.unSeen,});
}