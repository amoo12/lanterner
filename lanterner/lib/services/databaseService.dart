// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanterner/models/activity.dart';
import 'package:lanterner/models/comment.dart';
import 'package:lanterner/models/message.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/models/user.dart';
import 'dart:async';

import 'package:logger/logger.dart';

var logger = Logger();

// this class talks to cloud firestore and manages queries
class DatabaseService {
  final String uid;
  final String postId;
  DatabaseService({this.uid, this.postId});

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');
  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');
  final CollectionReference timelineCollection =
      FirebaseFirestore.instance.collection('timeline');
  final CollectionReference activityCollection =
      FirebaseFirestore.instance.collection('activity');
  // final CollectionReference timelinePostsCollectionGroup =
  //     FirebaseFirestore.instance.collectionGroup('timelinePosts');
  // inserts a new user record in Firestore
  Future insertUser(User user) async {
    user.setSearchParameters();
    return await usersCollection.doc(uid).set(user.toMap());
  }

  //TODO: convert to batch write
  // inserts a new post record
  Future createPost(Post post) async {
    // var batch = FirebaseFirestore.instance.batch();
    // var newPostRef = postsCollection.doc();
    // //update user postsCount
    // batch.update(usersCollection.doc(post.ownerId),
    //     {'postsCount': FieldValue.increment(1)});
    // // add the post to the posts collection
    // batch.set(newPostRef, post.toMap());
    await usersCollection
        .doc(post.user.uid)
        .update({'postsCount': FieldValue.increment(1)});
    return await postsCollection.doc(post.postId).set(post.toMap());
  }

//returns user user data (takes a user id)
  Future<User> getUser(String uid) async {
    return await usersCollection
        .doc(uid)
        .get()
        .then((doc) => User.fromSnapShot(doc));
  }

  // update user bio
  Future<void> updateBio(String uid, String bio) async {
    var batch = FirebaseFirestore.instance.batch();

    batch.update(usersCollection.doc(uid), {'bio': bio});

    batch.commit();
  }

//get all users posts
  Future<List<Post>> getPosts(String uid) async {
    User user = await getUser(uid);
    return await postsCollection
        .where('user.nativeLanguage.code', isEqualTo: user.targetLanguage.code)
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) => value.docs.map((doc) => Post.fromMap(doc)).toList());
  }
// //get all users posts
//   Future<List<Post>> getPosts() async {
//     return await postsCollection
//         .orderBy('timestamp', descending: true)
//         .get()
//         .then((value) => value.docs.map((doc) => Post.fromMap(doc)).toList());
//   }

  Future<List<Post>> getUserTimeline(String uid) async {
    return await timelineCollection
        .doc(uid)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) => value.docs.map((doc) => Post.fromMap(doc)).toList());
  }

//get a user's posts
  Future<List<Post>> getUserPosts(String uid) async {
    return await postsCollection
        .where('user.uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) => value.docs.map((doc) => Post.fromMap(doc)).toList());
  }

  Future<Post> getPost(String postId) async {
    return await postsCollection
        .doc(postId)
        .get()
        .then((doc) => Post.fromMap(doc));
  }

  Future<void> deletePost(Post post) async {
    var batch = FirebaseFirestore.instance.batch();
    // delete post from posts collection
    batch.delete(postsCollection.doc(post.postId));
    // update posts count in user profile
    batch.update(usersCollection.doc(post.user.uid),
        {'postsCount': FieldValue.increment(-1)});

    //commit batch
    batch.commit();
  }

//update profile photo url in user document
  Future<void> updateProfilePicture(String uid, String photoUrl) async {
    var batch = FirebaseFirestore.instance.batch();
    batch.update(usersCollection.doc(uid), {
      'photoUrl': photoUrl,
    });

    QuerySnapshot chatsQuery = await FirebaseFirestore.instance
        .collectionGroup('chats')
        .where('peerId', isEqualTo: uid)
        .get();
    chatsQuery.docs.forEach((doc) {
      if (doc.exists) doc.reference.update({'photoUrl': photoUrl});
    });

    await FirebaseFirestore.instance
        .collectionGroup('userActivity')
        .where('user.uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc.exists)
          batch.update(doc.reference, {'user.photoUrl': photoUrl});
      });
    });

    await postsCollection
        .where('user.uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((element) {
        DocumentReference doc = postsCollection.doc(element.id);
        if (element.exists) batch.update(doc, {'user.photoUrl': photoUrl});
      });
    });

    await FirebaseFirestore.instance
        .collectionGroup('timelinePosts')
        .where('user.uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        // DocumentReference doc = postsCollection.doc(element.id);
        if (doc.exists)
          batch.update(doc.reference, {'user.photoUrl': photoUrl});
      });
    });

    await FirebaseFirestore.instance
        .collectionGroup('comments')
        .where('user.uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc.exists)
          batch.update(doc.reference, {'user.photoUrl': photoUrl});
      });
    });
    await FirebaseFirestore.instance
        .collectionGroup('following')
        .where('uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc.exists) batch.update(doc.reference, {'photoUrl': photoUrl});
      });
    });
    return FirebaseFirestore.instance
        .collectionGroup('followers')
        .where('uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc.exists) batch.update(doc.reference, {'photoUrl': photoUrl});
      });
      batch.commit();
    });
  }

  Future<void> updateUsername(User user) async {
    var batch = FirebaseFirestore.instance.batch();
    user.setSearchParameters();

    batch.update(usersCollection.doc(user.uid),
        {'name': user.name, 'searchOptions': user.searchOptions});

    await postsCollection
        .where('user.uid', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((element) {
        DocumentReference doc = postsCollection.doc(element.id);
        batch.update(doc, {'user.name': user.name});
      });
    });

    await FirebaseFirestore.instance
        .collectionGroup('timelinePosts')
        .where('user.uid', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        // DocumentReference doc = postsCollection.doc(element.id);

        batch.update(doc.reference, {'user.name': user.name});
      });
    });
    await FirebaseFirestore.instance
        .collectionGroup('comments')
        .where('user.uid', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        batch.update(doc.reference, {'user.name': user.name});
      });
    });

    await FirebaseFirestore.instance
        .collectionGroup('following')
        .where('uid', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      logger.d('new query running');
      snapshot.docs.forEach((doc) {
        batch.update(doc.reference,
            {'name': user.name, 'searchOptions': user.searchOptions});
      });
    });

    return FirebaseFirestore.instance
        .collectionGroup('followers')
        .where('uid', isEqualTo: user.uid)
        .get()
        .then((snapshot) {
      logger.d('new query running');
      snapshot.docs.forEach((doc) {
        batch.update(doc.reference,
            {'name': user.name, 'searchOptions': user.searchOptions});
      });
      batch.commit();
    });
  }

  Future<void> updateTargetLanguage(String uid, Language language) {
    return usersCollection
        .doc(uid)
        .update({'targetLanguage': language.toMap()});
  }

  // * -------
  Future<List<User>> searchUsers(String searchText, String uid) async {
    return await usersCollection
        .where('uid', isNotEqualTo: uid)
        .where('searchOptions', arrayContains: searchText)
        .get()
        .then((value) =>
            value.docs.map((doc) => User.fromSnapShot(doc)).toList());
  }

// follow a user
  Future<void> follow(String uid, User currrentUser) async {
    var batch = FirebaseFirestore.instance.batch();
    User followedUser = await getUser(uid);

    //* current user
    // add the user document to the followingsub-collection
    batch.set(
        usersCollection.doc(currrentUser.uid).collection('following').doc(uid),
        followedUser.toMap());

    // increase the following count on the user document
    batch.update(usersCollection.doc(currrentUser.uid),
        {'following': FieldValue.increment(1)});

//* followed user
// delete the user document from the followingsub-collection
    batch.set(
        usersCollection.doc(uid).collection('followers').doc(currrentUser.uid),
        currrentUser.toMap());

    // increase the followers count on the user document
    batch.update(
        usersCollection.doc(uid), {'followers': FieldValue.increment(1)});

    batch.commit();
  }

// unfollow a user
  Future unfollow(String uid, User currrentUser) async {
    var batch = FirebaseFirestore.instance.batch();
    //* current user
    // delete the user document from the followingsub-collection
    batch.delete(
        usersCollection.doc(currrentUser.uid).collection('following').doc(uid));

    //     {'following': FieldValue.increment(-1)});
    // decrease the following count on the user document
    batch.update(usersCollection.doc(currrentUser.uid),
        {'following': FieldValue.increment(-1)});

    //* unfollowed user
    // delete the user document from the followingsub-collection
    batch.delete(
        usersCollection.doc(uid).collection('followers').doc(currrentUser.uid));

// decrease the followers count on the user document
    batch.update(
        usersCollection.doc(uid), {'followers': FieldValue.increment(-1)});

    // commit the batch
    await batch.commit();
  }

// checks wether I already follow a user
  Future<bool> isFollowing(String uid, String currentUserId) async {
    // QuerySnapshot querySnapshot = await usersCollection
    //     .doc(currentUserId)
    //     .collection('following')
    //     .limit(1)
    //     .get();
    // if (querySnapshot.size > 0) {
    // if there's at least one uesr check if I follow them
    return await usersCollection
        .doc(currentUserId)
        .collection('following')
        .doc(uid)
        .get()
        .then((doc) {
      if (doc.exists) {
        return true;
      } else {
        return false;
      }
    });
    // } else {
    //   return false;
    // }
  }

  Future<List<User>> getFollowers(String uid) async {
    return await usersCollection.doc(uid).collection('followers').get().then(
        (value) => value.docs.map((doc) => User.fromSnapShot(doc)).toList());
  }

  Future<List<User>> getFollowing(String uid) async {
    return await usersCollection.doc(uid).collection('following').get().then(
        (value) => value.docs.map((doc) => User.fromSnapShot(doc)).toList());
  }

  Future<void> comment(String postId, Comment comment) async {
    //create a new document reference to get doc id
    DocumentReference ref =
        postsCollection.doc(postId).collection('comments').doc();

    // var batch = FirebaseFirestore.instance.batch();

    // assign new doc id to the comment
    comment.cid = ref.id;
    // add the doc to the collection
    // batch.set(
    postsCollection
        .doc(postId)
        .collection('comments')
        .doc(comment.cid)
        .set(comment.toMap());

    //commit batch
    // batch.commit();
  }

  Future<List<Comment>> getCommetns(String postId) async {
    return await postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp')
        .get()
        .then(
            (value) => value.docs.map((doc) => Comment.fromMap(doc)).toList());
  }

  Future<void> deleteCommetn(String postId, Comment comment) async {
    var batch = FirebaseFirestore.instance.batch();

    batch.delete(
        postsCollection.doc(postId).collection('comments').doc(comment.cid));

    //commit batch
    batch.commit();
  }

  Future<void> sendMessage(Message message, User peer) async {
    User sender = await getUser(message.senderId);

    var batch = FirebaseFirestore.instance.batch();
    batch.set(
        usersCollection
            .doc(message.senderId)
            .collection('chats')
            .doc(message.peerId),
        {
          'peerId': peer.uid,
          'username': peer.name,
          'photoUrl': peer.photoUrl,
          'lastMessage': message.toMap()
        });

    batch.set(
        usersCollection
            .doc(message.peerId)
            .collection('chats')
            .doc(message.senderId),
        {
          'peerId': sender.uid,
          'username': sender.name,
          'photoUrl': sender.photoUrl,
          "lastMessage": message.toMap()
        });

    batch.set(
        messagesCollection
            .doc(message.getChatroomId())
            .collection('messages')
            .doc(message.messageId),
        message.toMap());

    batch.commit();
  }

  Future<void> saveMessageTranslation(Message message) async {
    messagesCollection
        .doc(message.getChatroomId())
        .collection('messages')
        .doc(message.messageId)
        .update({'translation': message.translation});
  }

  Future<void> likePost(Post post, String uid, like) async {
    if (like) {
      return postsCollection
          .doc(post.postId)
          .collection('likes')
          .doc(uid)
          .set({'timestamp': DateTime.now().toUtc().toString()});
    } else if (!like) {
      return postsCollection
          .doc(post.postId)
          .collection('likes')
          .doc(uid)
          .delete();
    }
  }

  Stream<bool> isLiked(Post post, uid) {
    final ref = postsCollection.doc(post.postId).collection('likes').doc(uid);

    return ref.snapshots().map((doc) => doc.exists ? true : false);
  }

  Future<bool> isLikedF(Post post, uid) async {
    final ref = await postsCollection
        .doc(post.postId)
        .collection('likes')
        .doc(uid)
        .get();

    return ref.exists ? true : false;
  }

  // Stream<DocumentSnapshot>
  Stream<User> userStream(String uid) {
    final ref = usersCollection.doc(uid);

    return ref.snapshots().map((doc) => User.fromSnapShot(doc));
  }

  Future<void> promoteToAdmin(String uid) async {
    var batch = FirebaseFirestore.instance.batch();

    batch.update(usersCollection.doc(uid), {'admin': true});

    await postsCollection
        .where('user.uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((element) {
        DocumentReference doc = postsCollection.doc(element.id);
        batch.update(doc, {'user.admin': true});
      });
    });

    await FirebaseFirestore.instance
        .collectionGroup('timelinePosts')
        .where('user.uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        batch.update(doc.reference, {'user.admin': true});
      });
    });
    // TODO: check again if this is necessary
    return FirebaseFirestore.instance
        .collectionGroup('comments')
        .where('user.uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        batch.update(doc.reference, {'user.admin': true});
      });
      batch.commit();
    });
  }

  Future<void> revokeAdmin(String uid) async {
    var batch = FirebaseFirestore.instance.batch();

    batch.update(usersCollection.doc(uid), {'admin': false});

    await postsCollection
        .where('user.uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((element) {
        DocumentReference doc = postsCollection.doc(element.id);
        batch.update(doc, {'user.admin': false});
      });
    });

    await FirebaseFirestore.instance
        .collectionGroup('timelinePosts')
        .where('user.uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        batch.update(doc.reference, {'user.admin': false});
      });
    });
    // TODO: check again if this is necessary
    return FirebaseFirestore.instance
        .collectionGroup('comments')
        .where('user.uid', isEqualTo: uid)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) {
        batch.update(doc.reference, {'user.admin': false});
      });
      batch.commit();
    });
  }

  Future<void> incrementTranslations(String uid) {
    return usersCollection
        .doc(uid)
        .update({'translationsCount': FieldValue.increment(1)});
  }

  Future<void> incrementAudioListened(String uid) {
    return usersCollection
        .doc(uid)
        .update({'audioListened': FieldValue.increment(1)});
  }

  Future<List<Activity>> getUserActivity(String uid) async {
    return activityCollection
        .doc(uid)
        .collection('userActivity')
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) =>
            value.docs.map((doc) => Activity.fromMap(doc.data())).toList());
  }

  //! TODO: duplicate function also exists in messagesProvider
  String getChatroomId(String senderId, String peerId) {
    String user1 = senderId.substring(0, 5);
    String user2 = peerId.substring(0, 5);
    List<String> list = [user1, user2];
    list.sort();

    return '${list[0]}-${list[1]}';
  }
}
