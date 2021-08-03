import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/controllers/newPostController.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/widgets/customTextField.dart';
import 'dart:math' as math;

import 'package:lanterner/widgets/progressIndicator.dart';

class NewPost extends StatefulWidget {
  NewPost({Key key}) : super(key: key);

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  NewPostController postController = NewPostController();
  String uid;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final _authState = watch(authStateProvider);
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('New post'),
          actions: [
            IconButton(
              onPressed: () async {
                if (postController.captionController.text.trim().isNotEmpty ||
                    postController.uploadPhoto.file != null) {
                  customProgressIdicator(context);

                  await postController.handleSubmit(_authState.data.value.uid);
                  setState(() {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                } else {
                  // TODO change to snackbar or other type of alerts
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Center(
                          child: Container(
                              child: Text('Say something or add a photo')),
                        );
                      });
                }
              },
              icon: Icon(
                Icons.send,
              ),
            )
          ],
          elevation: 0,
          leading: Transform.rotate(
            angle: 45 * math.pi / 180,
            child: IconButton(
              icon: Icon(
                Icons.add,
                size: 30,
              ),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                await Future.delayed(Duration(milliseconds: 150));

                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                // height: 200,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: TextFormFieldWidget(
                        controller: postController.captionController,
                        bottomBorder: false,
                        hintText: 'Say something...',
                        expands: true,
                        autofocus: true,
                        isMultiline: true,
                      ),
                    ),
                    postController.uploadPhoto.file == null
                        ? Container(
                            height: 0.0,
                          )
                        : Container(
                            // alignment: Alignment.centerLeft,
                            height: 175.0,
                            width: 175.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: Theme.of(context).accentColor,
                                  width: 0.5,
                                )),
                            // width: MediaQuery.of(context).size.width * 0.8,
                            child: Stack(
                              children: <Widget>[
                                Center(
                                  child: Container(
                                    height: 170.0,
                                    width: 170.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                            postController.uploadPhoto.file),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    color: Colors.grey[50].withOpacity(0.8),
                                    icon: Icon(Icons.cancel),
                                    onPressed: () {
                                      setState(() {
                                        postController.uploadPhoto.clearImage();
                                      });
                                    })
                              ],
                            ),
                          ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade800,
                        width: 1,
                      ),
                    ),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[900],
                        blurRadius: 0.5,
                        spreadRadius: 0.5,
                      ),
                    ]),
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.photo_outlined),
                          color: Colors.grey[400],
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  title: Text("Add a photo"),
                                  children: <Widget>[
                                    SimpleDialogOption(
                                        child: Text("Photo with Camera"),
                                        onPressed: () async {
                                          await postController.uploadPhoto
                                              .handleTakePhoto(context);
                                          setState(() {});
                                        }),
                                    SimpleDialogOption(
                                        child: Text("Image from Gallery"),
                                        onPressed: () async {
                                          await postController.uploadPhoto
                                              .handleChooseFromGallery(context);
                                          setState(() {});
                                        }),
                                    SimpleDialogOption(
                                      child: Text("Cancel"),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        // IconButton(
                        //   icon: Icon(Icons.mic),
                        //   color: Colors.grey[400],
                        //   onPressed: () {},
                        // )
                      ],
                    )),
              ),
            ),
          ],
        ),
      );
    });
  }
}
