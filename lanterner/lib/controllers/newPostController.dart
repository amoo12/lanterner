import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:lanterner/controllers/uploadPhoto.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:uuid/uuid.dart';

class NewPostController {
  // PickedFile pickedFile;
  // File file;
  // ImagePicker _picker = ImagePicker();
  // bool isUploading = false;
  String postId = Uuid().v4();
  UploadPhoto uploadPhoto = UploadPhoto();

  DatabaseService db = DatabaseService();

  TextEditingController captionController = TextEditingController();

  // handleTakePhoto(BuildContext context) async {
  //   Navigator.pop(context);
  //   PickedFile pickedFile = await _picker.getImage(
  //     source: ImageSource.camera,
  //     maxHeight: 675,
  //     maxWidth: 960,
  //   );
  //   this.file = File(pickedFile.path);
  // }

  // handleChooseFromGallery(BuildContext context) async {
  //   Navigator.pop(context);
  //   PickedFile pickedFile = await _picker.getImage(source: ImageSource.gallery);
  //   this.file = File(pickedFile.path);
  // }

  // clearImage() {
  //   file = null;
  // }

  handleSubmit(String uid) async {
    User user = await db.getUser(uid);
    uploadPhoto.isUploading = true;
    String mediaUrl;
    if (uploadPhoto.file != null) {
      await uploadPhoto.compressImage(postId);
      mediaUrl = await uploadPhoto.uploadImage(uploadPhoto.file, postId);
    }

    // TODO change to global (this returns a local date)
    DateTime createdAt = DateTime.now();
    Timestamp timestamp = Timestamp.fromDate(createdAt);

    await db.createPost(Post(
      postId: postId,
      photoUrl: mediaUrl,
      caption: captionController.text,
      user: user,
      // username: user.name,
      // ownerId: user.uid,
      // userPhotoUrl: user.photoUrl,
      createdAt: createdAt.toString(),
      // ownerNativeLanguage: user.nativeLanguage,
      timestamp: timestamp,
    ));

    captionController.clear();

    uploadPhoto.clearImage();
    // file = null;
    uploadPhoto.isUploading = false;
    postId = Uuid().v4();
  }

  // compressImage() async {
  //   final tempDir = await getTemporaryDirectory();
  //   final path = tempDir.path;
  //   Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
  //   final compressedImageFile = File('$path/img_$postId.jpg')
  //     ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
  //   file = compressedImageFile;
  // }

  // move to backend services
  // Future<String> uploadImage(imageFile) async {
  //   // firebase_storage.FirebaseStorage.instance =
  //   // firebase_storage.FirebaseStorage.instance();
  //   firebase_storage.Reference ref = FirebaseStorage.instance
  //       .ref()
  //       .child('playground')
  //       .child('/some-image.jpg');
  //   UploadTask uploadTask = ref.child("post_$postId.jpg").putFile(imageFile); //!
  //   TaskSnapshot storageSnap =
  //       await uploadTask.whenComplete(() => uploadTask.snapshot);
  //   String downloadUrl = await storageSnap.ref.getDownloadURL();
  //   return downloadUrl;
  // }
}
