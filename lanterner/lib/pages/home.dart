import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/providers/posts_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/postCard.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../widgets/progressIndicator.dart';

//ignore: must_be_immutable
class Home extends StatefulWidget {
  final BuildContext menuScreenContext;
  final Function hideNav;
  final Function showNav;
  final Function onScreenHideButtonPressed;
  bool hideStatus;
  Home(
      {Key key,
      this.menuScreenContext,
      this.hideNav,
      this.showNav,
      this.onScreenHideButtonPressed,
      this.hideStatus = false})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ScrollController _scrollViewController;
  final _allPostListKey = GlobalKey<State<StatefulWidget>>();
  final _followingPostsListKey = GlobalKey<State<StatefulWidget>>();
  bool isScrollingDown = false;
  double appbarHieght = 80.0;
  double listbottomPadding = 50.0;
  double textSize = 14;
  DatabaseService db = DatabaseService();
  String uid;
  @override
  void initState() {
    super.initState();
    uid = context.read(authStateProvider).data.value.uid;
    _scrollViewController = new ScrollController();
    _scrollViewController.addListener(() {
      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          // this.widget.hideStatus = true;
          setState(() {
            widget.hideNav();
            appbarHieght = 0;
            textSize = 0;
            listbottomPadding = 0;
          });
        }
      }

      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;

          setState(() {
            widget.showNav();
            appbarHieght = 80.0;
            textSize = 14;
            listbottomPadding = 0;
          });
        }
      }

      if (_scrollViewController.position.atEdge) {
        setState(() {
          // widget.showNav();
          // appbarHieght = 80.0;
          // textSize = 14;
          listbottomPadding = 50;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _scrollViewController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Column(
            children: [
              Flexible(flex: -1, child: buildMyAppBar()),
              Expanded(
                // flex: 7,
                child: Column(
                  children: [
                    Expanded(
                        child: TabBarView(
                      // physics: NeverScrollableScrollPhysics(),
                      children: [
                        FutureBuilder(
                            future: db.getPosts(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data.length > 0) {
                                  return Consumer(
                                      builder: (context, watch, child) {
                                    watch(postProvider).posts = snapshot.data;
                                    List<Post> posts =
                                        watch(postProvider).posts.length == 0
                                            ? snapshot.data
                                            : [
                                                // ...snapshot.data,
                                                ...watch(postProvider).posts
                                              ];

                                    return Container(
                                      padding: EdgeInsets.only(
                                          bottom: listbottomPadding),
                                      child: ListView.builder(
                                          key: _allPostListKey,
                                          controller: _scrollViewController,
                                          itemCount: posts.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Hero(
                                              tag: 'allPosts-to-comments' +
                                                  posts[index].postId,
                                              child: PostCard(
                                                  post: posts[index],
                                                  herotag:
                                                      'allPosts-to-comments',
                                                  key: ValueKey(
                                                      posts[index].postId)),
                                            );
                                          }),
                                    );
                                  });
                                } else {
                                  return Container(
                                      child: Center(
                                    child: Text('No posts uploaded yet'),
                                  ));
                                }
                              } else {
                                return circleIndicator(context);
                              }
                            }),
                        FutureBuilder(
                            future: db.getUserTimeline(uid),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data.length > 0) {
                                  return Consumer(
                                      builder: (context, watch, child) {
                                    watch(followingPostProvider).posts =
                                        snapshot.data;
                                    List<Post> posts =
                                        watch(followingPostProvider)
                                                    .posts
                                                    .length ==
                                                0
                                            ? snapshot.data
                                            : [
                                                // ...snapshot.data,
                                                ...watch(followingPostProvider)
                                                    .posts
                                              ];

                                    return Container(
                                      padding: EdgeInsets.only(
                                          bottom: listbottomPadding),
                                      child: ListView.builder(
                                          key: _followingPostsListKey,
                                          controller: _scrollViewController,
                                          itemCount: posts.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Hero(
                                              tag: 'follwingPosts-to-comments' +
                                                  posts[index].postId,
                                              child: PostCard(
                                                  post: posts[index],
                                                  herotag:
                                                      'follwingPosts-to-comments',
                                                  key: ValueKey(
                                                      posts[index].postId)),
                                            );
                                          }),
                                    );
                                  });
                                } else {
                                  return Container(
                                      child: Center(
                                    child: Text(
                                        'Follow other users to see their posts here'),
                                  ));
                                }
                              } else {
                                return circleIndicator(context);
                              }
                            }),
                      ],
                    )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
    // );
  }

  // builds an appbar that disappears in scroll
  AnimatedContainer buildMyAppBar() {
    return AnimatedContainer(
      height: appbarHieght,
      duration: Duration(milliseconds: 300),
      child: AppBar(
        title: Center(
          child: Text('Lanterner',
              style: Theme.of(context)
                  .textTheme
                  .headline2
                  .copyWith(fontFamily: 'FORTE')),
        ),
        bottom: TabBar(
          isScrollable: true, // brings the tabs to the center
          dragStartBehavior: DragStartBehavior.down,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(
              child: Text(
                'All',
                style: TextStyle(fontSize: textSize),
              ),
            ),
            Tab(
              child: Text(
                'Following',
                style: TextStyle(fontSize: textSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
