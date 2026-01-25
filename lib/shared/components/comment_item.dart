import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readmore/readmore.dart';
import 'package:social_media_app/models/comment_model.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/user/user_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/image_viewer_screen.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import '../style/fonts/font_style.dart';
import 'custom_time_ago.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    super.key,
    required this.commentModel,
  });
  final CommentModel commentModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              UserModel userModel = await BlocProvider.of<SocialCubit>(context)
                  .getUserData(userUid: commentModel.userUid);
              if (context.mounted) {
                Navigator.pushNamed(
                  context,
                  UserView.routName,
                  arguments: userModel,
                );
              }
            },
            child: ProfilePictureWithStory(
              image: commentModel.profilePhoto,
              size: 70,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    color: Color(0xffCCC4D0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          UserModel userModel =
                              await BlocProvider.of<SocialCubit>(context)
                                  .getUserData(userUid: commentModel.userUid);
                          if (context.mounted) {
                            Navigator.pushNamed(
                              context,
                              UserView.routName,
                              arguments: userModel,
                            );
                          }
                        },
                        child: Text(
                          commentModel.userName,
                          style: FontsStyle.font21ColorBold,
                        ),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      if (commentModel.comment!.isNotEmpty)
                        ReadMoreText(
                          commentModel.comment!,
                          trimMode: TrimMode.Line,
                          trimLines: 3,
                          colorClickableText: Colors.pink,
                          trimCollapsedText: 'more',
                          trimExpandedText: ' less',
                          style: FontsStyle.font18PopinWithShadowOption(
                            isOverflow: false,
                            color: const Color(0xff6D4ACD),
                          ),
                          lessStyle: FontsStyle.font15Popin(
                              color: Colors.grey.shade600),
                          moreStyle: FontsStyle.font15Popin(
                              color: Colors.grey.shade600),
                        ),
                      if (commentModel.commentPhoto != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewerScreen(
                                    imageUrl: commentModel.commentPhoto!),
                              ),
                            );
                          },
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: commentModel.commentPhoto!,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    size: 30,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Row(
                //   children: [
                //     Text(
                //       timeAgo(commentModel.dateTime),
                //       style: FontsStyle.font18PopinWithShadowOption(
                //           isShadow: true),
                //     ),
                //     const Spacer(),
                //     TextButton(
                //       onPressed: () {
                        //TODO: Add Like Comment
                //       },
                //       child: Text(
                //         'Like',
                //         style: FontsStyle.font18PopinWithShadowOption(
                //             isShadow: true),
                //       ),
                //     ),
                //     const SizedBox(
                //       width: 15,
                //     ),
                //     TextButton(
                //       onPressed: () {
                         //TODO: Add reply Comment
                //       },
                //       child: Text(
                //         'Reply',
                //         style: FontsStyle.font18PopinWithShadowOption(
                //             isShadow: true),
                //       ),
                //     ),
                 // ],
              //   )
              ],
            ),
          )
        ],
      ),
    );
  }
}
