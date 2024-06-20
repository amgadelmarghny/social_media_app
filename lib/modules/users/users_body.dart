import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:social_media_app/modules/users/widgets/custom_cover_and_image_profile.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../shared/style/theme/constant.dart';
import 'widgets/custom_follower_following_row.dart';

class UsersBody extends StatelessWidget {
  const UsersBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const CustomCoverAndImageProfile(
            profileImage:
                'https://avatars.githubusercontent.com/u/126693786?s=400&u=b1aebebdd8c0990c5bdb1c6b62cca90aebf2e247&v=4',
            profileCover:
                'https://img.freepik.com/free-psd/travel-tourism-facebook-cover-template_106176-2350.jpg?t=st=1718837003~exp=1718840603~hmac=ee693122a4a6abe55342026a5443a20b35e53b8ec5c6c4a8cddcb53e87314dba&w=1380',
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Amgad Marghny',
                style: FontsStyle.font20BoldWithColor,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  IconBroken.Edit_Square,
                  size: 32,
                  color: defaultColor,
                ),
                color: defaultColor,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              // Specify a height here to provide constraints
              height: MediaQuery.of(context).size.height *
                  0.7, // Adjust the multiplier as needed
              child: Column(
                children: [
                  const CustomPostFollowersFollowingRow(
                    numOfPosts: '148',
                    numOfFollowers: '12K',
                    numOfFollowing: '200',
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          height: 50,
                          text: 'Follow',
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: CustomButton(
                          text: 'Message',
                          height: 50,
                          buttonColor: Colors.white,
                          textColor: const Color(0xFF635A8F),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '"I can draw my life by myself"',
                    style: FontsStyle.font20Poppins,
                  ),
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 30,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 0.95,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              crossAxisCount: 2),
                      itemBuilder: (context, index) {
                        return Image.network(
                          fit: BoxFit.cover,
                          'https://img.freepik.com/free-psd/travel-tourism-facebook-cover-template_106176-2350.jpg?t=st=1718837003~exp=1718840603~hmac=ee693122a4a6abe55342026a5443a20b35e53b8ec5c6c4a8cddcb53e87314dba&w=1380',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
