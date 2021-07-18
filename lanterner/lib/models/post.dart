import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanterner/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post {
  String postId;
  String photoUrl;
  String audioUrl;
  String caption;
  String createdAt;
  Timestamp timestamp;
  int likeCount;
  int commmentCount;
  User user;
  Post({
    this.audioUrl,
    this.caption,
    this.photoUrl,
    this.postId,
    this.createdAt,
    this.timestamp,
    this.user,
    this.likeCount,
    this.commmentCount,
  });
  factory Post.fromMap(DocumentSnapshot doc) {
    Map data = doc.data();
    return Post(
      postId: doc.id,
      user: User.fromMap(data['user']),
      photoUrl: data['photoUrl'],
      audioUrl: data['audioUrl'],
      caption: data['caption'],
      createdAt: data['createdAt'],
      timestamp: data['timestamp'],
      likeCount: data['likeCount'] ?? 0,
      commmentCount: data['commmentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'user': user.toMap(),
      'photoUrl': photoUrl,
      'audioUrl': audioUrl,
      'caption': caption,
      'createdAt': createdAt,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'commmentCount': commmentCount,
    };
  }

  String ago() {
    return timeago.format(DateTime.parse(this.createdAt));
  }
}
