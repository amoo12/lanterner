// import 'dart:convert';

import 'package:lanterner/models/user.dart';
//  import 'package:translator/translator.dart' as tr;

class Message {
  String messageId;
  String content;
  String type;
  String senderId;
  String peerId;
  String timeStamp;
  String translation;
  Message({
    this.messageId,
    this.content,
    this.type,
    this.senderId,
    this.peerId,
    this.timeStamp,
    this.translation,
  });

  String getChatroomId() {
    String user1 = this.senderId.substring(0, 5);
    String user2 = this.peerId.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();

    return '${list[0]}-${list[1]}';
  }

  @override
  String toString() {
    return 'Message(messageId: $messageId, content: $content, type: $type, senderId: $senderId, peerId: $peerId, timeStamp: $timeStamp)';
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'content': content,
      'type': type,
      'senderId': senderId,
      'peerId': peerId,
      'timeStamp': timeStamp,
      'translation': translation,
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
      translation: map['translation'],
    );
  }
}

// class Translation {
//   Language sourceLanguage;
//   Language targetLanguage;
//   String text;
//   Translation({this.sourceLanguage, this.targetLanguage, this.text});

//   Map<String, dynamic> toMap() {
//     return {
//       'sourceLanguage': sourceLanguage.toMap(),
//       'targetLanguage': targetLanguage.toMap(),
//       'text': text,
//     };
//   }

//   factory Translation.fromGoogleTranslation(tr.Translation translation) {
//     return Translation(
//       sourceLanguage: translation.sourceLanguage,
//       targetLanguage: translation.targetLanguage,
//       text: translation.text,
//     );
//   }

//   factory Translation.fromMap(Map<String, dynamic> map) {
//     return Translation(
//       sourceLanguage: Language.fromMap(map['sourceLanguage']),
//       targetLanguage: Language.fromMap(map['targetLanguage']),
//       text: map['text'],
//     );
//   }
// }
