import 'package:flutter/material.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import '../style/fonts/font_style.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    super.key,
    required this.userName,
    required this.commentContent,
    required this.dateTime,
    required this.profilePhoto,
  });
  final String? profilePhoto;
  final String userName;
  final String commentContent;
  final String dateTime;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfilePictureWithStory(
          image: profilePhoto,
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
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xffCCC4D0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: FontsStyle.font21ColorBold,
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    if (commentContent.isNotEmpty)
                      Text(
                        commentContent,
                        style: FontsStyle.font18Popin(
                          isOverflow: false,
                          color: const Color(0xff6D4ACD),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    dateTime,
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
