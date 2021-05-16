import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanterner/models/user.dart';

class Post {
  String postId;
  String photoUrl;
  String audioUrl;
  String ownerId;
  String username;
  String userPhotoUrl;
  String caption;
  Language ownerNativeLanguage;
  Timestamp timestamp;

  Post({
    this.audioUrl,
    this.caption,
    this.photoUrl,
    this.postId,
    this.ownerId,
    this.username,
    this.userPhotoUrl,
    this.ownerNativeLanguage,
    this.timestamp,
  });
  factory Post.fromMap(DocumentSnapshot doc) {
    Map data = doc.data();
    return Post(
      postId: doc.id,
      photoUrl: data['photoUrl'],
      audioUrl: data['audioUrl'],
      ownerId: data['ownerId'],
      username: data['username'],
      userPhotoUrl: data['userPhotoUrl'],
      caption: data['caption'],
      timestamp: data['timestamp'],
      ownerNativeLanguage: Language.fromMap(
        data['ownerNativeLanguage'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'photoUrl': photoUrl,
      'audioUrl': audioUrl,
      'ownerId': ownerId,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
      'caption': caption,
      'timestamp': timestamp,
      'ownerNativeLanguage': ownerNativeLanguage.toMap(),
    };
  }
}
