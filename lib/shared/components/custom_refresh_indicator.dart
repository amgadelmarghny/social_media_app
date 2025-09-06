import 'package:flutter/material.dart';

class CustomRefreshIndicator extends StatelessWidget {
  const CustomRefreshIndicator(
      {super.key, required this.child, required this.onRefresh});
  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xffC58DEB),
      backgroundColor: const Color(0xff8862D9),
      strokeWidth: 1.0,
      child: child,
    );
  }
}
