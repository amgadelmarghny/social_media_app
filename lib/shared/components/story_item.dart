import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class StoryItem extends StatelessWidget {
  const StoryItem({super.key, required this.image, required this.firstName});
  final String image;
  final String firstName;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.all(4),
            width: 80,
            decoration: const ShapeDecoration(
              shape: CircleBorder(
                side: BorderSide(
                  color: Color(0xffC79BE7),
                  width: 3,
                ),
              ),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(image),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            firstName,
            style: FontsStyle.font18Popin(),
          )
        ],
      ),
    );
  }
}
