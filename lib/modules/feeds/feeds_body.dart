import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/feeds/widgets/upload_post_demo_widget.dart';
import 'package:social_media_app/shared/components/post_item.dart';
import 'package:social_media_app/modules/feeds/widgets/story_list_view.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../shared/bloc/comments_cubit/comments_cubit.dart';
import '../../shared/bloc/social_cubit/social_cubit.dart';

class FeedsBody extends StatelessWidget {
  const FeedsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
        ),
        child: BlocConsumer<SocialCubit, SocialState>(
          listener: (BuildContext context, SocialState state) {
            if (state is CreatePostSuccessState) {
              BlocProvider.of<SocialCubit>(context).removePost();
              showToast(
                  msg: 'Post added successfully',
                  toastState: ToastState.success);
            }
            if (state is UploadPostImageFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is LikePostFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
            if (state is CreatePostFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
          },
          builder: (BuildContext context, SocialState state) {
            SocialCubit socialCubit = BlocProvider.of<SocialCubit>(context);
            return Column(
              mainAxisSize: MainAxisSize.max,
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
                if (socialCubit.postContentController.text.isNotEmpty ||
                    socialCubit.postImagePicked != null)
                  if (state is CreatePostLoadingState ||
                      // if failure show keep showing this widget
                      // to cancel adding post or upload it again
                      state is UploadPostImageFailureState ||
                      state is CreatePostFailureState)
                    const UploadPostDemo(),
                // post
                ConditionalBuilder(
                  condition: socialCubit.postsModelList.isNotEmpty,
                  builder: (context) {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: socialCubit.postsModelList.length,
                      itemBuilder: (context, index) {
                        return PostItem(
                          postModel: socialCubit.postsModelList[index],
                          postId: socialCubit.postsIdList[index],
                          userModel: socialCubit.userModel!,
                        );
                      },
                    );
                  },
                  fallback: (context) => Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.sizeOf(context).height / 5),
                    child: Text(
                      'There is no posts yet',
                      style: FontsStyle.font20Poppins,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
