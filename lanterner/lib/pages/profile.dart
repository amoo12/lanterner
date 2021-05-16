import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lanterner/providers/auth_provider.dart';

//ignore: must_be_immutable
class Profile extends ConsumerWidget {
  final BuildContext menuScreenContext;
  final Function hideNav;
  final Function showNav;
  final Function onScreenHideButtonPressed;
  bool hideStatus;
  Profile(
      {Key key,
      this.menuScreenContext,
      this.hideNav,
      this.showNav,
      this.onScreenHideButtonPressed,
      this.hideStatus = false})
      : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final _auth = watch(authServicesProvider);
    return Container(
      child: Center(
        child: TextButton(
          onPressed: () {
            _auth.signout();
          },
          child: Text('signout'),
        ),
      ),
    );
  }
}
