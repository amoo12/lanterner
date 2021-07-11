import 'package:firebase_auth/firebase_auth.dart';
import 'package:lanterner/models/user.dart' as u;

import 'databaseService.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  AuthenticationService(this._firebaseAuth);

  Stream<User> get authStateChange => _firebaseAuth.authStateChanges();

  // sign in  a registered user
  Future<String> signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return "Login Successful"; //
    } on FirebaseAuthException catch (e) {
      return e
          .message; // return the error message can be used to give feedback to the user
    }
  }

  // creates a new firebase user
  Future<String> signUp(u.User user) async {
    // recives a local user object holding user's profile details
    try {
      UserCredential creCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      user.uid = creCredential.user.uid;
      await DatabaseService(uid: creCredential.user.uid)
          .insertUser(user); // inserts the new user record in firestore

      return "Signup Successful";
    } on FirebaseAuthException catch (e) {
      return e
          .message; // return the error message, can be used to give feedback to the user
    }
  }

  // sign out.
  Future<void> signout() async {
    await _firebaseAuth.signOut();
  }



}
