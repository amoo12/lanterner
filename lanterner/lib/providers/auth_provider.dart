import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/models/user.dart' as userModel;
import 'package:lanterner/services/auth_service.dart';
import 'package:lanterner/services/databaseService.dart';

DatabaseService db = DatabaseService();

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authServicesProvider = Provider<AuthenticationService>(
    (ref) => AuthenticationService(ref.read(firebaseAuthProvider)));

final authStateProvider = StreamProvider.autoDispose<User>(
    (ref) => ref.watch(authServicesProvider).authStateChange);

final userProvider = FutureProvider.autoDispose<userModel.User>((ref) async {
  return await db.userStream(ref.watch(authStateProvider).data.value.uid).first;
});
