import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'hashtag.dart';
import 'interactive_row.dart';
import 'profile_post_row.dart';

class PostItem extends StatelessWidget {
  const PostItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10 ,left: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff6D4ACD).withOpacity(0.40),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const ProfilePostRow(
            image:
                'https://avatars.githubusercontent.com/u/126693786?s=400&u=b1aebebdd8c0990c5bdb1c6b62cca90aebf2e247&v=4',
            userName: 'Amgad Marghny',
            timePosted: '5 minutes',
          ),
          Text(
            'This is a beautiful sky that i took last week. it\'s great, right ? :) scewvevjjjjjjjjjjjjjjjjjj jjhiuuuuuuuuuuuuu sssuhun un',
            style: FontsStyle.font15Popin(),
          ),
          // hashtags
          const Wrap(
            children: [
              Hashtag(
                title: '#Profile',
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(1.3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Image(
                fit: BoxFit.fitHeight,
                image: NetworkImage(
                  'https://storage.googleapis.com/fc-freepik-pro-rev1-eu-static/ai-styles-landings/dark/people.jpg?h=1280',
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const InteractiveRow(
            numOfLikes: '2000',
            numOfComments: '231',
          ),
        ],
      ),
    );
  }
}
