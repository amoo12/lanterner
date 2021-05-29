import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanterner/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class Post {
  String postId;
  String photoUrl;
  String audioUrl;
  // String ownerId;
  // String username;
  // String userPhotoUrl;
  String caption;
  String createdAt;
  // Language ownerNativeLanguage;
  Timestamp timestamp;
  User user;
  Post({
    this.audioUrl,
    this.caption,
    this.photoUrl,
    this.postId,
    // this.ownerId,
    // this.username,
    // this.userPhotoUrl,
    this.createdAt,
    // this.ownerNativeLanguage,
    this.timestamp,
    this.user,
  });
  factory Post.fromMap(DocumentSnapshot doc) {
    Map data = doc.data();
    return Post(
      postId: doc.id,
      user: User.fromMap(data['user']),
      photoUrl: data['photoUrl'],
      audioUrl: data['audioUrl'],
      // ownerId: data['ownerId'],
      // username: data['username'],
      // userPhotoUrl: data['userPhotoUrl'],
      caption: data['caption'],
      createdAt: data['createdAt'],
      timestamp: data['timestamp'],
      // ownerNativeLanguage: Language.fromMap(
      //   data['ownerNativeLanguage'],
      // ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'user': user.toMap(),
      'photoUrl': photoUrl,
      'audioUrl': audioUrl,
      // 'ownerId': ownerId,
      // 'username': username,
      // 'userPhotoUrl': userPhotoUrl,
      'caption': caption,
      'createdAt': createdAt,
      'timestamp': timestamp,
      // 'ownerNativeLanguage': ownerNativeLanguage.toMap(),
    };
  }

  String ago() {
    return timeago.format(DateTime.parse(this.createdAt));
  }
}
