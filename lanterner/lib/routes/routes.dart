import 'package:flutter/material.dart';
import 'package:lanterner/auth_wrapper.dart';
import 'package:lanterner/pages/authentication/login.dart';
import 'package:lanterner/pages/authentication/signup.dart';
import 'package:lanterner/pages/bottomNavigationBar.dart';
import 'package:lanterner/pages/chats/chatScreen.dart';
import 'package:lanterner/pages/comments.dart';
import 'package:lanterner/pages/followers.dart';
import 'package:lanterner/pages/myProfile.dart';
import 'package:lanterner/pages/EditBio.dart';
import 'package:lanterner/pages/new_post.dart';
import 'package:lanterner/pages/profile.dart';
import 'package:lanterner/pages/settings.dart';
import 'package:lanterner/widgets/postCard.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/signup': (context) => Signup(),
  '/login': (context) => Login(),
  '/newPost': (context) => NewPost(),
  '/imageViewer': (context) => ImageViewer(),
  '/settings': (context) => Settings(),
  '/wrapper': (context) => Wrapper(),
  '/myBottomNavBar': (context) => MyBottomNavBar(),
  '/profile': (context) => Profile(),
  '/myProfile': (context) => MyProfile(),
  '/comments': (context) => Comments(),
  '/followers': (context) => FollowersList(),
  '/editBio': (context) => EditBio(),
  '/chatRoom': (context) => ChatRoom(),
  
};
