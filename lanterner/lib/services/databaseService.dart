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
    return await usersCollection.doc(uid).set({
      'name': user.name,
      'email': user.email,
      'gender': user.gender,
      'dateofBirth': user.dateOfBirth,
      'nativeLanguage': {
        'title': user.nativeLanguage.title,
        'code': user.nativeLanguage.code,
        'level': user.nativeLanguage.level ?? '5',
        'isNative': user.nativeLanguage.isNative,
      },
      'targetLanguage': {
        'title': user.targetLanguage.title,
        'code': user.targetLanguage.code,
        'level': user.targetLanguage.level,
        'isNative': user.targetLanguage.isNative,
      },
    });
  }

  // inserts a new post record
  Future createPost(Post post) async {
    return await postsCollection.add(post.toMap(post));
  }

  Future<User> getUser(String uid) async {
    return await usersCollection
        .doc(uid)
        .get()
        .then((doc) => User.fromMap(doc));
  }

  Future<List<Post>> getPosts() async {
    // // List<Post> list;
    // return list = await postsCollection.get().then((value) {
    //   // Post post = Post();
    //   for (var i = 0; i < value.docs.length; i++) {
    //     Post post = Post.fromMap(value.docs[i]);
    //     list.add(post);
    //   }
    //   return list;
    // for (var item in value.docs) {
    //   // print(item);
    //   // Post post = Post.fromMap(item);
    //   Post post = Post.fromMap(item);

    //   print(post.username);
    // print(post.photoUrl);
    // return post;
    // }
    // });

    // .get()
    // .then((doc) => User.fromMap(doc));
  }

  List<Post> postFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => Post.fromMap(doc)).toList();
  }
}
