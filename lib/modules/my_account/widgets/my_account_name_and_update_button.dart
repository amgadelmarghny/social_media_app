import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/modules/edit_profile/edit_profile_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

class MyAccountNameAndUpdateButton extends StatelessWidget {
  const MyAccountNameAndUpdateButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BlocBuilder<SocialCubit, SocialState>(
          builder: (context, state) {
            SocialCubit socialCubit = context.read<SocialCubit>();
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Skeletonizer(
                      enabled: socialCubit.userModel == null,
                      child: Flexible(
                        child: Text(
                          '${socialCubit.userModel?.firstName} ${socialCubit.userModel?.lastName}',
                          style: FontsStyle.font20BoldWithColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Navigate to the edit profile view when edit button is pressed.
                        Navigator.pushNamed(
                            context, EditProfileView.routeViewName);
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
                    '@${socialCubit.userModel?.userName}',
                    style: FontsStyle.font18PopinWithShadowOption(),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
