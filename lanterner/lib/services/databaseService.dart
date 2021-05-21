// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/models/user.dart';

// this class talks to cloud firestore and manages queries
class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  // inserts a new user record in Firestore
  Future insertUser(User user) async {
    user.setSearchParameters();
    return await usersCollection.doc(uid).set(user.toMap());
  }

  // inserts a new post record
  Future createPost(Post post) async {
    // var batch = FirebaseFirestore.instance.batch();
    // var newPostRef = postsCollection.doc();
    // //update user postsCount
    // batch.update(usersCollection.doc(post.ownerId),
    //     {'postsCount': FieldValue.increment(1)});
    // // add the post to the posts collection
    // batch.set(newPostRef, post.toMap());
    // print('posted');
    await usersCollection
        .doc(post.ownerId)
        .update({'postsCount': FieldValue.increment(1)});
    return await postsCollection.add(post.toMap());
  }

//returns user user data (takes a user id)
  Future<User> getUser(String uid) async {
    return await usersCollection
        .doc(uid)
        .get()
        .then((doc) => User.fromMap(doc));
  }

//get all users posts
  Future<List<Post>> getPosts() async {
    return await postsCollection
        .get()
        .then((value) => value.docs.map((doc) => Post.fromMap(doc)).toList());
  }

//get a user's posts
  Future<List<Post>> getUserPosts(String uid) async {
    return await postsCollection
        .where('ownerId', isEqualTo: uid)
        .get()
        .then((value) => value.docs.map((doc) => Post.fromMap(doc)).toList());
  }

//update profile photo url in user document
  Future<void> updateProfilePicture(String uid, String photoUrl) {
    return usersCollection.doc(uid).update({
      'photoUrl': photoUrl,
    });
  }

  Future<List<User>> searchUsers(String searchText) async {
    return await usersCollection
        .where('searchOptions', arrayContains: searchText)
        .get()
        .then((value) => value.docs.map((doc) => User.fromMap(doc)).toList());
  }

  Future<void> follow(String uid, User currrentUser) async {
    var batch = FirebaseFirestore.instance.batch();
    User followedUser = await getUser(uid);

    //* current user
    // add the user document to the followingsub-collection
    batch.set(
        usersCollection.doc(currrentUser.uid).collection('following').doc(uid),
        followedUser.toMap());
    // increase the following count on the stast document within the sub-collection
    batch.set(
        usersCollection
            .doc(currrentUser.uid)
            .collection('following')
            .doc('stats'),
        {'following': FieldValue.increment(1)});
    // increase the following count on the user document
    batch.update(usersCollection.doc(currrentUser.uid),
        {'following': FieldValue.increment(1)});

//* followed user
// delete the user document from the followingsub-collection
    batch.set(
        usersCollection.doc(uid).collection('followers').doc(currrentUser.uid),
        currrentUser.toMap());

    // decrease the followers count on the stast document within the sub-collection
    batch.set(usersCollection.doc(uid).collection('followers').doc('stats'),
        {'followers': FieldValue.increment(1)});

    // increase the followers count on the user document
    batch.update(
        usersCollection.doc(uid), {'followers': FieldValue.increment(1)});

    batch.commit();
  }

  Future unfollow(String uid, User currrentUser) {
    var batch = FirebaseFirestore.instance.batch();
    //* current user
    // delete the user document from the followingsub-collection
    batch.delete(
        usersCollection.doc(currrentUser.uid).collection('following').doc(uid));
// decrease the following count on the stast document within the sub-collection
    batch.update(
        usersCollection
            .doc(currrentUser.uid)
            .collection('following')
            .doc('stats'),
        {'following': FieldValue.increment(-1)});
    // decrease the following count on the user document
    batch.update(usersCollection.doc(currrentUser.uid),
        {'following': FieldValue.increment(-1)});

    //* unfollowed user
    // delete the user document from the followingsub-collection
    batch.delete(
        usersCollection.doc(uid).collection('followers').doc(currrentUser.uid));
    // decrease the followers count on the stast document within the sub-collection
    batch.update(usersCollection.doc(uid).collection('followers').doc('stats'),
        {'followers': FieldValue.increment(-1)});
// decrease the followers count on the user document
    batch.update(
        usersCollection.doc(uid), {'followers': FieldValue.increment(-1)});

    // commit the batch
    batch.commit();
  }

  Future<bool> isFollowing(String uid, String currentUserId) async {
    QuerySnapshot querySnapshot =
        await usersCollection.doc(uid).collection('followers').limit(1).get();
    if (querySnapshot.size > 0) {
      return await usersCollection
          .doc(uid)
          .collection('followers')
          .doc(currentUserId)
          .get()
          .then((doc) {
        if (doc.exists) {
          return true;
        } else {
          return false;
        }
      });
    } else {
      return false;
    }
  }
}
