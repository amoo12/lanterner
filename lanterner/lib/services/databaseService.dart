// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanterner/models/comment.dart';
import 'package:lanterner/models/post.dart';
import 'package:lanterner/models/user.dart';

// this class talks to cloud firestore and manages queries
class DatabaseService {
  final String uid;
  final String postId;
  DatabaseService({this.uid, this.postId});

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

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
    // print('posted');
    await usersCollection
        .doc(post.user.uid)
        .update({'postsCount': FieldValue.increment(1)});
    return await postsCollection.add(post.toMap());
  }

//returns user user data (takes a user id)
  Future<User> getUser(String uid) async {
    return await usersCollection
        .doc(uid)
        .get()
        .then((doc) => User.fromSnapShot(doc));
  }

//get all users posts
  Future<List<Post>> getPosts() async {
    return await postsCollection
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) => value.docs.map((doc) => Post.fromMap(doc)).toList());
  }

//get a user's posts
  Future<List<Post>> getUserPosts(String uid) async {
    return await postsCollection
        .where('user.uid', isEqualTo: uid)
        .orderBy('timestamp')
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
  Future<void> updateProfilePicture(String uid, String photoUrl) {
    return usersCollection.doc(uid).update({
      'photoUrl': photoUrl,
    });
  }

  Future<List<User>> searchUsers(String searchText) async {
    return await usersCollection
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
    QuerySnapshot querySnapshot =
        await usersCollection.doc(uid).collection('followers').limit(1).get();
    if (querySnapshot.size > 0) {
      // if there's at least one uesr check if I follow them

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

    var batch = FirebaseFirestore.instance.batch();

    // assign new doc id to the comment
    comment.cid = ref.id;
    // add the doc to the collection
    batch.set(postsCollection.doc(postId).collection('comments').doc(ref.id),
        comment.toMap());

    //commit batch
    batch.commit();
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
}
