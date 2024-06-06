import 'package:flutter/material.dart';

void pushAndRemoveView(context, {required String newRouteName}) {
  Navigator.pushNamedAndRemoveUntil(
    context,
    newRouteName,
    (route) => false,
  );
}
