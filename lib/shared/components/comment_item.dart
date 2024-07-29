import 'package:flutter/material.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import '../style/fonts/font_style.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfilePictureWithStory(
          image:
              'https://firebasestorage.googleapis.com/v0/b/social-app-97290.appspot.com/o/users%2Fprofile%2FIMG_20210310_082337.jpg?alt=media&token=a59cec17-25c5-462d-826b-9419816e6ef4',
          size: 70,
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xffCCC4D0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amgad Marghny',
                      style: FontsStyle.font21ColorBold,
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Text(
                      'Amgad Marghnydrgrkscewrvbbbbbbjjjjjjjj',
                      style: FontsStyle.font18Popin(
                          isOverflow: false, color: const Color(0xff6D4ACD)),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    '1 hour',
                    style: FontsStyle.font18Popin(isShadow: true),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Like',
                      style: FontsStyle.font18Popin(isShadow: true),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Reply',
                      style: FontsStyle.font18Popin(isShadow: true),
                    ),
                  ),
                  const Spacer(
                    flex: 5,
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
