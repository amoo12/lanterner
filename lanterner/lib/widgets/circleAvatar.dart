import 'package:flutter/material.dart';
import 'package:lanterner/pages/myProfile.dart';
import 'package:lanterner/pages/profile.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

GestureDetector buildCircleAvatar(
    {@required String ownerId,
    @required photoUrl,
    @required currentUserId,
    @required double size,
    @required BuildContext context}) {
  return GestureDetector(
    onTap: () {
      if (ownerId == currentUserId) {
        if (ModalRoute.of(context).settings.name == '/myProfile') {
          // upload photo
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
          ? NetworkImage(
              photoUrl,
            )
          : AssetImage('assets/images/avatar_bg.jpg'),
      child: photoUrl == null
          ? Icon(Icons.person, size: 40, color: Colors.grey[200])
          : Container(),
    ),
  );
}
