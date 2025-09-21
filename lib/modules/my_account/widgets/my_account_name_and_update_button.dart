import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/edit_profile/edit_profile_view.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

class MyAccountNameAndUpdateButton extends StatelessWidget {
  const MyAccountNameAndUpdateButton({
    super.key,
    required this.userModel,
  });

  final UserModel? userModel;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Skeletonizer(
                  enabled: userModel == null,
                  child: Flexible(
                    child: Text(
                      '${userModel?.firstName} ${userModel?.lastName}',
                      style: FontsStyle.font20BoldWithColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Navigate to the edit profile view when edit button is pressed.
                    Navigator.pushNamed(context, EditProfileView.routeViewName);
                  },
                  icon: const Icon(
                    IconBroken.Edit_Square,
                    size: 32,
                    color: defaultTextColor,
                  ),
                  color: defaultTextColor,
                )
              ],
            ),
            Transform.translate(
              offset: const Offset(0.0, -10),
              child: Text(
                '@${userModel?.userName}',
                style: FontsStyle.font18Popin(),
              ),
            )
          ],
        ),
      ),
    );
  }
}