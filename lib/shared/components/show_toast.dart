import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({required String msg, required ToastState toastState}) {
  Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.TOP,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: toastColor(toastState),
      textColor: Colors.white,
      fontSize: 16.0);
}

enum ToastState { error, worrning, success }

Color toastColor(ToastState toastState) {
  late Color color;
  switch (toastState) {
    case ToastState.success:
      color = Colors.green;
      break;
    case ToastState.worrning:
      color = Colors.yellow;
      break;
    case ToastState.error:
      color = Colors.red;
  }
  return color;
}

void customSnakbar(context, {required String msg}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
    ),
  );
}
