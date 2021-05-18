import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/pages/settings.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import '../models/user.dart';
import '../services/databaseService.dart';
import 'dart:math' as math;
import '../widgets/progressIndicator.dart';

//ignore: must_be_immutable
class Profile extends ConsumerWidget {
  final BuildContext menuScreenContext;
  final Function hideNav;
  final Function showNav;
  final Function onScreenHideButtonPressed;
  bool hideStatus;
  DatabaseService db = DatabaseService();
  GlobalKey _scaffold = GlobalKey();

  Profile(
      {Key key,
      this.menuScreenContext,
      this.hideNav,
      this.showNav,
      this.onScreenHideButtonPressed,
      this.hideStatus = false})
      : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _authState = watch(authStateProvider);

    return FutureBuilder(
        future: db.getUser(_authState.data.value.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            User user = snapshot.data;

            return Scaffold(
              key: _scaffold,
              backgroundColor: Theme.of(context).primaryColor,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                actions: [
                  IconButton(
                    onPressed: () async {
                      pushNewScreenWithRouteSettings(
                        _scaffold.currentContext,
                        settings: RouteSettings(name: '/settings'),
                        screen: Settings(),
                        pageTransitionAnimation:
                            PageTransitionAnimation.scaleRotate,
                        withNavBar: false,
                      );
                    },
                    icon: Icon(
                      Icons.settings,
                    ),
                  )
                ],
              ),
              body: SafeArea(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.28,
                        padding: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[900],
                                blurRadius: 5,
                                spreadRadius: 2,
                              )
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: user.photoUrl != null
                                      ? NetworkImage(
                                          user.photoUrl,
                                        )
                                      : AssetImage(
                                          'https://via.placeholder.com/150'),
                                  child: user.photoUrl == null
                                      ? Icon(Icons.person,
                                          size: 50, color: Colors.grey)
                                      : Container(),
                                ),
                                Text(
                                  user.name,
                                  // 'name',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  '@' + 'kare_12',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: 45,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        '0',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        'Following',
                                        style: TextStyle(color: Colors.grey),
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
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        'Followers',
                                        style: TextStyle(color: Colors.grey),
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
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        'Posts',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Container(
                            //   width: MediaQuery.of(context).size.width * 0.85,
                            //   height: 90,
                            //   decoration: BoxDecoration(
                            //       color: Theme.of(context).cardColor,
                            //       borderRadius: BorderRadius.circular(8.0)),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //     children: [
                            //       Column(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           Container(
                            //             decoration: BoxDecoration(
                            //                 color: Colors.deepPurple[50],
                            //                 borderRadius: BorderRadius.circular(50)),
                            //             child: IconButton(
                            //                 color: Colors.grey,
                            //                 icon: Icon(Icons.translate),
                            //                 onPressed: () {}),
                            //           ),
                            //           Text('0'),
                            //         ],
                            //       ),
                            //       Column(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           IconButton(
                            //               color: Colors.grey,
                            //               icon: Icon(Icons.star_border_rounded),
                            //               onPressed: () {}),
                            //           Text('0'),
                            //         ],
                            //       ),
                            //       Column(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           IconButton(
                            //               color: Colors.grey,
                            //               icon: Icon(Icons.headset),
                            //               onPressed: () {}),
                            //           Text('0'),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text('Statistics'),
                          ),
                          Container(
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      height: 60,
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        // color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                              color: Colors.grey,
                                              icon: Icon(
                                                Icons.translate,
                                                size: 20,
                                              ),
                                              onPressed: () {}),
                                          Column(
                                            children: [
                                              Text(
                                                '0',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Translatoins',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 60,
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        // color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                              color: Colors.grey,
                                              icon: Icon(
                                                Icons.headset,
                                                size: 20,
                                              ),
                                              onPressed: () {}),
                                          Column(
                                            children: [
                                              Text(
                                                '0',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                'Audio played',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                Container(
                                  height: 60,
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  decoration: BoxDecoration(
                                    //     // color: Colors.deepPurple[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey, width: 0.2),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {},
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Favoirites',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: IconButton(
                                                splashRadius: 0.1,
                                                color: Colors.grey,
                                                icon: Icon(
                                                  Icons.star_rounded,
                                                  size: 24,
                                                ),
                                                onPressed: () {},
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Transform.rotate(
                                                angle: 180 * math.pi / 180,
                                                child: IconButton(
                                                  splashRadius: 0.1,
                                                  color: Colors.grey,
                                                  icon: Icon(
                                                    Icons.arrow_back_ios,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {},
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                                //   children: [
                                //     Container(
                                //       height: 60,
                                //       width: MediaQuery.of(context).size.width * 0.9,
                                //       // padding: EdgeInsets.symmetric(
                                //       //     horizontal: 10, vertical: 8),
                                //       decoration: BoxDecoration(
                                //         //     // color: Colors.deepPurple[50],
                                //         borderRadius: BorderRadius.circular(8),
                                //         border:
                                //             Border.all(color: Colors.grey, width: 0.2),
                                //       ),
                                //       child: ListTile(
                                //         leading: IconButton(
                                //             color: Colors.grey,
                                //             icon: Icon(
                                //               Icons.star_border_rounded,
                                //               size: 20,
                                //             ),
                                //             onPressed: () {}),
                                //         title: Text(
                                //           'Favoirites',
                                //           style: TextStyle(color: Colors.grey),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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

// Expanded(
//                 child: Container(
//                     padding: EdgeInsets.only(top: 20),
//                     width: MediaQuery.of(context).size.width * 0.95,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Moments'),
//                         Expanded(
//                             child: FutureBuilder(
//                                 future:
//                                     db.getUserPosts(_authState.data.value.uid),
//                                 builder: (context, snapshot) {
//                                   if (snapshot.hasData) {
//                                     List<Post> posts = snapshot.data;

//                                     if (posts.length > 0) {
//                                       return ListView.builder(
//                                           controller: _scrollViewController,
//                                           itemCount: posts.length,
//                                           itemBuilder: (BuildContext context,
//                                               int index) {
//                                             return PostCard(posts[index]);
//                                           });
//                                     } else {
//                                       return Container(
//                                           child: Center(
//                                         child: Text('No posts uploaded yet'),
//                                       ));
//                                     }
//                                   } else {
//                                     return Container(
//                                         child: Center(
//                                             child:
//                                                 CircularProgressIndicator()));
//                                   }
//                                 })),
//                       ],
//                     )),
//               )
