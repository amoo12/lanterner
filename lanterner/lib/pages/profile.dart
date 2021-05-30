import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/pages/myPosts.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/widgets/circleAvatar.dart';
import 'package:lanterner/widgets/languageIndicator.dart';
import 'package:lanterner/widgets/postCard.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import '../models/user.dart';
import '../services/databaseService.dart';
import '../widgets/progressIndicator.dart';
import 'followers.dart';
import 'dart:math' as math;

//ignore: must_be_immutable
class Profile extends StatefulWidget {
  final String uid;
  Profile({Key key, this.uid}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool hideStatus;
  DatabaseService db = DatabaseService();
  GlobalKey _scaffold = GlobalKey();

  bool isFollowing;
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final _authState = watch(authStateProvider);
      return FutureBuilder(
          future: db.getUser(widget.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              User user = snapshot.data;

              return FutureBuilder(
                  future: db.isFollowing(widget.uid, _authState.data.value.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      isFollowing = snapshot.data;
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
                                height:
                                    MediaQuery.of(context).size.height * 0.9,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.30,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            )
                                          ]),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            child: Row(
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                buildCircleAvatar(
                                                    size: 40,
                                                    ownerId: user.uid,
                                                    context: context,
                                                    photoUrl: user.photoUrl,
                                                    currentUserId: _authState
                                                        .data.value.uid),
                                                // CircleAvatar(
                                                //   radius: 40,
                                                //   backgroundImage: user
                                                //               .photoUrl !=
                                                //           null
                                                //       ? NetworkImage(
                                                //           user.photoUrl,
                                                //         )
                                                //       : NetworkImage(
                                                //           'https://via.placeholder.com/150'),
                                                //   child: user.photoUrl == null
                                                //       ? Icon(Icons.person,
                                                //           size: 50,
                                                //           color: Colors.grey)
                                                //       : Container(),
                                                // ),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      user.name,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Container(
                                                      width: 60,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          languageIndictor(user
                                                              .nativeLanguage),
                                                          Transform.rotate(
                                                            angle: 180 *
                                                                math.pi /
                                                                180,
                                                            child: Icon(
                                                              Icons
                                                                  .arrow_back_ios,
                                                              color:
                                                                  Colors.grey,
                                                              size: 10,
                                                            ),
                                                          ),
                                                          languageIndictor(user
                                                              .targetLanguage),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85,
                                            height: 45,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (user.following > 0) {
                                                      pushNewScreenWithRouteSettings(
                                                          context,
                                                          screen: FollowersList(
                                                            uid: user.uid,
                                                          ),
                                                          settings: RouteSettings(
                                                              name:
                                                                  '/following'),
                                                          withNavBar: false);
                                                    }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        user.following
                                                                .toString() ??
                                                            '0',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        'Following',
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: 30,
                                                  child: VerticalDivider(
                                                    // width: 1.0,
                                                    color: Colors.grey[600],
                                                    thickness: 0.5,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (user.followers > 0) {
                                                      pushNewScreenWithRouteSettings(
                                                          context,
                                                          screen: FollowersList(
                                                            uid: user.uid,
                                                          ),
                                                          settings: RouteSettings(
                                                              name:
                                                                  '/followers'),
                                                          withNavBar: false);
                                                    }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        user.followers
                                                                .toString() ??
                                                            '0',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        'Followers',
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: 30,
                                                  child: VerticalDivider(
                                                    color: Colors.grey[600],
                                                    thickness: 0.5,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    if (user.postsCount > 0) {
                                                      pushNewScreenWithRouteSettings(
                                                          context,
                                                          screen: MyPosts(
                                                            uid: user.uid,
                                                          ),
                                                          settings: RouteSettings(
                                                              name: '/myPosts'),
                                                          withNavBar: false);
                                                    }
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        user.postsCount
                                                                .toString() ??
                                                            '0',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                        'Posts',
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                    child: isFollowing
                                                        ? ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              minimumSize: Size(
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.4,
                                                                  35),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          15),
                                                              primary: Theme.of(
                                                                      context)
                                                                  .accentColor,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                // side: buttonType == 2
                                                                //   // ? BorderSide(color: Theme.of(context).accentColor, width: 1)
                                                                //   //     : BorderSide.none
                                                                // ),
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              User user = await db
                                                                  .getUser(
                                                                      _authState
                                                                          .data
                                                                          .value
                                                                          .uid);

                                                              await db.unfollow(
                                                                  widget.uid,
                                                                  user);
                                                              setState(() {
                                                                isFollowing =
                                                                    false;
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                    'Following'),
                                                                Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .white,
                                                                )
                                                              ],
                                                            ),
                                                          )
                                                        : ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              minimumSize: Size(
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.4,
                                                                  35),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          15),
                                                              // primary: Theme.of(
                                                              //         context)
                                                              //     .accentColor,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                  side: BorderSide(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .accentColor,
                                                                      width: 1)
                                                                  //   //     : BorderSide.none
                                                                  // ),
                                                                  ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              User user = await db
                                                                  .getUser(
                                                                      _authState
                                                                          .data
                                                                          .value
                                                                          .uid);
                                                              await db.follow(
                                                                  widget.uid,
                                                                  user);
                                                              setState(() {
                                                                isFollowing =
                                                                    true;
                                                              });
                                                            },
                                                            child:
                                                                Text('Follow'),
                                                          )),
                                                Container(
                                                    child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize: Size(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                        35),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 15),
                                                    // primary: Theme.of(context).accentColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            side: BorderSide(
                                                                color: Theme.of(
                                                                        context)
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
                                            indicatorSize:
                                                TabBarIndicatorSize.label,
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
                                                  padding:
                                                      EdgeInsets.only(top: 30),
                                                  child: Column(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 12.0),
                                                            child: Text(
                                                                'Statistics'),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.85,
                                                            height: 75,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                              // color: Theme.of(context).cardColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
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
                                                                        color: Colors
                                                                            .grey,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .translate,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                        onPressed:
                                                                            () {}),
                                                                    Text('0'),
                                                                  ],
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    IconButton(
                                                                        color: Colors
                                                                            .grey,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .star_border_rounded,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                        onPressed:
                                                                            () {}),
                                                                    Text('0'),
                                                                  ],
                                                                ),
                                                                Column(
                                                                  children: [
                                                                    IconButton(
                                                                        color: Colors
                                                                            .grey,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .headset,
                                                                          size:
                                                                              20,
                                                                        ),
                                                                        onPressed:
                                                                            () {}),
                                                                    Text('0'),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.85,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            user.bio != null
                                                                ? Container(
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            10,
                                                                            15,
                                                                            10,
                                                                            65),
                                                                    child: Text(
                                                                        user
                                                                            .bio,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.grey[50],
                                                                          fontSize:
                                                                              14,
                                                                          height:
                                                                              1.5,
                                                                        )),
                                                                  )
                                                                : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                    padding: EdgeInsets.only(
                                                        top: 10),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.95,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                            child:
                                                                FutureBuilder(
                                                                    future: db.getUserPosts(
                                                                        widget
                                                                            .uid),
                                                                    builder:
                                                                        (context,
                                                                            snapshot) {
                                                                      if (snapshot
                                                                          .hasData) {
                                                                        List<Post>
                                                                            posts =
                                                                            snapshot.data;
                                                                        if (posts.length >
                                                                            0) {
                                                                          return ListView.builder(
                                                                              itemCount: posts.length,
                                                                              itemBuilder: (BuildContext context, int index) {
                                                                                return PostCard(posts[index]);
                                                                              });
                                                                        } else {
                                                                          return Container(
                                                                              child: Center(
                                                                            child:
                                                                                Text('No posts uploaded yet'),
                                                                          ));
                                                                        }
                                                                      } else {
                                                                        return Container(
                                                                            child:
                                                                                Center(child: CircularProgressIndicator()));
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
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text("ERROR: Someting went wrong");
            } else {
              return circleIndicator(context);
            }
          });
    });
  }
}
