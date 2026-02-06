import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/style/fonts/font_style.dart';

class DeletePostOption extends StatelessWidget {
  const DeletePostOption({
    super.key,
    required this.postId,
    required this.isItDeletedThroughPostView,
  });

  final String postId;
  final bool isItDeletedThroughPostView;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        return AbsorbPointer(
          absorbing: state is RemovePostLoadingState,
          child: GestureDetector(
            onTap: () async {
              if (context.mounted) Navigator.pop(context);
              await BlocProvider.of<SocialCubit>(context)
                  .deletePost(postId)
                  .then((value) {
                // If we're in PostView (detail view), pop back to feed after deletion
                if (context.mounted && isItDeletedThroughPostView) {
                  Navigator.pop(context);
                }
              });
            },
            child: Container(
              height: 50,
              color: const Color(0xff8862D9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    radius: 15,
                    child: state is RemovePostLoadingState
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete03,
                            color: Colors.red,
                          ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Delete post',
                    style: FontsStyle.font18PopinWithShadowOption(),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
