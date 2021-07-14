import 'package:auto_direction/auto_direction.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lanterner/controllers/uploadPhoto.dart';
import 'package:lanterner/models/message.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/providers/messages_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/postCard.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatelessWidget {
  final User peer;
  ChatRoom({Key key, this.peer}) : super(key: key);

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    //! TODO: if the user is recived from the chatList page it only contains name,uid & photoUrl
    final User user = ModalRoute.of(context).settings.arguments ?? peer;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xff181E30),
      appBar: AppBar(
        title: Text('${user.name}'),
      ),
      body: ChatScreen(peer: user, scaffoldKey: _scaffoldKey),
    );
  }
}

class ChatScreen extends StatefulWidget {
  GlobalKey<ScaffoldState> scaffoldKey;
  final User peer;
  ChatScreen({
    Key key,
    this.scaffoldKey,
    this.peer,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ScrollController listScrollController;

  int _limit = 20;
  final int _limitIncrement = 20;

  MessagesState chatState;
  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    listScrollController = ScrollController();
    listScrollController.addListener(_scrollListener);

    context.read(authStateProvider).data.value.uid;
    context.read(messagesProvider.notifier).getMessages(
        context.read(authStateProvider).data.value.uid, widget.peer.uid);
    context.read(messagesProvider.notifier).getchatDetailAsync(
        context.read(authStateProvider).data.value.uid, widget.peer.uid);
  }

  @override
  void dispose() {
    listScrollController.dispose();

    super.dispose();
  }

  Future<bool> _onWillPop() async {
    context.read(messagesProvider.notifier).onChatScreenClosed();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer(
        builder: (context, watch, child) {
          final _authState = watch(authStateProvider);
          List<Message> messages = watch(messagesProvider).messageList ?? [];

          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: ListView.builder(
                    controller: listScrollController,
                    reverse: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return chatMessage(
                          context, messages[index], _authState.data.value.uid);
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ChatTextField(
                    uid: _authState.data.value.uid,
                    peer: widget.peer,
                    scaffoldKey: widget.scaffoldKey),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget chatMessage(BuildContext context, Message message, String uid) {
    return GestureDetector(
        onLongPress: () async {
          if (message.senderId == uid) {
            await showBarModalBottomSheet(
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
                        //detlte comment from db
                        // await .db.deleteCommetn(
                        //     widget.post.postId,
                        //     comments[index]);

                        setState(() {
                          // delete comment from the temp provider list
                          // context
                          //     .read(commentProvider
                          //         .notifier)
                          //     .remove(
                          //         comments[index]);
                          // remove comment from the local list.
                          // comments.remove(
                          //     comments[index]);
                          // Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: message.senderId == uid
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            // mainAxisAlignment: message.senderId == uid
            //     ? MainAxisAlignment.end
            //     : MainAxisAlignment.start,
            children: [
              message.type == 'text'
                  ? Container(
                      // width: 80,
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.85,
                        // minWidth: 30
                      ),
                      // width: 300,
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 15.0),
                      // width: MediaQuery.of(context).size.width * 0.75,
                      decoration: message.senderId == uid
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
                          Text(
                            message.content,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : message.type == 'image'
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: message.senderId == uid
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
                                            photoUrl: message.content),
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
                                          imageUrl: message.content,
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
                                      getChatTime(message.timeStamp),
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
                      : message.type == 'audio'
                          ? Container()
                          : Container(),
              message.type != 'image'
                  ? Text(
                      getChatTime(message.timeStamp),
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 10.0,
                        // fontWeight: FontWeight.w600,
                      ),
                    )
                  : Container()
            ],
          ),
        ));
  }
}

//helper
String getChatTime(String date) {
  if (date == null || date.isEmpty) {
    return '';
  }
  String msg = '';
  var dt = DateTime.parse(date).toLocal();

  if (DateTime.now().toLocal().isBefore(dt)) {
    return DateFormat.jm().format(DateTime.parse(date).toLocal()).toString();
  }

  var dur = DateTime.now().toLocal().difference(dt);
  if (dur.inDays > 0) {
    msg = '${dur.inDays} d';
    return dur.inDays == 1 ? '1d' : DateFormat("dd MMM hh:mm").format(dt);
  } else if (dur.inHours > 0) {
    msg = '${dur.inHours} h';
  } else if (dur.inMinutes > 0) {
    msg = '${dur.inMinutes} m';
  } else if (dur.inSeconds > 0) {
    msg = '${dur.inSeconds} s';
  } else {
    msg = 'now';
  }
  return msg;
}

class ChatTextField extends StatefulWidget {
  GlobalKey<ScaffoldState> scaffoldKey;
  final User peer;
  final uid;
  ChatTextField({Key key, this.peer, this.uid, this.scaffoldKey})
      : super(key: key);

  @override
  _ChatTextFieldState createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  TextEditingController textEditingController;
  String text = "";
  DatabaseService db;

  UploadPhoto uploadPhoto;

  uploadImage(String uid) async {
    String photoUrl;
    await uploadPhoto.compressImage(uid);
    photoUrl = await uploadPhoto.uploadImage(
        imageFile: uploadPhoto.file, id: uid, folder: 'chats');
    submitMessage(uid: widget.uid, type: 'image', url: photoUrl);
  }

  void submitMessage({String uid, String type, String url}) {
    final messageId = Uuid().v4();

    Message message = Message(
      messageId: messageId,
      content: type == 'text' ? textEditingController.text.trim() : url,
      timeStamp: DateTime.now().toUtc().toString(),
      senderId: uid,
      peerId: widget.peer.uid,
      type: type,
    );
    if (type == 'text') {
      textEditingController.clear();
    }

    context.read(messagesProvider.notifier).add(message);
    db.sendMessage(message, widget.peer);
  }

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    db = DatabaseService();
    uploadPhoto = UploadPhoto();
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10),
      color: Theme.of(context).cardColor,
      constraints: BoxConstraints(minHeight: 60, maxHeight: 110),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              Icons.camera_alt_rounded,
              color: Colors.grey[350],
            ),
            onPressed: () {
              showDialog(
                context: widget.scaffoldKey.currentContext,
                builder: (context) {
                  return SimpleDialog(
                    title: Text("Upload image"),
                    children: <Widget>[
                      SimpleDialogOption(
                          child: Text("Photo with Camera"),
                          onPressed: () async {
                            await uploadPhoto.handleTakePhoto(context);
                            uploadImage(widget.uid);
                            // setState(() {});
                          }),
                      SimpleDialogOption(
                          child: Text("Image from Gallery"),
                          onPressed: () async {
                            await uploadPhoto.handleChooseFromGallery(context);

                            if (uploadPhoto.file != null) {
                              bool confirm = await Navigator.push(
                                  widget.scaffoldKey.currentContext,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ConfirmImageSelection(
                                              uploadPhoto: uploadPhoto)));
                              if (confirm) {
                                uploadImage(widget.uid);
                              }
                            }
                          }),
                      SimpleDialogOption(
                        child: Text("Cancel"),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  );
                },
              );
            },
          ),
          Expanded(
            child: Container(
              child: AutoDirection(
                text: text,
                child: TextFormField(
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    hintStyle: TextStyle(color: Colors.grey),
                    labelStyle: TextStyle(color: Colors.white),
                    focusColor: Colors.white,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  controller: textEditingController,
                  onChanged: (value) {
                    setState(() {
                      text = value;
                    });
                  },
                ),
              ),
            ),
          ),
          textEditingController.text.trim().isNotEmpty
              ? Container(
                  height: 50,
                  width: 50,
                  margin: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(50)),
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: textEditingController.text.trim().isNotEmpty
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                      onPressed: textEditingController.text.trim().isNotEmpty
                          ? () {
                              setState(() {
                                submitMessage(uid: widget.uid, type: 'text');
                              });
                            }
                          : null,
                    ),
                  ))
              : Container(
                  height: 50,
                  width: 50,
                  margin: EdgeInsets.only(bottom: 5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(50)),
                  child: Center(
                    child: IconButton(
                        icon: Icon(Icons.mic, color: Colors.white),
                        onPressed: () {
                          // TODO: record audio
                        }),
                  )),
        ],
      ),
    );
  }
}

class ConfirmImageSelection extends StatefulWidget {
  final String photoUrl;
  UploadPhoto uploadPhoto;

  ConfirmImageSelection({Key key, this.photoUrl, this.uploadPhoto})
      : super(key: key);

  @override
  _ConfirmImageSelectionState createState() => _ConfirmImageSelectionState();
}

class _ConfirmImageSelectionState extends State<ConfirmImageSelection> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Container(
            child: Center(
              child: GestureDetector(
                child: InteractiveViewer(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(widget.uploadPhoto.file),
                      ),
                    ),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child:
                        Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child:
                          Text('send', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
