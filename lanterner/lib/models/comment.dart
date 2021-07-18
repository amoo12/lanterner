import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanterner/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comment {
  String cid;
  String postId;
  String text;
  User user;
  String createdAt;
  Timestamp timestamp;

  Comment({
    this.cid,
    this.postId,
    this.text,
    this.user,
    this.createdAt,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'cid': cid,
      'postId': postId,
      'text': text,
      'user': user.toMap(),
      'createdAt': createdAt,
      'timestamp': timestamp,
    };
  }

  factory Comment.fromMap(DocumentSnapshot doc) {
    Map data = doc.data();
    return Comment(
      cid: doc.id,
      postId: data['postId'],
      text: data['text'],
      user: User.fromMap(data['user']),
      createdAt: data['createdAt'],
      timestamp: data['timestamp'],
    );
  }

  String ago() {
    return timeago.format(DateTime.parse(this.createdAt), locale: 'en_short');
  }
}
