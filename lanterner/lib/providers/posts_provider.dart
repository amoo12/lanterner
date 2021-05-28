import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/post.dart';
import 'package:flutter/material.dart';

final postProvider =
    ChangeNotifierProvider.autoDispose<PostsList>((ref) => PostsList());

class PostsList extends ChangeNotifier {
  List<Post> posts;
  PostsList([List<Post> initialPosts]) : super();

  void remove([Post post]) {
    posts.remove(post);

    //*  must call notifyListeners to trigger rebuild
    notifyListeners();
  }
}
