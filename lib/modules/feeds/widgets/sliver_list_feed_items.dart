import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/post_item.dart';

class SliverListfeedItems extends StatelessWidget {
  const SliverListfeedItems({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        SocialCubit socialCubit = context.read<SocialCubit>();
        return SliverList.builder(
          itemBuilder: (context, index) {
            return Skeletonizer(
              enabled: state is GetFeedsPostsLoadingState,
              child: PostItem(
                postModel: socialCubit.friendsPostsModelList[index],
                postId: socialCubit.friendsPostsIdList[index],
              ),
            );
          },
          itemCount: socialCubit.friendsPostsModelList.length,
        );
      },
    );
  }
}
