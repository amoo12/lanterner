import 'package:flutter/material.dart';

RaisedButton buttonWidget(
    BuildContext context, String text, Function onPressed) {
  return RaisedButton(
      padding: EdgeInsets.symmetric(vertical: 15),
      color: Theme.of(context).accentColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: Theme.of(context).textTheme.button,
      ),
      onPressed: onPressed);
}
