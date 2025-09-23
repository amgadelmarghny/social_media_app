import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/post_item.dart';

class MySliverPostsListAccount extends StatelessWidget {
  const MySliverPostsListAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        SocialCubit socialCubit = context.read<SocialCubit>();
        return SliverList.builder(
          itemCount: socialCubit.postsModelList.length,
          itemBuilder: (context, index) {
            // Placeholder image for each grid item
            return Skeletonizer(
              enabled: state is GetMyDataLoadingState,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: PostItem(
                  postModel: socialCubit.postsModelList[index],
                  postId: socialCubit.postsIdList[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
