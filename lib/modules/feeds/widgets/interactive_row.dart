import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_media_app/modules/feeds/widgets/comments_sheet.dart';
import 'package:social_media_app/modules/feeds/widgets/users_suggestion_sheet.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/style/fonts/font_style.dart';

class InteractiveRow extends StatelessWidget {
  const InteractiveRow({
    super.key,
    required this.numOfLikes,
    required this.isLike,
    this.onLikeButtonTap,
    required this.postId,
    this.showCommentSheet = true,
    required this.commentsNum,
    required this.creatorUid,
    required this.authorName,
    required this.postText,
    required this.postImage,
  });

  final int numOfLikes, commentsNum;
  final String postId, creatorUid;
  final bool isLike;
  final void Function()? onLikeButtonTap;
  final bool showCommentSheet;
  final String authorName;
  final String? postText, postImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<SocialCubit, SocialState>(
          builder: (context, state) {
            return AbsorbPointer(
              absorbing: state is ToggleLikeLoadingState,
              child: IconButton(
                onPressed: onLikeButtonTap,
                icon: isLike
                    ? SvgPicture.asset(
                        'lib/assets/images/like.svg',
                      )
                    : const Icon(Icons.favorite_border),
              ),
            );
          },
        ),
        if (numOfLikes > 0)
          Transform.translate(
            offset: const Offset(-7, 0),
            child: InkWell(
              onTap: () async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor:
                          1.0, // This makes the bottom sheet take the full height
                      child: UsersSuggestionsSheet(
                        userModelList:
                            context.read<SocialCubit>().userModelList,
                      ),
                    );
                  },
                );
                await context
                    .read<SocialCubit>()
                    .getUsersLikesInPost(postId: postId);
              },
              child: Text(
                numOfLikes.toString(),
                style: FontsStyle.font18PopinWithShadowOption(),
              ),
            ),
          ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: showCommentSheet
              ? () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor:
                            1.0, // This makes the bottom sheet take the full height
                        child: CommentsSheet(
                          postId: postId,
                          commentsNum: commentsNum,
                          creatorUid: creatorUid,
                        ),
                      );
                    },
                  );
                }
              : null,
          child: Row(
            children: [
              SvgPicture.asset(
                'lib/assets/images/comments.svg',
              ),
              const SizedBox(
                width: 5,
              ),
              if (commentsNum > 0)
                Text(
                  commentsNum.toString(),
                  style: FontsStyle.font18PopinWithShadowOption(),
                )
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () async {
            if (postText != null) {
              final String contentToShare =
                  'Check out this post by $authorName:\n\n$postText\n\n- Sent from zmlni application';

              await SharePlus.instance.share(ShareParams(text: contentToShare));
            }
            if (postImage != null) {
              final url = Uri.parse(postImage!);
              final response = await http.get(url);
              final bytes = response.bodyBytes;

              final temp = await getTemporaryDirectory();
              final path = '${temp.path}/image.jpg';
              File(path).writeAsBytesSync(bytes);

              await SharePlus.instance
                  .share(ShareParams(files: [XFile(path)], text: postText));
            }
          },
          icon: SvgPicture.asset(
            'lib/assets/images/share.svg',
          ),
        ),
      ],
    );
  }
}
