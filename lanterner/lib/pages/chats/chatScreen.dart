import 'dart:async';

import 'package:auto_direction/auto_direction.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lanterner/pages/chats/audioPlayerWidget.dart';
import 'package:lanterner/pages/chats/chatMessage.dart';
import 'package:lanterner/widgets/circleAvatar.dart';
import 'package:lanterner/widgets/nestedWillPopScope.dart';
import 'package:uuid/uuid.dart';
import 'package:lanterner/controllers/uploadPhoto.dart';
import 'package:lanterner/models/message.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/providers/messages_provider.dart';
import 'package:lanterner/services/databaseService.dart';

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
        title: Row(
          children: [
            ProfileImage(
                ownerId: user.uid,
                photoUrl: user.photoUrl,
                currentUserId: '',
                size: 20,
                context: context),
            SizedBox(
              width: 20,
            ),
            Flexible(
              child: Text(
                '${user.name}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
  ChatTextField({Key key, this.peer, this.uid, this.scaffoldKey})
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
      // Hide recorder when keyboard appear
      hideRecorder();
    }
  }

  hideRecorder() {
    setState(() {
      containerHieght = 0;
    });
  }

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
        if (containerHieght == 300) {
          setState(() {
            containerHieght = 0;
          });
          return false;
        } else {
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

                                if (hasPermission & _enabled) {
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
