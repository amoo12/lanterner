import 'package:auto_direction/auto_direction.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/controllers/translationController.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/pages/comments.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/providers/posts_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/circleAvatar.dart';
import 'package:lanterner/widgets/languageIndicator.dart';
import 'package:lanterner/widgets/progressIndicator.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

import 'package:translator/translator.dart';

var logger = Logger();

class PostCard extends StatefulWidget {
  final herotag;
  final Post post;
  const PostCard({this.post, @required this.herotag, Key key})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isRTL;

  TranslationController translator = TranslationController();
  String firstHalf;
  String secondHalf;

  bool flag = true;

  translationBottomSheet(String textTotrasnlate, String uid) {
    showBarModalBottomSheet(
      enableDrag: false,
      useRootNavigator: true,
      barrierColor: Colors.black.withOpacity(0.3),
      expand: false,
      bounce: true,
      context: context,
      builder: (context) => Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20, 20, 20, 2),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8))),
        child: FutureBuilder(
            // future: translator.translate(
            //     textTotrasnlate: textTotrasnlate, uid: uid),

            future: translator.translate(
                textTotrasnlate: textTotrasnlate, uid: uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Translation translation = snapshot.data;
                return Column(
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Translated from ',
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            translation.sourceLanguage.name,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.2),
                      child: SingleChildScrollView(
                        child: Container(
                          color: Theme.of(context).cardColor,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: AutoDirection(
                                text: translation.text,
                                child: Text(
                                  translation.text,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(color: Colors.white),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Text("ERROR: Someting went wrong");
              } else {
                return circleIndicator(context, Theme.of(context).cardColor);
              }
            }),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  splitCaption(String text) {
    if (text.length > 100) {
      firstHalf = text.substring(0, 100);
      secondHalf = text.substring(100, text.length);
    } else {
      firstHalf = text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    splitCaption(widget.post.caption);

    return Consumer(builder: (context, watch, child) {
      final _authState = watch(authStateProvider);

      return Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 1,
          child: InkWell(
            highlightColor: Theme.of(context).backgroundColor,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              if (ModalRoute.of(context).settings.name != '/comments') {
                pushNewScreenWithRouteSettings(
                  context,
                  settings: RouteSettings(name: '/comments'),
                  screen: Comments(
                    herotag: widget.herotag != null ? widget.herotag : '',
                    post: widget.post,
                  ),
                  pageTransitionAnimation: PageTransitionAnimation.fade,
                  withNavBar: false,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                ProfileImage(
                                    ownerId: widget.post.user.uid,
                                    currentUserId: _authState.data.value.uid,
                                    photoUrl: widget.post.user.photoUrl,
                                    size: 22,
                                    context: context),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 44,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${widget.post.user.name}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[400],
                                          fontWeight: FontWeight.w500),
                                    ),
                                    widget.post.user.admin
                                        ? Container(
                                            padding: EdgeInsets.only(left: 6),
                                            child: Icon(
                                              Icons.verified,
                                              color: Colors.tealAccent,
                                              // Color(
                                              //     0xffFFD700),
                                              size: 14,
                                            ),
                                          )
                                        : SizedBox()
                                  ],
                                ),
                                Container(
                                  // width: 60,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      languageIndictor(
                                          widget.post.user.nativeLanguage),
                                      Transform.rotate(
                                        angle: 180 * math.pi / 180,
                                        child: Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.grey,
                                          size: 10,
                                        ),
                                      ),
                                      languageIndictor(
                                          widget.post.user.targetLanguage),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(widget.post.ago(),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  GestureDetector(
                    onTap: () {},
                    child: AutoDirection(
                      onDirectionChange: (isRTL) {
                        setState(() {
                          this.isRTL = isRTL;
                        });
                      },
                      text: widget.post.caption != null
                          ? widget.post.caption
                          : '',
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: secondHalf.isEmpty
                            ? SelectableText(
                                firstHalf,
                                onTap: () {
                                  translationBottomSheet(
                                      firstHalf,
                                      context
                                          .read(authStateProvider)
                                          .data
                                          .value
                                          .uid);
                                },
                                style: TextStyle(color: Colors.white),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SelectableText(
                                    flag
                                        ? (firstHalf + "...")
                                        : (firstHalf + secondHalf),
                                    onTap: () {
                                      if (flag) {
                                        setState(() {
                                          flag = !flag;
                                        });
                                      } else {
                                        translationBottomSheet(
                                            widget.post.caption,
                                            context
                                                .read(authStateProvider)
                                                .data
                                                .value
                                                .uid);
                                      }
                                    },
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  InkWell(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          flag ? "show more" : "show less",
                                          style: TextStyle(
                                              color: Colors.grey[350],
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      setState(() {
                                        flag = !flag;
                                      });
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  // media
                  widget.post.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: GestureDetector(
                            onTap: () {
                              pushNewScreenWithRouteSettings(
                                context,
                                settings: RouteSettings(name: '/imageViewer'),
                                screen:
                                    ImageViewer(photoUrl: widget.post.photoUrl),
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                                withNavBar: false,
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: CachedNetworkImage(
                                height: 180,
                                fit: BoxFit.fitWidth,
                                imageUrl: widget.post.photoUrl,
                                placeholder: (context, url) => Container(
                                    color: Colors.grey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.photo,
                                          color: Colors.grey[400],
                                          size: 60,
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.grey[400]),
                                          ),
                                        ),
                                      ],
                                    )),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                        )
                      : Container(),

                  PostCardFooter(
                    post: widget.post,
                    currentUserID: _authState.data.value.uid,
                    parentContext: context,
                    herotag: widget.herotag,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// TODO : convert to a stateless Widget
class ImageViewer extends StatefulWidget {
  final String photoUrl;

  const ImageViewer({
    Key key,
    this.photoUrl,
  }) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: Center(
          child: GestureDetector(
            onVerticalDragEnd: (drag) {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              child: CachedNetworkImage(
                fit: BoxFit.fitWidth,
                imageUrl: widget.photoUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              maxScale: 4,
              minScale: .1,
              panEnabled: true,
              constrained: true,
              scaleEnabled: true,
            ),
          ),
        ),
      ),
    );
  }
}

class PostCardFooter extends StatefulWidget {
  Post post;
  final String currentUserID;
  final BuildContext parentContext;
  final String herotag;

  PostCardFooter(
      {Key key,
      this.post,
      this.currentUserID,
      this.parentContext,
      this.herotag})
      : super(key: key);

  @override
  _PostCardFooterState createState() => _PostCardFooterState();
}

class _PostCardFooterState extends State<PostCardFooter> {
  bool isLiked;
  // final GlobalKey<CommentCountState> _key = GlobalKey();
  var isSaved = false;

  Stream<DocumentSnapshot> freshPost;
  Future<DocumentSnapshot> freshPostComment;
  final DatabaseService db = DatabaseService();
  int likeCountForTimelinePosts = 0;
  int commentCountForTimelinePosts = 0;

  Future<void> like() async {
    if (isLiked == false) {
      setState(() {
        isLiked = true;
        widget.post.likeCount++;
        likeCountForTimelinePosts++;
      });
      return await db.likePost(widget.post, widget.currentUserID, isLiked);
    } else if (isLiked == true) {
      setState(() {
        isLiked = false;
        widget.post.likeCount--;
        likeCountForTimelinePosts--;
        // likeCountForTimelinePosts--;
        //  widget.post.likeCount == 0
        //     ? widget.post.likeCount
        //     :
      });
      return await db.likePost(widget.post, widget.currentUserID, isLiked);
    }
  }

  void savePost() {
    setState(() {
      isSaved = !isSaved;
    });
  }

  Stream<DocumentSnapshot> fetchPost() {
    DocumentReference ref =
        FirebaseFirestore.instance.collection('posts').doc(widget.post.postId);

    return ref.snapshots();
  }

//  only checks for the first time the post is loaded then we user the stream
  heckIsliked() async {
    isLiked = await db.isLikedF(widget.post, widget.currentUserID);
    if (widget.herotag == 'follwingPosts-to-comments') {
      widget.post = await db.getPost(widget.post.postId);
    }
  }

  @override
  void initState() {
    super.initState();
    heckIsliked();
    freshPost = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.99,
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  LikeButton(
                    currentUserID: widget.currentUserID,
                    post: widget.post,
                    like: like,
                    isLiked: isLiked,
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: widget.herotag == 'follwingPosts-to-comments'
                          ? StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(widget.post.postId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  widget.post.commmentCount =
                                      snapshot.data.data()['commmentCount'];

                                  widget.post.likeCount =
                                      snapshot.data.data()['likeCount'] +
                                          likeCountForTimelinePosts;

                                  return Text(
                                    widget.post.likeCount.toString() ?? '0',
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 10),
                                  );
                                } else {
                                  return Text(
                                    '0',
                                    // snapshot.data.data()['likeCount'].toString(),
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 10),
                                  );
                                }
                              })
                          : Text(
                              widget.post.likeCount.toString(),
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 10),
                            ),
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.comment,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onPressed: () {
                      if (ModalRoute.of(context).settings.name != '/comments') {
                        pushNewScreenWithRouteSettings(
                          context,
                          settings: RouteSettings(name: '/comments'),
                          screen: Comments(
                            herotag: widget.herotag,
                            post: widget.post,
                          ),
                          pageTransitionAnimation: PageTransitionAnimation.fade,
                          withNavBar: false,
                        );
                      }
                    },
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: CommentCount(widget: widget),
                    ),
                  ),
                ],
              ),
              // isSaved
              //     ? IconButton(
              //         icon: Icon(
              //           Icons.bookmark,
              //           color: Colors.grey[400],
              //           size: 20,
              //         ),
              //         onPressed: savePost,
              //       )
              //     : IconButton(
              //         icon: Icon(
              //           Icons.bookmark_outline,
              //           color: Colors.grey[400],
              //           size: 20,
              //         ),
              //         onPressed: savePost,
              //       ),
            ],
          ),
          Container(
            child: IconButton(
              icon: Icon(
                Icons.more_vert_outlined,
                color: Colors.grey[400],
                size: 20,
              ),
              onPressed: () async {
                User user = await context.read(userProvider.future);
                print(user.toString());
                if (widget.currentUserID == widget.post.user.uid ||
                    user.admin) {
                  showBarModalBottomSheet(
                    useRootNavigator: true,
                    barrierColor: Colors.black.withOpacity(0.3),
                    expand: false,
                    context: context,
                    builder: (context) => Container(
                      height: 100,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8))),
                      child: ListView(
                        children: [
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                            onTap: () async {
                              if (ModalRoute.of(widget.parentContext)
                                      .settings
                                      .name ==
                                  '/comments') {
                                //detlte post from db
                                await db.deletePost(widget.post);

                                Navigator.pop(context);
                                Navigator.pop(context, widget.post);
                              } else {
                                //detlte post from db
                                await db.deletePost(widget.post);

                                // delete the post from provider to trigger rebuild
                                context.read(postProvider).remove(widget.post);
                              }
                              context
                                  .read(followingPostProvider)
                                  .remove(widget.post);

                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CommentCount extends StatefulWidget {
  const CommentCount({
    Key key,
    @required this.widget,
  }) : super(key: key);

  final PostCardFooter widget;

  @override
  CommentCountState createState() => CommentCountState();
}

class CommentCountState extends State<CommentCount> {
  updateCount() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateCount();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.widget.post.commmentCount.toString(),
      style: TextStyle(color: Colors.grey[400], fontSize: 10),
    );
  }
}

class LikeButton extends StatefulWidget {
  var like;
  Post post;
  String currentUserID;
  bool isLiked;
  LikeButton({Key key, this.like, this.post, this.currentUserID, this.isLiked})
      : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  Stream<bool> likeStream;
  fetchLikeState() async {
    likeStream = db.isLiked(widget.post, widget.currentUserID);
  }

  @override
  void initState() {
    super.initState();
    fetchLikeState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: likeStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox();
          }
          widget.isLiked = snapshot.data;
          return Container(
            child: TapDebouncer(
              cooldown: const Duration(milliseconds: 500),
              onTap: () async {
                await widget.like();
              },
              builder: (context, onTap) => IconButton(
                icon: Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_outline,
                  color: widget.isLiked ? Colors.pink : Colors.grey[400],
                  size: 20,
                ),
                onPressed: onTap,
              ),
            ),
          );
        });
  }
}
