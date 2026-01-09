import 'package:flutter/material.dart';
import '../../../shared/style/fonts/font_style.dart';

class Hashtag extends StatelessWidget {
  const Hashtag({
    super.key,
    required this.title,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: SizedBox(
        height: 19,
        child: MaterialButton(
          onPressed: () {},
          minWidth: 1,
          padding: EdgeInsets.zero,
          child: Text(
            title,
            style: FontsStyle.font15Popin(
              color: Colors.white60,
            ),
          ),
        ),
      ),
    );
  }
}
