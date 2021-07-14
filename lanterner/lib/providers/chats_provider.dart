import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/chat.dart';
import 'package:flutter/material.dart';
import 'dart:async';

final chatsProvider =
    ChangeNotifierProvider<ChatsListState>((ref) => ChatsListState());

class ChatsListState extends ChangeNotifier {
  List<Chat> chats;

  ChatsListState([List<Chat> initialchats]) : super();

  StreamSubscription<QuerySnapshot> _chatsSubscription;

  // final CollectionReference messagesCollection =
  //     FirebaseFirestore.instance.collection('messages');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  // void remove([Message message]) {
  //   chats.remove(message);

  //   //*  must call notifyListeners to trigger rebuild
  //   notifyListeners();
  // }

  List<Chat> get chatsList {
    if (chats == null) {
      return null;
    } else {
      this.chats.sort((x, y) => DateTime.parse(x.lastMessage.timeStamp)
          .toLocal()
          .compareTo(DateTime.parse(y.lastMessage.timeStamp).toLocal()));
      this.chats.reversed;
      this.chats = this.chats.reversed.toList();
      return List.from(this.chats);
    }
  }

  getChats(String uid) {
    // List<Message> messages;
    chats = null;

    _chatsSubscription = usersCollection
        .doc(uid)
        .collection('chats')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docChanges.isEmpty) {
        return;
      }
      if (snapshot.docChanges.first.type == DocumentChangeType.added) {
        _onMessageAdded(snapshot.docChanges.first.doc);
      } else if (snapshot.docChanges.first.type == DocumentChangeType.removed) {
        // _onNotificationRemoved(snapshot.docChanges.first.doc);
      } else if (snapshot.docChanges.first.type ==
          DocumentChangeType.modified) {
        _onMessageChanged(snapshot.docChanges.first.doc);
      }
    });
  }

  void _onMessageAdded(DocumentSnapshot snapshot) {
    if (chats == null) {
      chats = [];
    }
    if (snapshot.data() != null) {
      var map = snapshot.data();
      if (map != null) {
        var model = Chat.fromMap(map);
        model.peerId = snapshot.id;
        if (chats.length > 0 && chats.any((x) => x.peerId == model.peerId)) {
          return;
        }
        chats.add(model);
      }
    } else {
      chats = null;
    }
    notifyListeners();
  }

  void _onMessageChanged(DocumentSnapshot snapshot) {
    if (chats == null) {
      chats = [];
    }
    if (snapshot.data() != null) {
      var map = snapshot.data();

      if (map != null) {
        var model = Chat.fromMap(map);
        model.peerId = snapshot.id;
        if (chats.length > 0 && chats.any((x) => x.peerId == model.peerId)) {
          // TODO: apply this to messagesPrivider as well
          int index =
              chats.indexWhere((element) => element.peerId == model.peerId);
          chats[index] = model;
          notifyListeners();
          return;
        }
        chats.add(model);
      }
    } else {
      chats = null;
    }
    notifyListeners();
  }

  void onChatListClosed() {
    if (_chatsSubscription != null) {
      _chatsSubscription.cancel();
    }
  }

  void getChatListAsync(String uid) async {
    try {
      if (chats == null) {
        chats = [];
      }
      usersCollection
          .doc(uid)
          .collection('chats')
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot != null && querySnapshot.docs.isNotEmpty) {
          for (var i = 0; i < querySnapshot.docs.length; i++) {
            final model = Chat.fromMap(querySnapshot.docs[i].data());
            model.peerId = querySnapshot.docs[i].id;
            chats.add(model);
          }
          // _userlist.addAll(_userFilterlist);
          // _userFilterlist.sort((x, y) => y.followers.compareTo(x.followers));
          notifyListeners();
        } else {
          chats = null;
        }
      });
    } catch (error) {
      print(error);
    }
  }
}
