import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/pages/login.dart';
import 'package:lanterner/providers/auth_provider.dart';

class Wrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    // return either home or authenticate widget
    final _authState = watch(authStateProvider);
    final _auth = watch(authServicesProvider);
    return _authState.when(
      data: (value) {
        if (value != null) {
          return Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {
                  _auth.signout();
                },
                child: Text('signout'),
              ),
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
