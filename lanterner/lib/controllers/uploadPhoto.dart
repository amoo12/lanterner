import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class UploadPhoto {
  PickedFile pickedFile;
  File file;
  ImagePicker _picker = ImagePicker();
  bool isUploading = false;
  String photoId = Uuid().v4();
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

  compressImage(String id) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$id.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    file = compressedImageFile;
  }

  // move to backend services
  Future<String> uploadImage({imageFile, String id, String folder}) async {
    firebase_storage.Reference ref =
        FirebaseStorage.instance.ref().child(folder);

    photoId = folder == 'chats' ? photoId : id;
    UploadTask uploadTask = ref.child("$photoId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap =
        await uploadTask.whenComplete(() => uploadTask.snapshot);
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    photoId = Uuid().v4();
    return downloadUrl;
  }
}
