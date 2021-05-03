import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/pages/login.dart';
import 'package:lanterner/providers/auth_provider.dart';

class Wrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    // final user = Provider.of<User>(context);
    // return either home or authenticate widget
    final _authState = watch(authStateProvider);
    // print(user);
    return _authState.when(
      data: (value) {
        print('ok');
        if (value != null) {
          return Scaffold(
            body: Center(
              child: Text('home'),
            ),
          );
        }
        return Login();
      },
      loading: () {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (_, __) {
        return Scaffold(
          body: Center(
            child: Text("OOPS"),
          ),
        );
      },
    );
  }
}
