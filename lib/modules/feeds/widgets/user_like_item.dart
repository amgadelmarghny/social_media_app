import 'package:flutter/material.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class UserLikeItem extends StatelessWidget {
  const UserLikeItem({super.key, required this.userModel});
  final UserModel userModel;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              // TODO: move to user profile
              // Navigator.pushNamed(context, routeName);
            },
            child: Row(
              children: [
                ProfilePictureWithStory(
                  image: userModel.photo,
                  size: 70,
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    "${userModel.firstName} ${userModel.lastName}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: FontsStyle.font18PopinMedium(),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (userModel.uid != CacheHelper.getData(key: kUidToken))
          CustomButton(
            height: 40,
            fontSize: 18,
            width: 100,
            text: 'Follow',
            onTap: () {},
          )
      ],
    );
  }
}
