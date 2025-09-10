import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/edit_profile/edit_profile_view.dart';
import 'package:social_media_app/modules/users/widgets/custom_cover_and_image_profile.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../shared/style/theme/constant.dart';
import 'widgets/custom_follower_following_row.dart';
import 'widgets/follow_and_message_buttons.dart';

class UsersBody extends StatelessWidget {
  const UsersBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialState>(
      listener: (context, state) {
        if (state is PickImageFailureState) {
          showToast(msg: state.errMessage, toastState: ToastState.worrning);
        }
        if (state is UploadProfileImageFailureState) {
          showToast(msg: state.errMessage, toastState: ToastState.worrning);
        }
        if (state is UploadCoverImageFailureState) {
          showToast(msg: state.errMessage, toastState: ToastState.worrning);
        }
        if (state is UploadCoverImageSuccessState ||
            state is UploadProfileImageSuccessState) {
          showToast(msg: 'Added successfully', toastState: ToastState.success);
        }
      },
      builder: (context, state) {
        UserModel userModel = BlocProvider.of<SocialCubit>(context).userModel!;
        return Column(
          children: [
            CustomCoverAndImageProfile(
              profileImage: userModel.photo,
              profileCover: userModel.cover,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '${userModel.firstName} ${userModel.lastName}',
                      style: FontsStyle.font20BoldWithColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, EditProfileView.routeViewName);
                    },
                    icon: const Icon(
                      IconBroken.Edit_Square,
                      size: 32,
                      color: defaultColor,
                    ),
                    color: defaultColor,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  const FollowAndMessageButtons(),
                  const SizedBox(
                    height: 15,
                  ),
                  if (userModel.bio != null)
                    Text(
                      '"${userModel.bio}"',
                      style: FontsStyle.font20Poppins,
                    ),
                  GridView.builder(
                    clipBehavior: Clip.none,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 20,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.95,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      return Image.network(
                        fit: BoxFit.cover,
                        'https://img.freepik.com/free-psd/travel-tourism-facebook-cover-template_106176-2350.jpg?t=st=1718837003~exp=1718840603~hmac=ee693122a4a6abe55342026a5443a20b35e53b8ec5c6c4a8cddcb53e87314dba&w=1380',
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
