import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanterner/models/user.dart';

class Post {
  String postId;
  String photoUrl;
  String audioUrl;
  String ownerId;
  String username;
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
      caption: data['caption'],
      timestamp: data['timestamp'],
      ownerNativeLanguage: Language.fromMap(
        data['ownerNativeLanguage'],
      ),
    );
  }

  Map<String, dynamic> toMap(Post post) {
    return {
      'postId': post.postId,
      'photoUrl': post.photoUrl,
      'audioUrl': post.audioUrl,
      'ownerId': post.ownerId,
      'username': post.username,
      'caption': post.caption,
      'timestamp': post.timestamp,
      'ownerNativeLanguage':
          post.ownerNativeLanguage.toMap(post.ownerNativeLanguage),
    };
  }
}
