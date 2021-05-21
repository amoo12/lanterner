import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/widgets/postCard.dart';
import '../models/user.dart';
import '../services/databaseService.dart';
import '../widgets/progressIndicator.dart';

//ignore: must_be_immutable
class Profile extends ConsumerWidget {
  final String uid;
  // final BuildContext menuScreenContext;
  // final Function hideNav;
  // final Function showNav;
  // final Function onScreenHideButtonPressed;
  bool hideStatus;
  DatabaseService db = DatabaseService();
  GlobalKey _scaffold = GlobalKey();

  ScrollController _scrollViewController = ScrollController();

  Profile(
      {Key key,
      // this.menuScreenContext,
      // this.hideNav,
      // this.showNav,
      // this.onScreenHideButtonPressed,
      this.uid,
      this.hideStatus = false})
      : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return FutureBuilder(
        future: db.getUser(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User user = snapshot.data;

            return DefaultTabController(
              length: 2,
              child: Scaffold(
                key: _scaffold,
                backgroundColor: Theme.of(context).primaryColor,
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Theme.of(context).primaryColor,
                  title: Text(user.name),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    primary: true,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.30,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ]),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Row(
                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: user.photoUrl != null
                                            ? NetworkImage(
                                                user.photoUrl,
                                              )
                                            : NetworkImage(
                                                'https://via.placeholder.com/150'),
                                        child: user.photoUrl == null
                                            ? Icon(Icons.person,
                                                size: 50, color: Colors.grey)
                                            : Container(),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        children: [
                                          Text(
                                            user.name,
                                            // 'name',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            '@' + 'kare_12',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  height: 45,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            '0',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            'Following',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 30,
                                        child: VerticalDivider(
                                          // width: 1.0,
                                          color: Colors.grey[600],
                                          thickness: 0.5,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '0',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            'Followers',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        height: 30,
                                        child: VerticalDivider(
                                          color: Colors.grey[600],
                                          thickness: 0.5,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '0',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Text(
                                            'Posts',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                          child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              35),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          primary:
                                              Theme.of(context).accentColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            // side: buttonType == 2
                                            //   // ? BorderSide(color: Theme.of(context).accentColor, width: 1)
                                            //   //     : BorderSide.none
                                            // ),
                                          ),
                                        ),
                                        onPressed: () {},
                                        child: Text('Follow'),
                                      )),
                                      Container(
                                          child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              35),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          // primary: Theme.of(context).accentColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                  width: 1)),
                                        ),
                                        onPressed: () {},
                                        child: Row(
                                          children: [
                                            Text('Message'),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                TabBar(
                                  indicatorSize: TabBarIndicatorSize.label,
                                  indicatorWeight: 3,
                                  tabs: [
                                    Tab(
                                      text: 'Profile',
                                    ),
                                    Tab(
                                      text: 'Posts',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Column(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 12.0),
                                                  child: Text('Statistics'),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.85,
                                                  height: 75,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  decoration: BoxDecoration(
                                                    // color: Theme.of(context).cardColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 1),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                              color:
                                                                  Colors.grey,
                                                              icon: Icon(
                                                                Icons.translate,
                                                                size: 20,
                                                              ),
                                                              onPressed: () {}),
                                                          Text('0'),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                              color:
                                                                  Colors.grey,
                                                              icon: Icon(
                                                                Icons
                                                                    .star_border_rounded,
                                                                size: 20,
                                                              ),
                                                              onPressed: () {}),
                                                          Text('0'),
                                                        ],
                                                      ),
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                              color:
                                                                  Colors.grey,
                                                              icon: Icon(
                                                                Icons.headset,
                                                                size: 20,
                                                              ),
                                                              onPressed: () {}),
                                                          Text('0'),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 12.0),
                                                    child: Text('About'),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 12.0),
                                                    child: Text(
                                                        'About me, I am a the perfect language partner'
                                                        // user.about
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          padding: EdgeInsets.only(top: 10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.95,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  child: FutureBuilder(
                                                      future:
                                                          db.getUserPosts(uid),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot.hasData) {
                                                          List<Post> posts =
                                                              snapshot.data;

                                                          if (posts.length >
                                                              0) {
                                                            return ListView
                                                                .builder(
                                                                    // physics: NeverScrollableScrollPhysics(),
                                                                    // primary:
                                                                    // false,
                                                                    // shrinkWrap:
                                                                    //     true,
                                                                    itemCount: posts
                                                                        .length,
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      return PostCard(
                                                                          posts[
                                                                              index]);
                                                                    });
                                                          } else {
                                                            return Container(
                                                                child: Center(
                                                              child: Text(
                                                                  'No posts uploaded yet'),
                                                            ));
                                                          }
                                                        } else {
                                                          return Container(
                                                              child: Center(
                                                                  child:
                                                                      CircularProgressIndicator()));
                                                        }
                                                      })),
                                            ],
                                          ))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return circleIndicator(context);
          }
        });
  }
}
