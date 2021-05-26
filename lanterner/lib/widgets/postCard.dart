import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/pages/comments.dart';
import 'package:lanterner/pages/myProfile.dart';
import 'package:lanterner/pages/profile.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard(this.post, {Key key}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isRTL;

  String firstHalf;
  String secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();
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
                  screen: Comments(postId: widget.post.postId),
                  pageTransitionAnimation: PageTransitionAnimation.slideUp,
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
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (widget.post.ownerId ==
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
                                    if (ModalRoute.of(context).settings.name !=
                                        '/profile') {
                                      pushNewScreenWithRouteSettings(
                                        context,
                                        settings:
                                            RouteSettings(name: '/profile'),
                                        screen:
                                            Profile(uid: widget.post.ownerId),
                                        pageTransitionAnimation:
                                            PageTransitionAnimation.slideUp,
                                        withNavBar: false,
                                      );
                                    }
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: widget.post.userPhotoUrl !=
                                          null
                                      ? NetworkImage(
                                          widget.post.userPhotoUrl,
                                        )
                                      : NetworkImage(
                                          'https://via.placeholder.com/150'),
                                  child: widget.post.userPhotoUrl == null
                                      ? Icon(Icons.person,
                                          size: 40, color: Colors.grey)
                                      : Container(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.post.username}',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              Text(
                                'username',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
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
                    onTap: () {
                      //TODO: Translete
                    },
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
                        padding: new EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: secondHalf.isEmpty
                            ? new Text(
                                firstHalf,
                                style: TextStyle(color: Colors.white),
                              )
                            : new Column(
                                children: <Widget>[
                                  new Text(
                                    flag
                                        ? (firstHalf + "...")
                                        : (firstHalf + secondHalf),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  new InkWell(
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        new Text(
                                          flag ? "show more" : "show less",
                                          style: new TextStyle(
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
                                  screen: ImageViewer(
                                      photoUrl: widget.post.photoUrl),
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                  withNavBar: false,
                                );
                              },
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Image.network(
                                    widget.post.photoUrl,
                                    height: 180,
                                    // centerSlice: Rect,
                                    fit: BoxFit.fitWidth,
                                  ))),
                        )
                      : Container(),

                  PostCardFooter(postId: widget.post.postId),
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
              child: Image.network(widget.photoUrl),
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
  final postId;

  const PostCardFooter({Key key, this.postId}) : super(key: key);

  @override
  _PostCardFooterState createState() => _PostCardFooterState();
}

class _PostCardFooterState extends State<PostCardFooter> {
  bool isLiked = false;

  var isSaved = false;

  void like() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  void savePost() {
    setState(() {
      isSaved = !isSaved;
    });
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
              isLiked
                  ? IconButton(
                      icon: Icon(
                        Icons.favorite_outline,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: like,
                    )
                  : IconButton(
                      icon: Icon(Icons.favorite, color: Colors.pink, size: 20),
                      onPressed: like,
                    ),
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
                      screen: Comments(postId: widget.postId),
                      pageTransitionAnimation: PageTransitionAnimation.slideUp,
                      withNavBar: false,
                    );
                  }
                },
              ),
              isSaved
                  ? IconButton(
                      icon: Icon(
                        Icons.bookmark,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: savePost,
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.bookmark_outline,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: savePost,
                    ),
            ],
          ),
          Container(
            child: IconButton(
              icon: Icon(
                Icons.more_vert_outlined,
                color: Colors.grey[400],
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
