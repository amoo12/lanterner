import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lanterner/pages/chats/chatsList.dart';
import 'package:lanterner/pages/new_post.dart';
import 'package:lanterner/pages/myProfile.dart';
import 'package:lanterner/pages/activityList.dart';
import 'package:lanterner/pages/search.dart';
import 'package:lanterner/routes/routes.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'home.dart';
import 'package:animations/animations.dart';

BuildContext testContext;

class MyBottomNavBar extends StatefulWidget {
  final BuildContext menuScreenContext;
  MyBottomNavBar({Key key, this.menuScreenContext}) : super(key: key);

  @override
  _MyBottomNavBarState createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  PersistentTabController _controller;
  bool _hideNavBar;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _hideNavBar = false;
  }

  List<Widget> _buildScreens() {
    return [
      Home(
        menuScreenContext: widget.menuScreenContext,
        hideStatus: _hideNavBar,
        hideNav: () {
          setState(() {
            _hideNavBar = true;
          });
        },
        showNav: () {
          setState(() {
            _hideNavBar = false;
          });
        },
      ),
      ChatsList(),
      Center(
        child: Search(),
      ),
      ActivityList(menuScreenContext: widget.menuScreenContext),
      MyProfile(
        menuScreenContext: widget.menuScreenContext,
        hideStatus: _hideNavBar,
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(
            MdiIcons.notificationClearAll), // * consider using this for home
        // icon: Icon(MdiIcons.homeCircle),
        title: "Home",
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        inactiveColorSecondary: Colors.white,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/home',
          routes: routes,
        ),

        // textStyle: TextStyle(color: Colors.red, fontSize: 20),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(MdiIcons.chat),
        inactiveIcon: Icon(MdiIcons.chatOutline),
        title: ("chats"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/chats',
          routes: routes,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search),
        title: ("Search"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/search',
          routes: routes,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.notifications),
        title: ("Notifications"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/activity',
          routes: routes,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person_pin),
        title: ("My Profile"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/myProfile',
          routes: routes,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      // drawer: Drawer(
      //   child: Center(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         const Text('This is the Drawer'),
      //       ],
      //     ),
      //   ),
      // ),
      floatingActionButton: _controller.index ==
              0 // makes sure the button only appears in home
          ? AnimatedContainer(
              // color: Colors.transparent,
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(bottom: _hideNavBar ? 0 : 56),
              child: OpenContainer(
                // closedShape: ,
                closedColor: Colors.transparent,
                closedElevation: 0.0,
                closedShape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                transitionDuration: Duration(milliseconds: 500),
                closedBuilder: (BuildContext c, VoidCallback action) =>
                    FloatingActionButton(
                  // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  child: Icon(
                    Icons.add_comment,
                    color: Colors.white,
                  ),
                  onPressed: null,
                  // () {
                  // pushNewScreenWithRouteSettings(
                  //   context,
                  //   settings: RouteSettings(name: '/newPost'),
                  //   screen: NewPost(),
                  //   pageTransitionAnimation: PageTransitionAnimation.slideUp,
                  //   withNavBar: false,
                  // )..then((value) => setState(() {}));
                  // },
                ),

                openBuilder: (BuildContext c, VoidCallback action) => NewPost(),
                tappable: true,
              ),
            )
          : Container(
              width: 0.0,
              height: 0.0,
            ),
      body: PersistentTabView(
        context,
        onItemSelected: (index) {
          setState(() {});
        },
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
            ? 0.0
            : kBottomNavigationBarHeight,
        hideNavigationBarWhenKeyboardShows: true,
        // ! the state of the keyboard is maintained if you use the back button to pop it and it keeps appearing every time you open the tap,
        //! don't put any text fields in the home page.    (maybe because of hiding navbar on scroll)
        // margin: EdgeInsets.only(bottom: 10.0, right: 10, left: 10),
        popActionScreens: PopActionScreensType.all,
        bottomScreenMargin: 0.0,
        onWillPop: (context) async {
          return showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Are you sure?'),
                  content: Text('Do you want to exit the App?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'No',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        exit(0);
                      },
                      /*Navigator.of(context).pop(true)*/
                      child: Text(
                        'Yes',
                        style: TextStyle(
                            color: Theme.of(context).scaffoldBackgroundColor),
                      ),
                    ),
                  ],
                ),
              ) ??
              false;

          // return false;
        },
        selectedTabScreenContext: (context) {
          testContext = context;
        },
        hideNavigationBar: _hideNavBar,
        decoration: NavBarDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          border: Border.all(color: Colors.grey, width: 0.1),
          adjustScreenBottomPaddingOnCurve: true,
          colorBehindNavBar: Colors.redAccent,
          gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor,
              ]),
          borderRadius: BorderRadius.horizontal(
            left: Radius.zero,
            right: Radius.zero,
          ),
        ),
        popAllScreensOnTapOfSelectedTab: true,
        itemAnimationProperties: ItemAnimationProperties(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style13, // Choose the nav bar style with this property
      ),
    );
  }
}
