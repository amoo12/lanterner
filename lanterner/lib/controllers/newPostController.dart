import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanterner/controllers/uploadPhoto.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:uuid/uuid.dart';

class NewPostController {
  String postId = Uuid().v4();
  UploadPhoto uploadPhoto = UploadPhoto();

  DatabaseService db = DatabaseService();

  TextEditingController captionController = TextEditingController();

  handleSubmit(String uid) async {
    User user = await db.getUser(uid);
    uploadPhoto.isUploading = true;
    String mediaUrl;
    if (uploadPhoto.file != null) {
      await uploadPhoto.compressImage(postId);
      mediaUrl = await uploadPhoto.uploadImage(
          imageFile: uploadPhoto.file, id: postId, folder: 'posts');
    }

    // TODO change to global (this returns a local date)
    DateTime createdAt = DateTime.now();
    Timestamp timestamp = Timestamp.fromDate(createdAt);

    await db.createPost(Post(
      postId: postId,
      photoUrl: mediaUrl,
      caption: captionController.text,
      user: user,
      createdAt: createdAt.toString(),
      timestamp: timestamp,
      likeCount: 0,
      commmentCount: 0,
    ));

    captionController.clear();

    uploadPhoto.clearImage();
    uploadPhoto.isUploading = false;
    postId = Uuid().v4();
  }
}
