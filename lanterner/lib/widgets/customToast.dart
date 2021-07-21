import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(FToast fToast, String message, [int duration = 1]) {
  Widget toast = Container(
    // width: MediaQuery.of(context).size.width * 0.9,
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.amberAccent.shade100.withOpacity(0.9)),
    child: Row(
      children: [
        Flexible(
          child: Text(
            message,
            style: TextStyle(color: Colors.grey.shade800),
          ),
        ),
      ],
    ),
  );

  fToast.showToast(
    
    child: toast,
    gravity: ToastGravity.TOP,
    toastDuration: Duration(seconds: duration),
  );
}
