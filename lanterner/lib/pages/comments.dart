import 'package:auto_direction/auto_direction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/comment.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/providers/comments_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/circleAvatar.dart';
import 'package:lanterner/widgets/postCard.dart';
import 'package:lanterner/widgets/progressIndicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// ignore: must_be_immutable
class Comments extends StatelessWidget {
  Comments({Key key, this.postId}) : super(key: key);
  final String postId;

  // TextEditingController commentController = TextEditingController();
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
                      CommentsListView(db: db, post: post),
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
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Text("ERROR: Someting went wrong");
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
    @required this.post,
  }) : super(key: key);

  final DatabaseService db;
  final Post post;

  @override
  _CommentsListViewState createState() => _CommentsListViewState();
}

class _CommentsListViewState extends State<CommentsListView> {
  Future<List<Comment>> fetchComments;

  @override
  void initState() {
    super.initState();
    fetchComments = widget.db.getCommetns(widget.post.postId);
  }

  @override
  void dispose() {
    super.dispose();
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
                return Consumer(builder: (context, watch, child) {
                  // a local list to combine comments from the snapshot as well as the provider
                  // comments coming from the provider are only the ones added during this build of the current build of the widget
                  // if initState is called the provider is disposed and cleared from comments.
                  List<Comment> comments = watch(commentProvider).length == 0
                      ? snapshot.data
                      : [...snapshot.data, ...watch(commentProvider)];
                  return ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 500),
                    child: Container(
                      padding: EdgeInsets.only(bottom: 60),
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            child: Column(
                              children: [
                                InkWell(
                                  onLongPress: () async {
                                    if (_authState.data.value.uid ==
                                            comments[index].user.uid ||
                                        _authState.data.value.uid ==
                                            widget.post.user.uid) {
                                      await showBarModalBottomSheet(
                                        barrierColor:
                                            Colors.black.withOpacity(0.3),
                                        expand: false,
                                        context: context,
                                        builder: (context) => Container(
                                          height: 100,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  topRight:
                                                      Radius.circular(8))),
                                          child: ListView(
                                            children: [
                                              ListTile(
                                                leading: Icon(Icons.delete),
                                                title: Text('Delete'),
                                                onTap: () async {
                                                  //detlte comment from db
                                                  await widget.db.deleteCommetn(
                                                      widget.post.postId,
                                                      comments[index]);

                                                  setState(() {
                                                    // delete comment from the temp provider list
                                                    context
                                                        .read(commentProvider
                                                            .notifier)
                                                        .remove(
                                                            comments[index]);
                                                    // remove comment from the local list.
                                                    comments.remove(
                                                        comments[index]);
                                                    Navigator.pop(context);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ProfileImage(
                                          currentUserId:
                                              _authState.data.value.uid,
                                          ownerId: comments[index].user.uid,
                                          photoUrl:
                                              comments[index].user.photoUrl,
                                          size: 22,
                                          context: context),
                                      Expanded(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
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
                                                  // onTap: () {},
                                                  child: Container(
                                                    child: Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            '${comments[index].text}',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
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
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                });
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Text("ERROR: Someting went wrong");
              } else {
                return circleIndicator(context);
              }
            });
      },
    );
  }
}

// ignore: must_be_immutable
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
  Comment com = Comment();

  comment(String currentUserId) async {
    if (commentController.text.trim().isNotEmpty) {
      DateTime createdAt = DateTime.now();
      Timestamp timestamp = Timestamp.fromDate(createdAt);
      User user = await db.getUser(currentUserId);

      com = Comment(
          user: user,
          text: commentController.text.trim(),
          createdAt: createdAt.toString(),
          timestamp: timestamp);
      db.comment(widget.postId, com);
      commentController.clear();
    }
  }

  @override
  void initState() {
    db = DatabaseService();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                        ? () async {
                            FocusScope.of(context).unfocus();

                            await comment(_authState.data.value.uid);
                            context.read(commentProvider.notifier).add(com);

                            // confirmation snackbar
                            SnackBar registrationBar = SnackBar(
                              duration: Duration(milliseconds: 300),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.height * 0.15,
                                  left:
                                      MediaQuery.of(context).size.width * 0.09,
                                  right:
                                      MediaQuery.of(context).size.width * 0.09),
                              content: Text(
                                'comment posted',
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(registrationBar);
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
