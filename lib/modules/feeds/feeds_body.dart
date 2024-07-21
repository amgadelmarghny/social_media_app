import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/feeds/widgets/upload_post_demo_widget.dart';
import 'package:social_media_app/shared/components/post_item.dart';
import 'package:social_media_app/modules/feeds/widgets/story_list_view.dart';
import 'package:social_media_app/shared/components/show_toast.dart';

import '../../shared/bloc/social_cubit/social_cubit.dart';

class FeedsBody extends StatelessWidget {
  const FeedsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
        ),
        child: BlocConsumer<SocialCubit, SocialState>(
          listener: (BuildContext context, SocialState state) {
            if (state is CreatePostSuccessState) {
              BlocProvider.of<SocialCubit>(context).cancelUploadPost();
              showToast(
                  msg: 'Post added successfully',
                  toastState: ToastState.success);
            }
            if (state is UploadPostImageFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is CreatePostFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
          },
          builder: (BuildContext context, SocialState state) {
            return Column(
              children: [
                SearchBar(
                  hintText: 'Explore',
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const StoryListView(),
                const SizedBox(
                  height: 20,
                ),
                // upload post demo
                if (BlocProvider.of<SocialCubit>(context)
                        .postContentController
                        .text
                        .isNotEmpty ||
                    BlocProvider.of<SocialCubit>(context).postImagePicked !=
                        null)
                  if (state is CreatePostLoadingState ||
                      state is UploadPostImageFailureState ||
                      state is CreatePostFailureState)
                    const UploadPostDemo(),
                // post
                const PostItem()
              ],
            );
          },
        ),
      ),
    );
  }
}
