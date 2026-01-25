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
          itemCount: socialCubit.myPostsModelList.isEmpty &&
                  (state is GetMyDataLoadingState || state is GetMyPostsLoading)
              ? 3 // Show 3 skeleton items while loading
              : socialCubit.myPostsModelList.length,
          itemBuilder: (context, index) {
            // Placeholder image for each grid item
            return Skeletonizer(
              enabled:
                  state is GetMyDataLoadingState || state is GetMyPostsLoading,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: socialCubit.myPostsModelList.isNotEmpty
                    ? PostItem(
                        postModel: socialCubit.myPostsModelList[index],
                        postId: socialCubit.myPostsIdList[index],
                      )
                    : Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: const Center(
                          child:
                              Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
