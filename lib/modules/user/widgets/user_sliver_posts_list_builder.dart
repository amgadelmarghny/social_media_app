import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';
import 'package:social_media_app/shared/components/post_item.dart';

class UserSliverPostsListBuilder extends StatelessWidget {
  const UserSliverPostsListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        UserCubit userCubit = context.read<UserCubit>();
        
        return SliverList.builder(
          itemCount: userCubit.postsModelList.length,
          itemBuilder: (context, index) {
            // Placeholder image for each grid item
            return Skeletonizer(
              enabled: state is GetUserPostsLoading,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: PostItem(
                  postModel: userCubit.postsModelList[index],
                  postId: userCubit.postsIdList[index],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
