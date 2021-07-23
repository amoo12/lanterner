import 'package:auto_direction/auto_direction.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lanterner/controllers/translationController.dart';
import 'package:lanterner/models/message.dart';
import 'package:lanterner/pages/chats/chatScreen.dart';
import 'package:lanterner/widgets/postCard.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'audioPlayerWidget.dart';

class ChatMessage extends StatefulWidget {
  Message message;
  final String uid;
  ChatMessage({Key key, this.message, this.uid}) : super(key: key);

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  TranslationController translator = TranslationController();

  bool translated = false;
  bool loading = false;
  String translation;

  @override
  void initState() {
    super.initState();
    if (widget.message.translation != null) {
      translated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          if (widget.message.type == 'text' &&
              widget.message.translation == null) {
            setState(() {
              loading = true;
            });
            await translator
                .translate(
                    textTotrasnlate: widget.message.content,
                    uid: widget.uid,
                    message: widget.message)
                .then((value) {
              setState(() {
                widget.message.translation = value.text;
                loading = false;
                translated = true;
              });
            });
          }
        },
        onLongPress: () async {
          if (widget.message.senderId == widget.uid) {
            // await showBarModalBottomSheet(
            //   barrierColor: Colors.black.withOpacity(0.3),
            //   expand: false,
            //   context: context,
            //   builder: (context) => Container(
            //     height: 100,
            //     padding: EdgeInsets.symmetric(vertical: 20),
            //     decoration: BoxDecoration(
            //         borderRadius: BorderRadius.only(
            //             topLeft: Radius.circular(8),
            //             topRight: Radius.circular(8))),
            //     child: ListView(
            //       children: [
            //         ListTile(
            //           leading: Icon(Icons.delete),
            //           title: Text('Delete'),
            //           onTap: () async {
            //             //detlte comment from db
            //             // await .db.deleteCommetn(
            //             //     widget.post.postId,
            //             //     comments[index]);

            //             // setState(() {
            //               // delete comment from the temp provider list
            //               // context
            //               //     .read(commentProvider
            //               //         .notifier)
            //               //     .remove(
            //               //         comments[index]);
            //               // remove comment from the local list.
            //               // comments.remove(
            //               //     comments[index]);
            //               // Navigator.pop(context);
            //             // });
            //           },
            //         ),
            //       ],
            //     ),
            //   ),
            // );
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: widget.message.senderId == widget.uid
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              widget.message.type == 'text'
                  ? Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 15.0),
                      decoration: widget.message.senderId == widget.uid
                          ? BoxDecoration(
                              color: Color(0xff56B7D7),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(50),
                                  topLeft: Radius.circular(50),
                                  topRight: Radius.circular(50)),
                            )
                          : BoxDecoration(
                              color: Color(0xFF353A50),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(50),
                                  bottomRight: Radius.circular(50),
                                  topRight: Radius.circular(50)),
                            ),
                      child: Column(
                        children: [
                          AutoDirection(
                            text: widget.message.content,
                            child: Text(
                              widget.message.content,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          loading
                              ? CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                )
                              : Container(
                                  height: 0,
                                  width: 0,
                                ),
                          translated
                              ? widget.message.translation != null
                                  ? Container(
                                      child: Column(
                                        children: [
                                          Divider(),
                                          AutoDirection(
                                            text: widget.message.translation !=
                                                    null
                                                ? widget.message.translation
                                                : '',
                                            child: Text(
                                              widget.message.translation != null
                                                  ? widget.message.translation
                                                  : '',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height: 0,
                                      width: 0,
                                    )
                              : Container(height: 0, width: 0),
                        ],
                      ),
                    )
                  : widget.message.type == 'image'
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: widget.message.senderId == widget.uid
                                ? Color(0xff56B7D7)
                                : Color(0xFF353A50),
                          ),
                          padding: EdgeInsets.all(3),
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(9.0),
                                child: GestureDetector(
                                    onTap: () {
                                      pushNewScreenWithRouteSettings(
                                        context,
                                        settings:
                                            RouteSettings(name: '/imageViewer'),
                                        screen: ImageViewer(
                                            photoUrl: widget.message.content),
                                        pageTransitionAnimation:
                                            PageTransitionAnimation.cupertino,
                                        withNavBar: false,
                                      );
                                    },
                                    child: Container(
                                      // width: 200,
                                      constraints: BoxConstraints(
                                          maxHeight: 300, maxWidth: 300),
                                      child: ShaderMask(
                                        shaderCallback: (rect) {
                                          return LinearGradient(
                                            begin: Alignment.center,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.3),
                                            ],
                                          ).createShader(Rect.fromLTRB(
                                              0, 0, rect.width, rect.height));
                                        },
                                        blendMode: BlendMode.darken,
                                        child: CachedNetworkImage(
                                          fit: BoxFit.fitWidth,
                                          imageUrl: widget.message.content,
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    )),
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(0, 1, 10, 0),
                                    child: Text(
                                      getChatTime(widget.message.timeStamp),
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 10.0,
                                        // fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : widget.message.type == 'audio'
                          ? AudioFile(
                              message: widget.message,
                              uid: widget.uid,
                            )
                          : Container(),
              widget.message.type != 'image'
                  ? Text(
                      getChatTime(widget.message.timeStamp),
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 10.0,
                        // fontWeight: FontWeight.w600,
                      ),
                    )
                  : Container(),
            ],
          ),
        ));
  }
}
