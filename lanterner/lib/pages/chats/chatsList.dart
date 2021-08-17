import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/chat.dart';
import 'package:lanterner/models/user.dart';
import 'package:lanterner/providers/auth_provider.dart';
import 'package:lanterner/providers/chats_provider.dart';
import 'package:intl/intl.dart';
import 'package:lanterner/widgets/circleAvatar.dart';
import 'package:logger/logger.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'chatScreen.dart';

var logger = Logger();

class ChatsList extends StatefulWidget {
  ChatsList({Key key}) : super(key: key);

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  GlobalKey _scaffold = GlobalKey();
  ScrollController listScrollController;
  List<int> _items = [];
  int counter = 0;
  int _limit = 20;
  final int _limitIncrement = 20;

  //! TODO: duplicate function also exists in chatScreen.dart
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

    context
        .read(chatsProvider.notifier)
        .getChats(context.read(authStateProvider).data.value.uid);
    context
        .read(chatsProvider.notifier)
        .getChatListAsync(context.read(authStateProvider).data.value.uid);
  }

  Future<bool> _onWillPop() async {
    context.read(chatsProvider.notifier).onChatListClosed();
    logger.d('chats list cancelled');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          key: _scaffold,
          appBar: AppBar(
            title: Text('chats'),
            centerTitle: true,
          ),
          body: Consumer(builder: (context, watch, child) {
            final _authState = watch(authStateProvider);
            List<Chat> chats = watch(chatsProvider).chatsList ?? [];

            var idSet = <String>{};
            var distinct = <Chat>[];
            for (var d in chats) {
              if (idSet.add(d.peerId)) {
                distinct.add(d);
              }
            }
            chats.clear();
            chats = distinct;

            if (chats.length > 0) {
              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  onTap: () async {
                    // TODO: becarful with sending a user with null values

                    User peer = User(
                        name: chats[index].username,
                        uid: chats[index].peerId,
                        photoUrl: chats[index].photoUrl);

                    pushNewScreenWithRouteSettings(
                      _scaffold.currentContext,
                      settings: RouteSettings(name: '/chatRoom'),
                      screen: ChatRoom(peer: peer),
                      pageTransitionAnimation: PageTransitionAnimation.slideUp,
                      withNavBar: false,
                    );
                  },
                  leading: ProfileImage(
                      size: 22,
                      ownerId: chats[index].peerId,
                      context: context,
                      photoUrl: chats[index].photoUrl,
                      currentUserId: _authState.data.value.uid),
                  title: Text('${chats[index].username}',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    chats[index].lastMessage.type == 'text'
                        ? '${chats[index].lastMessage.content}'
                        : chats[index].lastMessage.type == 'image'
                            ? 'photo'
                            : chats[index].lastMessage.type == 'audio'
                                ? 'audio'
                                : 'message',
                    style: TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${getChatTime(chats[index].lastMessage.timeStamp)}',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              );
            } else {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                      child: Text(
                    'No conversations yet!! \n\n Start conversations with friends to see them here.',
                    textAlign: TextAlign.center,
                  )));
            }
          })

          // Stack(
          //   children: [
          //     AnimatedList(
          //       key: listKey,
          //       initialItemCount: _items.length,
          //       itemBuilder: (context, index, animation) {
          //         return slideIt(context, index, animation); // Refer step 3
          //       },
          //     ),
          //     Align(
          //         alignment: Alignment.bottomCenter,
          //         child: Container(
          //           margin: EdgeInsets.only(bottom: 50),
          //           child: Row(
          //             children: [
          //               ElevatedButton(
          //                 child: Text('add'),
          //                 onPressed: () {
          //                   listKey.currentState.insertItem(0,
          //                       duration: const Duration(milliseconds: 400));
          //                   _items = []
          //                     ..add(counter++)
          //                     ..addAll(_items);
          //                 },
          //               ),
          //               ElevatedButton(
          //                 child: Text('remove'),
          //                 onPressed: () {
          //                   listKey.currentState.removeItem(0,
          //                       (_, animation) => slideIt(context, 0, animation),
          //                       duration: const Duration(milliseconds: 400));
          //                 },
          //               ),
          //             ],
          //           ),
          //         ))
          //   ],
          // )
          ),
    );
  }

//   Widget slideIt(BuildContext context, int index, animation) {
//     int item = _items[index];
//     TextStyle textStyle = Theme.of(context).textTheme.headline4;
//     return SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(-1, 0),
//           end: Offset(0, 0),
//         ).animate(CurvedAnimation(
//             parent: animation,
//             curve: Curves.easeInOutBack,
//             reverseCurve: Curves.easeInOut)),
//         child: Container(
//           child: ListTile(
//             leading: CircleAvatar(
//               radius: 22,
//               backgroundColor: Colors.grey,
//               child: Icon(Icons.person),
//             ),
//             title: Text('name', style: TextStyle(color: Colors.white)),
//             subtitle:
//                 Text('last message', style: TextStyle(color: Colors.grey)),
//             trailing: Text('date'),
//           ),
//         ));
//   }
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
