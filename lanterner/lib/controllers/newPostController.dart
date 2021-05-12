import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;

class NewPostController {
  PickedFile pickedFile;
  File file;
  ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  String postId = Uuid().v4();

  DatabaseService db = DatabaseService();

  TextEditingController captionController = TextEditingController();

  handleTakePhoto(BuildContext context) async {
    Navigator.pop(context);
    PickedFile pickedFile = await _picker.getImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    this.file = File(pickedFile.path);
  }

  handleChooseFromGallery(BuildContext context) async {
    Navigator.pop(context);
    PickedFile pickedFile = await _picker.getImage(source: ImageSource.gallery);
    this.file = File(pickedFile.path);
  }

  clearImage() {
    file = null;
  }

  handleSubmit() async {
    isUploading = true;

    await compressImage();
    String mediaUrl = await uploadImage(file);
    // createPostInFirestore(
    //   mediaUrl: mediaUrl,
    //   location: locationController.text,
    //   description: captionController.text,
    // );

    db.createPost(Post(
        postId: postId, photoUrl: mediaUrl, caption: captionController.text));

    captionController.clear();
    // locationController.clear();
    file = null;
    isUploading = false;
    postId = Uuid().v4();
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    file = compressedImageFile;
  }

  // move to backend services
  Future<String> uploadImage(imageFile) async {
    // firebase_storage.FirebaseStorage.instance =
    // firebase_storage.FirebaseStorage.instance();
    firebase_storage.Reference ref = FirebaseStorage.instance
        .ref()
        .child('playground')
        .child('/some-image.jpg');
    UploadTask uploadTask = ref.child("post_$postId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap =
        await uploadTask.whenComplete(() => uploadTask.snapshot);
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }
}
