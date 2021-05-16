import 'package:flutter/material.dart';

customProgressIdicator(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
          color: Theme.of(context).primaryColor,
          child: Center(
            child: CircularProgressIndicator(backgroundColor: Colors.white),
          ),
        );
      });
}
