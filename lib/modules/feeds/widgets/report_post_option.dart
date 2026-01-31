import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/style/fonts/font_style.dart';

class ReportPostOption extends StatelessWidget {
  const ReportPostOption({
    super.key,
    required this.postId,
    required this.isItDeletedThroughPostView,
  });

  final String postId;
  final bool isItDeletedThroughPostView;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (context.mounted) Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController reasonController = TextEditingController();
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1D2B),
              title: const Text(
                "Report Post",
                style: TextStyle(color: Colors.white),
              ),
              content: TextField(
                controller: reasonController,
                minLines: 7,
                maxLines: 7,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter reason...",
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2B2B3D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    if (reasonController.text.isNotEmpty) {
                      Navigator.pop(context); // Close dialog
                      await BlocProvider.of<SocialCubit>(context)
                          .reportPost(
                        postId: postId,
                        reason: reasonController.text,
                      )
                          .then((value) {
                        if (context.mounted && isItDeletedThroughPostView) {
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                  child: const Text(
                    "Report",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
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
              child: const HugeIcon(
                icon: HugeIcons.strokeRoundedUserWarning01,
                color: Colors.red,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              'Report post',
              style: FontsStyle.font18PopinWithShadowOption(),
            )
          ],
        ),
      ),
    );
  }
}
