import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/message.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/providers/messages_provider.dart';
import 'package:lanterner/services/databaseService.dart';
import 'package:intl/intl.dart';

class ChatRoom extends StatelessWidget {
 final User peer;
  const ChatRoom({Key key, this.peer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: if the user is recived from the chatList page it only contains name,uid & photoUrl
    final User user = ModalRoute.of(context).settings.arguments?? peer;
    print(user.toString());
    return Scaffold(
      backgroundColor: Color(0xff181E30),
      appBar: AppBar(
        title: Text('${user.name}'),
      ),
      body: ChatScreen(peer: user),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final User peer;
  const ChatScreen({
    Key key,
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

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final _authState = watch(authStateProvider);
        List<Message> messages = watch(messagesProvider).messageList ?? [];

        // builder: (context, ) {
        return Stack(
          children: [
            Column(
              children: [
                Flexible(
                  child: Container(
                    // margin: EdgeInsets.only(bottom: 60),
                    child: ListView.builder(
                      controller: listScrollController,
                      reverse: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return chatMessage(context, messages[index],
                            _authState.data.value.uid);
                      },
                    ),
                  ),
                ),
                ChatTextField(
                    uid: _authState.data.value.uid, peer: widget.peer),
              ],
            ),
          ],
        );
      },
    );
  }

  Container chatMessage(BuildContext context, Message message, String uid) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: message.senderId == uid
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          // addAvatar(message.uid),
          // SizedBox(
          //   width: 5,
          // ),
          Flexible(
            child: Container(
              // width: 80,
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                  minWidth: 30),
              // width: 300,
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
              // width: MediaQuery.of(context).size.width * 0.75,
              decoration: message.senderId == uid
                  ? BoxDecoration(
                      color: Color(0xff56B7D7),
                      // gradient: LinearGradient(
                      //     begin: Alignment.centerRight,
                      //     end: Alignment.centerLeft,
                      //     colors: <Color>[
                      //       Color(0xFF76D3FF),
                      //       Color(0xFF5C79FF)
                      //     ]),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color:
                            // message.senderId == uid
                            //     ?
                            Colors.white,
                        // : Colors.grey[700],
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  // SizedBox(height: 8.0),
                  Text(
                    getChatTime(message.timeStamp),
                    style: TextStyle(
                      color: message.senderId == uid
                          ? Colors.grey[300]
                          : Colors.grey[500],
                      fontSize: 10.0,
                      // fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
  final User peer;
  final uid;
  ChatTextField({Key key, this.peer, this.uid}) : super(key: key);

  @override
  _ChatTextFieldState createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<ChatTextField> {
  TextEditingController textEditingController;
  String text = "";
  DatabaseService db;
  void submitMessage({String uid, String type}) {
    if (textEditingController.text.trim().isNotEmpty) {
      Message message = Message(
        content: textEditingController.text.trim(),
        timeStamp: DateTime.now().toUtc().toString(),
        senderId: uid,
        peerId: widget.peer.uid,
        type: type,
      );
      textEditingController.clear();

      print('MEssage:: ');
      db.sendMessage(message, widget.peer);
    }
  }

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    db = DatabaseService();
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
          Container(
              height: 50,
              width: 50,
              margin: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                  color: textEditingController.text.trim().isNotEmpty
                      ? Theme.of(context).accentColor
                      : Theme.of(context).accentColor.withOpacity(0.5),
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
                      ? () => submitMessage(uid: widget.uid, type: 'text')
                      : null,
                ),
              ))
        ],
      ),
    );
  }
}
