import 'package:flutter/material.dart';
import 'package:social_media_app/shared/components/auth_icon.dart';

class AuthIocnList extends StatelessWidget {
  const AuthIocnList({super.key});

  @override
  Widget build(BuildContext context) {
    const List<String> images = [
      'lib/assets/images/facebook.png',
      'lib/assets/images/x.png',
      'lib/assets/images/google.png',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          // heigh = auth icon height
          height: 36,
          // width = auth icon width * numbers of auth icon
          //         + the sized box separator width * those number
          width:
              double.parse('${36 * images.length + 20 * (images.length - 1)}'),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => AuthIcon(
              image: images[index],
            ),
            separatorBuilder: (context, index) => const SizedBox(
              width: 20,
            ),
            itemCount: images.length,
          ),
        ),
      ],
    );
  }
}
