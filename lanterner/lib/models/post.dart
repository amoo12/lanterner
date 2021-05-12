import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String postId;
  String photoUrl;
  String audioUrl;
  String userId;
  String username;
  String caption;

  Post({
    this.audioUrl,
    this.caption,
    this.photoUrl,
    this.postId,
    this.userId,
    this.username,
  });
  factory Post.fromMap(DocumentSnapshot doc) {
    Map data = doc.data();
    return Post(
        postId: doc.id,
        photoUrl: data['photoUrl'],
        audioUrl: data['audioUrl'],
        userId: data['userId'],
        username: data['username'],
        caption: data['caption']);
  }

  Map<String, dynamic> toMap(Post post) {
    return {
      'postId': post.postId,
      'photoUrl': post.photoUrl,
      'audioUrl': post.audioUrl,
      'userId': post.userId,
      'username': post.username,
      'caption': post.caption
    };
  }
}
