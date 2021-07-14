import 'package:lanterner/models/message.dart';

class Chat {
  String peerId;
  Message lastMessage;
  String username;
  String photoUrl;
  Chat({
    this.peerId,
    this.lastMessage,
    this.username,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'peerId': peerId,
      'lastMessage': lastMessage.toMap(),
      'username': username,
      'photoUrl': photoUrl,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      peerId: map['peerId'],
      lastMessage: Message.fromMap(map['lastMessage']),
      username: map['username'],
      photoUrl: map['photoUrl'],
    );
  }
}
