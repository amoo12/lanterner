import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanterner/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comment {
  String text;
  User user;
  String createdAt;

  Comment({
    this.text,
    this.user,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'user': user.toMap(),
      'createdAt': createdAt,
    };
  }

  factory Comment.fromMap(DocumentSnapshot doc) {
    Map data = doc.data();
    return Comment(
      text: data['text'],
      user: User.fromMap(data['user']),
      createdAt: data['createdAt'],
    );
  }

  String ago() {
    return timeago.format(DateTime.parse(this.createdAt));
  }
}
