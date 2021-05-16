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
    return await usersCollection.doc(uid).set(user.toMap());
  }

  // inserts a new post record
  Future createPost(Post post) async {
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

//update profile photo url in user document
  Future<void> updateProfilePicture(String uid, String photoUrl) {
    return usersCollection.doc(uid).update({
      'photoUrl': photoUrl,
    });
  }
}
