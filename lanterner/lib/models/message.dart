import 'dart:convert';

class Message {
  String messageId;
  String content;
  String type;
  String senderId;
  String peerId;
  String timeStamp;

  Message({
    this.messageId,
    this.content,
    this.type,
    this.senderId,
    this.peerId,
    this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'content': content,
      'type': type,
      'senderId': senderId,
      'peerId': peerId,
      'timeStamp': timeStamp,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'],
      content: map['content'],
      type: map['type'],
      senderId: map['senderId'],
      peerId: map['peerId'],
      timeStamp: map['timeStamp'],
    );
  }

  String getChatroomId() {
    String user1 = this.senderId.substring(0, 5);
    String user2 = this.peerId.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();

    // cprint(_channelName); //2RhfE-5kyFB
    return '${list[0]}-${list[1]}';
  }

  @override
  String toString() {
    return 'Message(messageId: $messageId, content: $content, type: $type, senderId: $senderId, peerId: $peerId, timeStamp: $timeStamp)';
  }
}
