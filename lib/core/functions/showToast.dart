import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(String title, Color? backgroundColor) {
  Fluttertoast.showToast(
    msg: title,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 0,
    backgroundColor: backgroundColor,
    textColor: const Color.fromRGBO(255, 255, 255, 1),
    fontSize: 16.0,
  );
}
