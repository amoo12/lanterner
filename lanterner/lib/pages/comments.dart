import 'package:auto_direction/auto_direction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/comment.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/pages/myProfile.dart';
import 'package:lanterner/pages/profile.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/postCard.dart';
import 'package:lanterner/widgets/progressIndicator.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class Comments extends StatelessWidget {
  Comments({Key key, this.postId}) : super(key: key);
  final String postId;

  TextEditingController commentController = TextEditingController();
  Comment comment = Comment();

  @override
  Widget build(BuildContext context) {
    DatabaseService db = DatabaseService(postId: postId);
    return FutureBuilder(
        future: db.getPost(postId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Post post = snapshot.data;
            return Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              appBar: AppBar(),
              body: Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(children: [
                      PostCard(post),
                      CommentsListView(db: db, postId: postId),
                    ]),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: CommentField(
                        comment: comment,
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

class CommentsListView extends StatefulWidget {
  const CommentsListView({
    Key key,
    @required this.db,
    @required this.postId,
  }) : super(key: key);

  final DatabaseService db;
  final String postId;

  @override
  _CommentsListViewState createState() => _CommentsListViewState();
}

class _CommentsListViewState extends State<CommentsListView> {
  Future<List<Comment>> fetchComments;
  // Stream<List<Comment>> fetchComments;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchComments = widget.db.getCommetns(widget.postId);
    // fetchComments = widget.db.commetns;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final _authState = watch(authStateProvider);

        return FutureBuilder<List<Comment>>(
            future: fetchComments,
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
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print(comments[index].user.uid);
                                    if (comments[index].user.uid ==
                                        _authState.data.value.uid) {
                                      pushNewScreenWithRouteSettings(
                                        context,
                                        settings:
                                            RouteSettings(name: '/myProfile'),
                                        screen: MyProfile(),
                                        pageTransitionAnimation:
                                            PageTransitionAnimation.slideUp,
                                        withNavBar: false,
                                      );
                                    } else {
                                      // pushNewScreenWithRouteSettings(context, screen: screen, settings: settings)
                                      if (ModalRoute.of(context)
                                              .settings
                                              .name !=
                                          '/profile') {
                                        pushNewScreenWithRouteSettings(
                                          context,
                                          settings:
                                              RouteSettings(name: '/profile'),
                                          screen: Profile(
                                              uid: comments[index].user.uid),
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.slideUp,
                                          withNavBar: false,
                                        );
                                      }
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundImage: comments[index]
                                                .user
                                                .photoUrl !=
                                            null
                                        ? NetworkImage(
                                            comments[index].user.photoUrl,
                                          )
                                        : NetworkImage(
                                            'https://via.placeholder.com/150'),
                                    child: comments[index].user.photoUrl == null
                                        ? Icon(Icons.person,
                                            size: 40, color: Colors.grey)
                                        : Container(),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${comments[index].user.name}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        AutoDirection(
                                          text: '${comments[index].text}',
                                          child: InkWell(
                                            onTap: () {},
                                            child: Container(
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      '${comments[index].text}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    '${comments[index].ago()}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
            });
      },
    );
  }
}

class CommentField extends StatefulWidget {
  final postId;
  Comment comment;
  CommentField({Key key, @required this.postId, this.comment})
      : super(key: key);

  @override
  _CommentFieldState createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  TextEditingController commentController = TextEditingController();
  DatabaseService db;
  String text = "";
  comment(String currentUserId) async {
    if (commentController.text.trim().isNotEmpty) {
      DateTime createdAt = DateTime.now();
      Timestamp timestamp = Timestamp.fromDate(createdAt);
      User user = await db.getUser(currentUserId);

      widget.comment = Comment();
      widget.comment.text = commentController.text.trim();
      widget.comment.user = user;
      widget.comment.createdAt = createdAt.toString();
      widget.comment.timestamp = timestamp;
      db.comment(widget.postId, widget.comment);

      commentController.clear();
      FocusScope.of(context).unfocus();
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
