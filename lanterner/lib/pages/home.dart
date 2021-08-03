import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/providers/posts_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/postCard.dart';

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

class _HomeState extends State<Home> with TickerProviderStateMixin {
  ScrollController _scrollViewController1;
  ScrollController _scrollViewController2;
  TabController _tabController;
  final _allPostListKey = GlobalKey<State<StatefulWidget>>();
  final _followingPostsListKey = GlobalKey<State<StatefulWidget>>();
  bool isScrollingDown = false;
  double appbarHieght = 80.0;
  double listbottomPadding = 50.0;
  double textSize = 14;
  DatabaseService db = DatabaseService();
  String uid;

  handleCollapsingAppBar(ScrollController _scrollViewController) {
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
  }

  @override
  void initState() {
    super.initState();
    uid = context.read(authStateProvider).data.value.uid;
    _scrollViewController1 = ScrollController();
    _scrollViewController2 = ScrollController();
    _tabController = TabController(vsync: this, length: 2);
    _scrollViewController1.addListener(() {
      handleCollapsingAppBar(_scrollViewController1);
    });
    _scrollViewController2.addListener(() {
      handleCollapsingAppBar(_scrollViewController2);
    });
    _tabController.addListener(() {
      setState(() {
        // Future.delayed(const Duration(milliseconds: 100));
        isScrollingDown = false;
        widget.showNav();
        appbarHieght = 80.0;
        textSize = 14;
        listbottomPadding = 0;
      });
    });
  }

  @override
  void dispose() {
    _scrollViewController1.dispose();
    _scrollViewController2.dispose();
    _tabController.dispose();
    _scrollViewController1.removeListener(() {});
    _scrollViewController2.removeListener(() {});
    _tabController.removeListener(() {});
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
                      controller: _tabController,
                      // physics: NeverScrollableScrollPhysics(),
                      children: [
                        FutureBuilder(
                            future: db.getPosts(uid),
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
                                          controller: _scrollViewController1,
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
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('No posts uploaded yet'),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      SvgPicture.asset(
                                        'assets/images/no posts optimised.svg',
                                        height:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                    ],
                                  ));
                                }
                              } else {
                                return circleIndicator(context);
                              }
                            }),
                        FollowingTab(
                            db: db,
                            uid: uid,
                            listbottomPadding: listbottomPadding,
                            followingPostsListKey: _followingPostsListKey,
                            scrollViewController2: _scrollViewController2),
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
      child: !isScrollingDown
          ? AppBar(
              title: Center(
                child: Text('Lanterner',
                    style: Theme.of(context)
                        .textTheme
                        .headline2
                        .copyWith(fontFamily: 'FORTE')),
              ),
              bottom: TabBar(
                controller: _tabController,
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
            )
          : Container(),
    );
  }
}

class FollowingTab extends StatelessWidget {
  const FollowingTab({
    Key key,
    @required this.db,
    @required this.uid,
    @required this.listbottomPadding,
    @required GlobalKey<State<StatefulWidget>> followingPostsListKey,
    @required ScrollController scrollViewController2,
  })  : _followingPostsListKey = followingPostsListKey,
        _scrollViewController2 = scrollViewController2,
        super(key: key);

  final DatabaseService db;
  final String uid;
  final double listbottomPadding;
  final GlobalKey<State<StatefulWidget>> _followingPostsListKey;
  final ScrollController _scrollViewController2;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: db.getUserTimeline(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return Consumer(builder: (context, watch, child) {
                watch(followingPostProvider).posts = snapshot.data;
                List<Post> posts =
                    watch(followingPostProvider).posts.length == 0
                        ? snapshot.data
                        : [
                            // ...snapshot.data,
                            ...watch(followingPostProvider).posts
                          ];

                return Container(
                  padding: EdgeInsets.only(bottom: listbottomPadding),
                  child: ListView.builder(
                      key: _followingPostsListKey,
                      controller: _scrollViewController2,
                      itemCount: posts.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Hero(
                          tag:
                              'follwingPosts-to-comments' + posts[index].postId,
                          child: PostCard(
                              post: posts[index],
                              herotag: 'follwingPosts-to-comments',
                              key: ValueKey(posts[index].postId)),
                        );
                      }),
                );
              });
            } else {
              return Container(
                  child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('No posts!! \n'),
                    Text('Follow other users to see their posts here'),
                    SizedBox(
                      height: 20,
                    ),
                    SvgPicture.asset(
                      'assets/images/no posts optimised.svg',
                      height: MediaQuery.of(context).size.width,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ],
                ),
              ));
            }
          } else {
            return circleIndicator(context);
          }
        });
  }
}
