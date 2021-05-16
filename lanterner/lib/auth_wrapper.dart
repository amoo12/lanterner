import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/pages/bottomNavigationBar.dart';
import 'package:lanterner/pages/authentication/login.dart';
import 'package:lanterner/providers/auth_provider.dart';

class Wrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    // return either home or authenticate widget
    final _authState = watch(authStateProvider);
    return _authState.when(
      data: (value) {
        if (value != null) {
          return MyBottomNavBar();
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
