import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lanterner/models/user.dart';

class Activity {
  User user;
  String type; // follow | like | comment
  String postId;
  String message;
  String timestamp;
  bool seen;
  Activity({
    this.user,
    this.type,
    this.postId,
    this.message,
    this.timestamp,
    this.seen,
  });

  Map<String, dynamic> toMap() {
    return {
      'user': user.toMap(),
      'type': type,
      'postId': postId,
      'message': message,
      'timestamp': timestamp,
      'seen': seen,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      user: User.fromMap(map['user']),
      type: map['type'],
      postId: map['postId'],
      // message: map['message'] ?? null,
      timestamp: map['timestamp'].toString(),
      seen: map['seen'],
    );
  }

  @override
  String toString() {
    return 'Activity(user: $user, type: $type, postId: $postId, message: $message, timestamp: $timestamp)';
  }
}
