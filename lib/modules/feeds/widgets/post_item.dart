import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class PostItem extends StatelessWidget {
  const PostItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff6D4ACD).withOpacity(0.40),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const ProfilePictureWithStory(
                image:
                    'https://avatars.githubusercontent.com/u/126693786?s=400&u=b1aebebdd8c0990c5bdb1c6b62cca90aebf2e247&v=4',
              ),
              const SizedBox(
                width: 3,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amgad Marghny',
                      style: FontsStyle.font18PopinBold(),
                    ),
                    Text(
                      '5 minute',
                      style: FontsStyle.font15Popin(
                          height: 1, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // post written
                Text(
                  'This is a beautiful sky that i took last week. it’s great, right ? :) scewvevjjjjjjjjjjjjjjjjjj jjhiuuuuuuuuuuuuu sssuhun un',
                  style: FontsStyle.font15Popin(),
                ),
                // hashtags
                Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: SizedBox(
                        height: 19,
                        child: MaterialButton(
                          onPressed: () {},
                          minWidth: 1,
                          padding: EdgeInsets.zero,
                          child: Text(
                            '#picture',
                            style: FontsStyle.font15Popin(
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ),
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
                          'https://storage.googleapis.com/fc-freepik-pro-rev1-eu-static/ai-styles-landings/dark/people.jpg?h=1280'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'lib/assets/images/like.svg',
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-7, 0),
                      child: Text(
                        '999',
                        style: FontsStyle.font18Popin(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'lib/assets/images/comments.svg',
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '999',
                            style: FontsStyle.font18Popin(),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'lib/assets/images/send.svg',
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
