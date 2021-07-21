import 'package:flutter/material.dart';

customProgressIdicator(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Container(
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Colors.white),
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        );
      });
}

circleIndicator(BuildContext context, [Color color]) {
  return Container(
    color: color ?? Theme.of(context).primaryColor,
    child: Center(
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50), color: Colors.white),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
          ),
        ),
      ),
    ),
  );
}
