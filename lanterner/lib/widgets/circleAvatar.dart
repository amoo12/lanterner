import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lanterner/controllers/uploadPhoto.dart';
import 'package:lanterner/pages/myProfile.dart';
import 'package:lanterner/pages/profile.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/customToast.dart';
import 'package:lanterner/widgets/progressIndicator.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class ProfileImage extends StatefulWidget {
  final String ownerId;
  String photoUrl;
  final currentUserId;
  final double size;
  final BuildContext context;
  final Function refreshParent;

  ProfileImage(
      {Key key,
      @required this.ownerId,
      @required this.photoUrl,
      @required this.currentUserId,
      @required this.size,
      @required this.context,
      this.refreshParent})
      : super(key: key);

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  DatabaseService db = DatabaseService();
  FToast fToast;
  uploadImage(String uid) async {
    String photoUrl;
    await uploadPhoto.compressImage(uid);

    photoUrl = await uploadPhoto.uploadImage(
        imageFile: uploadPhoto.file, id: uid, folder: 'profile');
    setState(() {
      widget.photoUrl = photoUrl;
    });

    await db.updateProfilePicture(uid, photoUrl);
  }

  UploadPhoto uploadPhoto = UploadPhoto();

  @override
  void initState() {
    super.initState();
    fToast = FToast();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (widget.ownerId == widget.currentUserId) {
            if (ModalRoute.of(context).settings.name == '/myProfile') {
              // upload photo

              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: Text("Upload image"),
                    children: <Widget>[
                      SimpleDialogOption(
                          child: Text("Photo with Camera"),
                          onPressed: () async {
                            await uploadPhoto.handleTakePhoto(context);
                            if (uploadPhoto.file != null) {
                              fToast.init(widget.context);
                              showToast(fToast, 'photo updoated successfully');
                              // customProgressIdicator(widget.context);
                              await uploadImage(widget.currentUserId);
                              // widget.refreshParent();
                            }
                            setState(() {});
                          }),
                      SimpleDialogOption(
                          child: Text("Image from Gallery"),
                          onPressed: () async {
                            await uploadPhoto.handleChooseFromGallery(context);

                            if (uploadPhoto.file != null) {
                              fToast.init(widget.context);
                              showToast(
                                  fToast, 'photo updoated successfully', 2);
                              // customProgressIdicator(widget.context);
                              await uploadImage(widget.currentUserId);
                              // Navigator.pop(widget.context);
                              // widget.refreshParent();
                            }
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
            } else {
              pushNewScreenWithRouteSettings(
                context,
                settings: RouteSettings(name: '/myProfile'),
                screen: MyProfile(),
                pageTransitionAnimation: PageTransitionAnimation.slideUp,
                withNavBar: false,
              );
            }
          } else {
            if (ModalRoute.of(context).settings.name != '/profile') {
              pushNewScreenWithRouteSettings(
                context,
                settings: RouteSettings(name: '/profile'),
                screen: Profile(uid: widget.ownerId),
                pageTransitionAnimation: PageTransitionAnimation.slideUp,
                withNavBar: false,
              );
            }
          }
        },
        child: widget.photoUrl != null
            ? CircleAvatar(
                radius: widget.size,
                backgroundImage: CachedNetworkImageProvider(
                  widget.photoUrl,
                ),
                child: Visibility(
                  child: Icon(Icons.person,
                      size: widget.size, color: Colors.grey[300]),
                  visible: widget.photoUrl == null,
                ))
            : CircleAvatar(
                radius: widget.size,
                child: Icon(Icons.person,
                    size: widget.size, color: Colors.grey[300])));
  }
}
