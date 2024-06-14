import 'package:flutter/material.dart';
import '../../../shared/components/profile_picture_with_story.dart';
import '../../../shared/style/fonts/font_style.dart';

class ProfilePostRow extends StatelessWidget {
  const ProfilePostRow({
    super.key,
    required this.image,
    required this.userName,
    this.timePosted,
  });
  final String image;
  final String userName;
  final dynamic timePosted;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ProfilePictureWithStory(
          image: image,
        ),
        const SizedBox(
          width: 3,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: FontsStyle.font18PopinBold(),
              ),
              Text(
                timePosted,
                style: FontsStyle.font15Popin(
                  height: 1,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
