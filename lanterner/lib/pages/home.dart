import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/post.dart';
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
  final _myList = GlobalKey<State<StatefulWidget>>();
  bool isScrollingDown = false;
  double appbarHieght = 80.0;
  double listbottomPadding = 50.0;
  double textSize = 14;
  DatabaseService db = DatabaseService();

  @override
  void initState() {
    super.initState();
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
                                          key: _myList,
                                          controller: _scrollViewController,
                                          itemCount: posts.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return PostCard(posts[index],
                                                key: ValueKey(
                                                    posts[index].postId));
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
                        Container(child: Center(child: Text('Following')))
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

class MainScreen2 extends StatelessWidget {
  const MainScreen2({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  pushNewScreen(context, screen: MainScreen3());
                },
                child: Text(
                  "Go to Third Screen",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Go Back to First Screen",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScreen3 extends StatelessWidget {
  const MainScreen3({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Go Back to Second Screen",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// SafeArea(
//   child: Column(
//     children: [
//       buildMyAppBar(),
//       Expanded(
//         child: SingleChildScrollView(
//           controller: _scrollViewController,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: <Widget>[
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     pushNewScreenWithRouteSettings(
//                       context,
//                       settings: RouteSettings(name: '/home'),
//                       screen: MainScreen2(),
//                       pageTransitionAnimation:
//                           PageTransitionAnimation.scaleRotate,
//                     );
//                   },
//                   child: Text(
//                     "Go to Second Screen ->",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     showModalBottomSheet(
//                       context: context,
//                       backgroundColor: Colors.white,
//                       useRootNavigator: true,
//                       builder: (context) => Center(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             "Exit",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   child: Text(
//                     "Push bottom sheet on TOP of Nav Bar",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     showModalBottomSheet(
//                       context: context,
//                       backgroundColor: Colors.white,
//                       useRootNavigator: false,
//                       builder: (context) => Center(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             "Exit",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   child: Text(
//                     "Push bottom sheet BEHIND the Nav Bar",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // pushDynamicScreen(context,
//                     //     screen: SampleModalScreen(), withNavBar: true);
//                   },
//                   child: Text(
//                     "Push Dynamic/Modal Screen",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     this.widget.onScreenHideButtonPressed();
//                   },
//                   child: Text(
//                     this.widget.hideStatus
//                         ? "Unhide Navigation Bar"
//                         : "Hide Navigation Bar",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(this.widget.menuScreenContext).pop();
//                   },
//                   child: Text(
//                     "<- Main Menu",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 60.0,
//               ),
//               PostCard(),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
