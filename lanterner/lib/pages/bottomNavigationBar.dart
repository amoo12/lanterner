import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lanterner/pages/new_post.dart';
import 'package:lanterner/pages/profile.dart';
import 'package:lanterner/pages/search.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'home.dart';

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
      Center(
        child: Text('chats'),
      ),
      Center(
        child: Search(),
      ),
      Center(
        child: Text('notifications'),
      ),
      Profile(
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
        // textStyle: TextStyle(color: Colors.red, fontSize: 20),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(MdiIcons.chat),
        inactiveIcon: Icon(MdiIcons.chatOutline),
        title: ("Messages"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/',
          routes: {
            '/first': (context) => MainScreen2(),
            '/second': (context) => MainScreen3(),
          },
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search),
        title: ("explore"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/',
          routes: {
            '/first': (context) => MainScreen2(),
            '/second': (context) => MainScreen3(),
          },
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.notifications),
        title: ("Notifications"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/',
          routes: {
            '/first': (context) => MainScreen2(),
            '/second': (context) => MainScreen3(),
          },
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person_pin),
        title: ("Profile"),
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/',
          routes: {
            '/first': (context) => MainScreen2(),
            '/second': (context) => MainScreen3(),
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.only(bottom: _hideNavBar ? 0 : 56),
              child: FloatingActionButton(
                // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Icon(
                  Icons.add_comment,
                  color: Colors.white,
                ),
                onPressed: () {
                  pushNewScreenWithRouteSettings(
                    context,
                    settings: RouteSettings(name: '/newPost'),
                    screen: NewPost(),
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    withNavBar: false,
                  );
                },
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
          await showDialog(
            context: context,
            useSafeArea: true,
            builder: (context) => Container(
              height: 50.0,
              width: 50.0,
              color: Colors.white,
              child: ElevatedButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          );
          return false;
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
