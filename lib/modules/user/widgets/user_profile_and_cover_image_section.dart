import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/modules/my_account/widgets/custom_cover_and_image_profile.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';

class UserProfileAndCoverImageSection extends StatelessWidget {
  const UserProfileAndCoverImageSection({
    super.key,
    required this.profileImage,
    required this.profileCover,
    required this.uid,
  });

  final String? profileImage, profileCover, uid;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Skeletonizer(
        enabled: uid == null,
        child: Stack(
          children: [
            CustomCoverAndImageProfile(
              profileImage: profileImage,
              profileCover: profileImage,
              isUsedInMyAccount:
                  context.read<SocialCubit>().userModel?.uid == uid,
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top,
              left: 15,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios),
              ),
            )
          ],
        ),
      ),
    );
  }
}