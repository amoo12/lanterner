import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/circleAvatar.dart';
import 'package:lanterner/widgets/progressIndicator.dart';

class FollowersList extends StatefulWidget {
  final String uid;

  FollowersList({Key key, this.uid}) : super(key: key);

  @override
  _FollowersListState createState() => _FollowersListState();
}

class _FollowersListState extends State<FollowersList> {
  DatabaseService db = DatabaseService();

  Future<List<User>> fetchUsers;

  bool isFollowersPage;
  fetData() async {
    await Future.delayed(Duration.zero, () {
      setState(() {
        isFollowersPage =
            ModalRoute.of(context).settings.name == '/followers' ? true : false;
      });

      fetchUsers = isFollowersPage
          // ? db.getFollowers(widget.uid)
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .collection('followers')
              .get()
              .then((value) =>
                  value.docs.map((doc) => User.fromSnapShot(doc)).toList())
          : db.getFollowing(widget.uid);
    });
  }

  @override
  void initState() {
    super.initState();
    fetData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ModalRoute.of(context).settings.name == '/followers'
            ? 'Followers'
            : 'Following'),
      ),
      body: Consumer(builder: (context, watch, child) {
        final _authState = watch(authStateProvider);

        return FutureBuilder(
            future: fetchUsers,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<User> users = snapshot.data;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: ProfileImage(
                        context: context,
                        ownerId: users[index].uid,
                        currentUserId: widget.uid,
                        photoUrl: users[index].photoUrl,
                        size: 22,
                      ),
                      title: Text(
                        '${users[index].name}',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: users[index].uid != _authState.data.value.uid
                          ? Container(
                              width: 100,
                              child: FutureBuilder(
                                  future: db.isFollowing(users[index].uid,
                                      _authState.data.value.uid),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      // ignore: unused_local_variable
                                      bool isFollowing = snapshot.data;

                                      return Container(
                                          child: snapshot.data
                                              ? ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    // minimumSize: Size(30, 35),
                                                    primary: Theme.of(context)
                                                        .accentColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      // side: buttonType == 2
                                                      //   // ? BorderSide(color: Theme.of(context).accentColor, width: 1)
                                                      //   //     : BorderSide.none
                                                      // ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    User user = await db
                                                        .getUser(_authState
                                                            .data.value.uid);
                                                    await db.unfollow(
                                                        users[index].uid, user);
                                                    setState(() {
                                                      isFollowing = false;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Following',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                )
                                              : ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize: Size(30, 35),
                                                    primary: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        side: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor,
                                                            width: 1)
                                                        //   //     : BorderSide.none
                                                        // ),
                                                        ),
                                                  ),
                                                  onPressed: () async {
                                                    User user = await db
                                                        .getUser(_authState
                                                            .data.value.uid);
                                                    await db.follow(
                                                        users[index].uid, user);
                                                    setState(() {
                                                      isFollowing = true;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Follow',
                                                    style:
                                                        TextStyle(fontSize: 14),
                                                  ),
                                                ));
                                    } else {
                                      return Container(width: 10);
                                    }
                                  }),
                            )
                          : Container(
                              width: 10,
                            ),
                    );
                  },
                );
              } else {
                return circleIndicator(context);
              }
            });
      }),
    );
  }
}
