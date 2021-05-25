import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/comment.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/customTextField.dart';
import 'package:lanterner/widgets/postCard.dart';
import 'package:lanterner/widgets/progressIndicator.dart';

class Comments extends StatelessWidget {
  Comments({Key key, this.postId}) : super(key: key);
  final String postId;

  DatabaseService db = DatabaseService();
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: db.getPost(postId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Post post = snapshot.data;
            return Scaffold(
              appBar: AppBar(),
              body: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(children: [
                      PostCard(post),
                      FutureBuilder<List<Comment>>(
                          future: db.getCommetns(postId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<Comment> comments = snapshot.data;

                              return ConstrainedBox(
                                constraints: BoxConstraints(minHeight: 500),
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  // if (widget.post.ownerId ==
                                                  //     _authState.data.value.uid) {
                                                  //   pushNewScreenWithRouteSettings(
                                                  //     context,
                                                  //     settings: RouteSettings(name: '/myProfile'),
                                                  //     screen: MyProfile(),
                                                  //     pageTransitionAnimation:
                                                  //         PageTransitionAnimation.slideUp,
                                                  //     withNavBar: false,
                                                  //   );
                                                  // } else {
                                                  //   // pushNewScreenWithRouteSettings(context, screen: screen, settings: settings)
                                                  //   if (ModalRoute.of(context).settings.name !=
                                                  //       '/profile') {
                                                  //     pushNewScreenWithRouteSettings(
                                                  //       context,
                                                  //       settings: RouteSettings(name: '/profile'),
                                                  //       screen: Profile(uid: widget.post.ownerId),
                                                  //       pageTransitionAnimation:
                                                  //           PageTransitionAnimation.slideUp,
                                                  //       withNavBar: false,
                                                  //     );
                                                  //   }
                                                  // }
                                                },
                                                child: CircleAvatar(
                                                  radius: 22,
                                                  backgroundImage: comments[
                                                                  index]
                                                              .user
                                                              .photoUrl !=
                                                          null
                                                      ? NetworkImage(
                                                          comments[index]
                                                              .user
                                                              .photoUrl,
                                                        )
                                                      : NetworkImage(
                                                          'https://via.placeholder.com/150'),
                                                  child: comments[index]
                                                              .user
                                                              .photoUrl ==
                                                          null
                                                      ? Icon(Icons.person,
                                                          size: 40,
                                                          color: Colors.grey)
                                                      : Container(),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${comments[index].user.name}',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                      Text(
                                                        '${comments[index].text}',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Divider(
                                          //   color: Colors.grey[700],
                                          //   thickness: 0.1,
                                          //   // height: 1,
                                          // )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text("ERROR: Someting went wrong");
                            } else {
                              return circleIndicator(context);
                            }
                          }),
                    ]),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: CommentField(
                        postId: postId,
                      ))
                ],
              ),
            );
          } else {
            return circleIndicator(context);
          }
        });
  }
}

class CommentField extends StatefulWidget {
  final postId;
  const CommentField({Key key, @required this.postId}) : super(key: key);

  @override
  _CommentFieldState createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  TextEditingController commentController = TextEditingController();
  DatabaseService db;
  String text = "";
  comment(String currentUserId) async {
    if (commentController.text.trim().isNotEmpty) {
      User user = await db.getUser(currentUserId);

      db.comment(
          widget.postId,
          Comment(
              text: commentController.text.trim(),
              user: user,
              createdAt: DateTime.now().toString()));

      commentController.clear();
    }
  }

  @override
  void initState() {
    db = DatabaseService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final _authState = watch(authStateProvider);

      return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 10),
        color: Theme.of(context).cardColor,
        constraints: BoxConstraints(minHeight: 60, maxHeight: 110),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: MediaQuery.of(context).size.width * 0.8,
                child: AutoDirection(
                  text: text,
                  child: TextFormField(
                    cursorColor: Colors.white,

                    // expands: widget.expands,
                    keyboardType: TextInputType.multiline,

                    maxLines: null,

                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Comment...',
                      hintStyle: TextStyle(color: Colors.grey),
                      labelStyle: TextStyle(color: Colors.white),
                      focusColor: Colors.white,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    controller: commentController,

                    onChanged: (value) {
                      setState(() {
                        text = value;
                      });
                    },
                  ),
                ),
              ),
            ),
            Container(
                height: 50,
                width: 50,
                margin: EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                    color: commentController.text.trim().isNotEmpty
                        ? Theme.of(context).accentColor
                        : Theme.of(context).accentColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(50)),
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      color: commentController.text.trim().isNotEmpty
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                    onPressed: commentController.text.trim().isNotEmpty
                        ? () {
                            comment(_authState.data.value.uid);
                          }
                        : null,
                  ),
                ))
          ],
        ),
      );
    });
  }
}
