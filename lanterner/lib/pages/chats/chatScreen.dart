import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_direction/auto_direction.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lanterner/controllers/translationController.dart';
import 'package:lanterner/widgets/customToast.dart';
import 'package:lanterner/widgets/nestedWillPopScope.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:uuid/uuid.dart';

import 'package:lanterner/controllers/uploadPhoto.dart';
import 'package:lanterner/models/message.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/providers/messages_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:lanterner/widgets/postCard.dart';

var logger = Logger();

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
  AudioPlayer audioPlayer;
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
    audioPlayer =
        AudioPlayer(playerId: context.read(authStateProvider).data.value.uid);

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

  bool isRecorderOpen(Function function) {
    return function();
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: () async {
        _onWillPop();
        return true;
      },
      child: Consumer(
        builder: (context, watch, child) {
          final _authState = watch(authStateProvider);
          List<Message> messages = watch(messagesProvider).messageList ?? [];

          var idSet = <String>{};
          var distinct = <Message>[];
          for (var d in messages) {
            if (idSet.add(d.messageId)) {
              distinct.add(d);
            }
          }
          messages.clear();
          messages = distinct;

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
                      return ChatMessage(
                        audioPlayer: audioPlayer,
                        message: messages[index],
                        uid: _authState.data.value.uid,
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ChatTextField(
                  uid: _authState.data.value.uid,
                  peer: widget.peer,
                  scaffoldKey: widget.scaffoldKey,
                  isRecorderOpen: isRecorderOpen,
                ),
              ),
            ],
          );
        },
      ),
    );
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
  Function isRecorderOpen;
  ChatTextField(
      {Key key, this.peer, this.uid, this.scaffoldKey, this.isRecorderOpen})
      : super(key: key);

  @override
  _ChatTextFieldState createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  TextEditingController textEditingController;
  final FocusNode focusNode = FocusNode();

  String text = "";
  DatabaseService db;

  UploadPhoto uploadPhoto;
  bool _enabled = true;
  bool isRecording = false;

  toggleTextField(bool enable) {
    setState(() {
      _enabled = enable;
    });
  }

  double containerHieght = 0;
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

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      hideRecorder();
    }
  }

  hideRecorder() {
    setState(() {
      containerHieght = 0;
    });
  }

  isRecorderOpen() {}
  void showRecorder() {
    // Hide keyboard when recorder appears
    focusNode.unfocus();
    setState(() {
      containerHieght == 0 ? containerHieght = 300 : containerHieght = 0;
    });
  }

  Future<void> _onUploadComplete() async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    ListResult listResult =
        await firebaseStorage.ref().child('upload-voice-firebase').list();
    setState(() {
      // references = listResult.items;
    });
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    textEditingController = TextEditingController();
    db = DatabaseService();
    uploadPhoto = UploadPhoto();
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
    focusNode.removeListener(() {});
    focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: () async {
        logger.d('poped from  textfield');
        if (containerHieght == 300) {
          logger.d('poped from  textfield false');
          setState(() {
            containerHieght = 0;
          });
          return false;
        } else {
          logger.d('poped from  textfield false true');
          return true;
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
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
                    if (_enabled) {
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
                                    await uploadPhoto
                                        .handleChooseFromGallery(context);

                                    if (uploadPhoto.file != null) {
                                      bool confirm = await Navigator.push(
                                          widget.scaffoldKey.currentContext,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ConfirmImageSelection(
                                                      uploadPhoto:
                                                          uploadPhoto)));
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
                    }
                  },
                ),
                Expanded(
                  child: Container(
                    child: AutoDirection(
                      text: text,
                      child: TextFormField(
                        enabled: _enabled,
                        focusNode: focusNode,
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
                              color:
                                  textEditingController.text.trim().isNotEmpty
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                            ),
                            onPressed:
                                textEditingController.text.trim().isNotEmpty
                                    ? () {
                                        setState(() {
                                          submitMessage(
                                              uid: widget.uid, type: 'text');
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
                              icon: Icon(
                                Icons.mic,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                bool hasPermission =
                                    await FlutterAudioRecorder2.hasPermissions;

                                if (hasPermission) {
                                  showRecorder();
//                                 }
                                }
                              }),
                        )),
              ],
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: containerHieght,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: FeatureButtonsView(
                onUploadComplete: _onUploadComplete,
                peer: widget.peer,
                uid: widget.uid,
                onFocusChange: hideRecorder,
                toggleTextField: toggleTextField,
              ),
            ),
          )
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

class ChatMessage extends StatefulWidget {
  AudioPlayer audioPlayer;
  Message message;
  final String uid;
  ChatMessage({Key key, this.message, this.uid, this.audioPlayer})
      : super(key: key);

  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  TranslationController translator = TranslationController();

  bool translated = false;
  bool loading = false;
  String translation;
  SharedPreferences prefs;

  // AudioPlayer audioPlayer;

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    // if (prefs.containsKey(widget.message.messageId)) {
    //   translation = prefs.getString(widget.message.messageId);
    //   setState(() {
    //     translated = true;
    //   });
    // }
  }

  @override
  void initState() {
    super.initState();
    // initPrefs();
    if (widget.message.translation != null) {
      translated = true;
    }

    // audioPlayer = AudioPlayer();
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
            // mainAxisAlignment: widget.message.senderId == widget.uid
            //     ? MainAxisAlignment.end
            //     : MainAxisAlignment.start,
            children: [
              widget.message.type == 'text'
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
                              audioPlayer: widget.audioPlayer,
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

class FeatureButtonsView extends StatefulWidget {
  final Function onUploadComplete;
  final Function onFocusChange;
  final Function toggleTextField;
  final User peer;
  final String uid;

  const FeatureButtonsView(
      {Key key,
      this.onUploadComplete,
      this.peer,
      this.uid,
      this.onFocusChange,
      @required this.toggleTextField})
      : super(key: key);
  @override
  _FeatureButtonsViewState createState() => _FeatureButtonsViewState();
}

class _FeatureButtonsViewState extends State<FeatureButtonsView> {
  bool _isPlaying;
  bool _isUploading;
  bool _isRecorded;
  bool _isRecording;

  AudioPlayer _audioPlayer;
  String _filePath;
  Duration _duration = new Duration();
  Duration _position = new Duration();

  FlutterAudioRecorder2 _audioRecorder;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isPlaying = false;
    _isUploading = false;
    _isRecorded = false;
    _isRecording = false;
    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    _audioPlayer.onAudioPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });
    focusNode.addListener(() {
      setState(() {
        widget.onFocusChange();
      });
    });
  }

  updaterecordertimer() async {
    Recording current = await _audioRecorder.current(channel: 0);

    _duration = current.duration;
    if (_duration.inSeconds >= 59) {
      _audioRecorder.stop();
      _isRecording = false;
      _isRecorded = true;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    // _audioRecorder.stop();
    focusNode.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: () async {
        if (_isRecording) {
          setState(() {
            _isRecording = false;
            _duration = Duration();
          });
          _audioRecorder.stop();
          widget.toggleTextField(true);
          widget.onFocusChange();
          return false;
        } else if (_isRecorded) {
          setState(() {
            _isRecorded = false;
            _duration = Duration();
          });

          widget.toggleTextField(true);
          widget.onFocusChange();
          return false;
        } else {
          return true;
        }
      },
      child: Center(
        child: _isRecorded
            ? _isUploading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: LinearProgressIndicator()),
                      Text('Uplaoding...'),
                    ],
                  )
                : Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                '00:' +
                                    _position
                                        .toString()
                                        .split(".")[0]
                                        .split(':')[2],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[100]),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                ' - 00:' +
                                    _duration
                                        .toString()
                                        .split(".")[0]
                                        .split(':')[2],
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[350]),
                              ),
                            ),
                          ],
                        ),
                        Flexible(child: SizedBox(height: 20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(50)),
                              child: IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.grey,
                                ),
                                onPressed: _onPlayButtonPressed,
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(50)),
                              child: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _isRecorded = false;
                                    _duration = Duration();
                                  });
                                  widget.toggleTextField(true);
                                  widget.onFocusChange();
                                },
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(50)),
                              child: IconButton(
                                icon: Icon(Icons.send_rounded,
                                    color: Colors.grey),
                                onPressed: _onFileUploadButtonPressed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isRecording
                      ? Flexible(
                          child: TimerBuilder.periodic(Duration(seconds: 1),
                              builder: (context) {
                          updaterecordertimer();
                          int recordedSeconds = _duration.inSeconds + 1;
                          return Text(recordedSeconds.toString());
                        }))
                      : Container(),
                  Flexible(child: SizedBox(height: 20)),
                  Flexible(
                    child: Container(
                      // height: 50,
                      // width: 50,
                      // constraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(50)),
                      child: IconButton(
                        icon: _isRecording
                            ? Icon(Icons.pause)
                            : Icon(Icons.fiber_manual_record),
                        onPressed: _onRecordButtonPressed,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _onFileUploadButtonPressed() async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    setState(() {
      _isUploading = true;
    });
    try {
      TaskSnapshot storageSnap = await firebaseStorage
          .ref('chats/audio/')
          .child(
              _filePath.substring(_filePath.lastIndexOf('/'), _filePath.length))
          .putFile(File(_filePath));

      String downloadUrl = await storageSnap.ref.getDownloadURL();
      final messageId = Uuid().v4();

      Message message = Message(
        messageId: messageId,
        content: downloadUrl,
        timeStamp: DateTime.now().toUtc().toString(),
        senderId: widget.uid,
        peerId: widget.peer.uid,
        type: 'audio',
      );

      DatabaseService db = DatabaseService();
      await db.sendMessage(message, widget.peer);
      widget.onUploadComplete();
    } catch (error) {
      print('Error occured while uplaoding to Firebase ${error.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occured while uplaoding'),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _onRecordAgainButtonPressed() {
    setState(() {
      _isRecorded = false;
    });
  }

  Future<void> _onRecordButtonPressed() async {
    if (_isRecording) {
      _audioRecorder.stop();
      _isRecording = false;
      _isRecorded = true;
    } else {
      widget.toggleTextField(false);
      _isRecorded = false;
      _isRecording = true;

      await _startRecording();
    }
    setState(() {});
  }

  void _onPlayButtonPressed() {
    if (!_isPlaying) {
      _isPlaying = true;

      _audioPlayer.play(_filePath, isLocal: true);
      _audioPlayer.onPlayerCompletion.listen((duration) {
        setState(() {
          _isPlaying = false;
        });
      });
    } else {
      _audioPlayer.pause();
      _isPlaying = false;
    }
    setState(() {});
  }

  Future<void> _startRecording() async {
    final bool hasRecordingPermission =
        await FlutterAudioRecorder2.hasPermissions;

    if (hasRecordingPermission ?? false) {
      Directory directory = await getApplicationDocumentsDirectory();
      String filepath = directory.path +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.aac';
      _audioRecorder =
          FlutterAudioRecorder2(filepath, audioFormat: AudioFormat.AAC);
      await _audioRecorder.initialized;
      _audioRecorder.start();
      _filePath = filepath;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Center(child: Text('Please enable recording permission'))));
    }
  }
}

class AudioFile extends StatefulWidget {
  AudioPlayer audioPlayer;
  final Message message;
  final String uid;
  AudioFile({Key key, @required this.audioPlayer, this.message, this.uid})
      : super(key: key);

  @override
  _AudioFileState createState() => _AudioFileState();
}

class _AudioFileState extends State<AudioFile> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  bool isPlaying = false;
  bool isPaused = false;
  bool isRepeat = false;
  Color color = Colors.black;

  DatabaseService db = DatabaseService();
  List<IconData> _icons = [
    Icons.play_arrow_rounded,
    Icons.pause_circle_filled_rounded,
  ];

  AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });

    audioPlayer.setUrl(this.widget.message.content);
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        _position = Duration(seconds: 0);
        if (isRepeat == true) {
          isPlaying = true;
        } else {
          isPlaying = false;
          isRepeat = false;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
  }

  Widget btnStart() {
    return IconButton(
      // padding: const EdgeInsets.only(bottom: 10),
      icon: isPlaying == false
          ? Icon(
              _icons[0],
              size: 35,
              color: Colors.white,
            )
          : Icon(_icons[1], size: 35, color: Colors.white),
      onPressed: () {
        if (isPlaying == false) {
          audioPlayer.play(this.widget.message.content);
          db.incrementAudioListened(widget.uid);
          setState(() {
            isPlaying = true;
          });
        } else if (isPlaying == true) {
          audioPlayer.pause();
          logger.d(audioPlayer.state.toString());
          setState(() {
            isPlaying = false;
          });
        }
      },
    );
  }

  // Widget btnFast() {
  //   return IconButton(
  //     icon: ImageIcon(
  //       AssetImage('img/forward.png'),
  //       size: 15,
  //       color: Colors.black,
  //     ),
  //     onPressed: () {
  //       audioPlayer.setPlaybackRate(playbackRate: 1.5);
  //     },
  //   );
  // }

  // Widget btnSlow() {
  //   return IconButton(
  //     icon: ImageIcon(
  //       AssetImage('img/backword.png'),
  //       size: 15,
  //       color: Colors.black,
  //     ),
  //     onPressed: () {
  //       audioPlayer.setPlaybackRate(playbackRate: 0.5);
  //     },
  //   );
  // }

  // Widget btnLoop() {
  //   return IconButton(
  //       onPressed: () {},
  //       icon: ImageIcon(
  //         AssetImage('img/loop.png'),
  //         size: 15,
  //         color: Colors.black,
  //       ));
  // }

  // Widget btnRepeat() {
  //   return IconButton(
  //     icon: ImageIcon(
  //       AssetImage('img/repeat.png'),
  //       size: 15,
  //       color: color,
  //     ),
  //     onPressed: () {
  //       if (isRepeat == false) {
  //         audioPlayer.setReleaseMode(ReleaseMode.LOOP);
  //         setState(() {
  //           isRepeat = true;
  //           color = Colors.blue;
  //         });
  //       } else if (isRepeat == true) {
  //         audioPlayer.setReleaseMode(ReleaseMode.RELEASE);
  //         color = Colors.black;
  //         isRepeat = false;
  //       }
  //     },
  //   );
  // }

  Widget slider() {
    double maxValue;
    maxValue =
        _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 0;
    var progress =
        _duration.inSeconds.toDouble() > _position.inSeconds.toDouble()
            ? _position.inSeconds.toDouble()
            : _duration.inSeconds.toDouble();
    return Slider(
        activeColor: Colors.white,
        inactiveColor: Colors.grey[400],
        value: progress,
        min: 0.0,
        max: maxValue,
        onChanged: (double value) {
          setState(() {
            changeToSecond(value.toInt());
            value = value;
          });
        });
  }

  void changeToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer.seek(newDuration);
  }

  // Widget loadAsset() {
  //   return Container(
  //       padding: EdgeInsets.zero,
  //       child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             // btnRepeat(),
  //             // btnSlow(),
  //             btnStart(),
  //             // btnFast(),
  //             // btnLoop()
  //           ]));
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        audioPlayer.stop();
        return true;
      },
      child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
              color: widget.uid == widget.message.senderId
                  ? Theme.of(context).accentColor.withOpacity(0.8)
                  : Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(40)),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  btnStart(),
                  slider(),
                  isPlaying
                      ? Text(
                          _position.toString().split(".")[0],
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[100]),
                        )
                      : Text(
                          _duration.toString().split(".")[0],
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[350]),
                        ),
                ],
              ),
            ],
          )),
    );
  }
}
