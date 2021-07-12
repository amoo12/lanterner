import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lanterner/controllers/uploadPhoto.dart';
import 'package:lanterner/pages/myProfile.dart';
import 'package:lanterner/pages/profile.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

GestureDetector buildCircleAvatar(
    {@required String ownerId,
    photoUrl,
    @required currentUserId,
    @required double size,
    @required BuildContext context}) {
  return GestureDetector(
    onTap: () {
      if (ownerId == currentUserId) {
        if (ModalRoute.of(context).settings.name == '/myProfile') {
          // upload photo
          // onTap:
          // () {
          //   showDialog(
          //     context: context,
          //     builder: (context) {
          //       return SimpleDialog(
          //         title: Text("Upload image"),
          //         children: <Widget>[
          //           SimpleDialogOption(
          //               child: Text("Photo with Camera"),
          //               onPressed: () async {
          //                 await uploadPhoto.handleTakePhoto(context);
          //                 // setState(() {});
          //               }),
          //           SimpleDialogOption(
          //               child: Text("Image from Gallery"),
          //               onPressed: () async {
          //                 await uploadPhoto.handleChooseFromGallery(context);
          //                 // setState(() {});
          //               }),
          //           SimpleDialogOption(
          //             child: Text("Cancel"),
          //             onPressed: () => Navigator.pop(context),
          //           )
          //         ],
          //       );
          //     },
          //   );
          // };
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
            screen: Profile(uid: ownerId),
            pageTransitionAnimation: PageTransitionAnimation.slideUp,
            withNavBar: false,
          );
        }
      }
    },
    child: CircleAvatar(
      radius: size,
      backgroundImage: photoUrl != null
          ? CachedNetworkImage(
              imageUrl: photoUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            )
          : AssetImage('assets/images/avatar_bg.jpg'),
      child: photoUrl == null
          ? Icon(Icons.person, size: 40, color: Colors.grey[200])
          : Container(),
    ),
  );
}

class ProfileImage extends StatefulWidget {
  final String ownerId;
  final photoUrl;
  final currentUserId;
  final double size;
  final BuildContext context;

  ProfileImage(
      {Key key,
      @required this.ownerId,
      @required this.photoUrl,
      @required this.currentUserId,
      @required this.size,
      @required this.context})
      : super(key: key);

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  DatabaseService db = DatabaseService();

  uploadImage(String uid) async {
    String photoUrl;
    await uploadPhoto.compressImage(uid);
    photoUrl = await uploadPhoto.uploadImage(uploadPhoto.file, uid);
    await db.updateProfilePicture(uid, photoUrl);
  }

  UploadPhoto uploadPhoto = UploadPhoto();

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
                            // customProgressIdicator(context);
                            await uploadImage(widget.currentUserId);
                          }
                          setState(() {});
                        }),
                    SimpleDialogOption(
                        child: Text("Image from Gallery"),
                        onPressed: () async {
                          await uploadPhoto.handleChooseFromGallery(context);

                          if (uploadPhoto.file != null) {
                            // customProgressIdicator(context);
                            await uploadImage(widget.currentUserId);
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
      child: CircleAvatar(
        radius: widget.size,
        backgroundImage: widget.photoUrl != null
            ? NetworkImage(
                widget.photoUrl,
              )
            : AssetImage('assets/images/avatar_bg.jpg'),
        child: widget.photoUrl == null
            ? Icon(Icons.person, size: 40, color: Colors.grey[200])
            : Container(),
      ),
    );
  }
}
