import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/message.dart';
import 'package:flutter/material.dart';
import 'dart:async';

final messagesProvider =
    ChangeNotifierProvider<MessagesState>((ref) => MessagesState());

class MessagesState extends ChangeNotifier {
  List<Message> messages;

  MessagesState([List<Message> initialMessageList]) : super();

  StreamSubscription<QuerySnapshot> _messageSubscription;

  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  void remove([Message message]) {
    messages.remove(message);

    //*  must call notifyListeners to trigger rebuild
    notifyListeners();
  }

  void add([Message message]) {
    if (messages == null) {
      messages = [];
    }
    messages.add(message);

    //*  must call notifyListeners to trigger rebuild
    notifyListeners();
  }

  List<Message> get messageList {
    if (messages == null) {
      return null;
    } else {
      this.messages.sort((x, y) => DateTime.parse(x.timeStamp)
          .toLocal()
          .compareTo(DateTime.parse(y.timeStamp).toLocal()));
      this.messages.reversed;
      this.messages = this.messages.reversed.toList();
      var idSet = <String>{};
      var distinct = <Message>[];
      for (var d in messages) {
        if (idSet.add(d.messageId)) {
          distinct.add(d);
        }
      }
      messages.clear();
      messages = distinct;
      return List.from(this.messages);
    }
  }

  getMessages(String senderId, String peerId) {
    // List<Message> messages;
    messages = null;

    _messageSubscription = messagesCollection
        .doc(getChatroomId(senderId, peerId))
        .collection('messages')
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
    if (messages == null) {
      messages = [];
    }
    if (snapshot.data() != null) {
      var map = snapshot.data();
      if (map != null) {
        var model = Message.fromMap(map);
        model.messageId = snapshot.id;
        if (messages.length > 0 &&
            messages.any((x) => x.messageId == model.messageId)) {
          return;
        }
        messages.add(model);
      }
    } else {
      messages = null;
    }
    notifyListeners();
  }

  void _onMessageChanged(DocumentSnapshot snapshot) {
    if (messages == null) {
      messages = [];
    }
    if (snapshot.data() != null) {
      var map = snapshot.data();
      if (map != null) {
        var model = Message.fromMap(map);
        model.messageId = snapshot.id;
        if (messages.length > 0 &&
            messages.any((x) => x.messageId == model.messageId)) {
          int index = messages
              .indexWhere((element) => element.messageId == model.messageId);
          messages[index] = model;
          notifyListeners();
          return;
        }
        messages.add(model);
      }
    } else {
      messages = null;
    }
    notifyListeners();
  }

  void onChatScreenClosed() {
    if (_messageSubscription != null) {
      _messageSubscription.cancel();
    }
  }

  void getchatDetailAsync(String senderId, String peerId) async {
    try {
      if (messages == null) {
        messages = [];
      }
      messagesCollection
          .doc(getChatroomId(senderId, peerId))
          .collection('messages')
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot != null && querySnapshot.docs.isNotEmpty) {
          for (var i = 0; i < querySnapshot.docs.length; i++) {
            final model = Message.fromMap(querySnapshot.docs[i].data());
            model.messageId = querySnapshot.docs[i].id;
            messages.add(model);
          }
          // _userlist.addAll(_userFilterlist);
          // _userFilterlist.sort((x, y) => y.followers.compareTo(x.followers));
          notifyListeners();
        } else {
          messages = null;
        }
      });
    } catch (error) {
      print(error);
    }
  }

  String getChatroomId(String senderId, String peerId) {
    String user1 = senderId.substring(0, 5);
    String user2 = peerId.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();

    return '${list[0]}-${list[1]}';
  }
}
