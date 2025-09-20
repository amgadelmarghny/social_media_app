import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

/// A widget that displays menu items for cover image actions.
///
/// [isUsedInMyAccount] determines if the actions are enabled (for the current user's account).
class CoverImageMenuItem extends StatelessWidget {
  /// Constructor for [CoverImageMenuItem].
  ///
  /// [isUsedInMyAccount] specifies if the menu is used in the context of the current user's account.
  const CoverImageMenuItem({super.key, required this.isUsedInMyAccount});

  /// Whether this menu is used in the context of the current user's account.
  final bool isUsedInMyAccount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // =========================
        // Upload Cover Photo option
        // =========================
        GestureDetector(
          onTap: () {
            // Only allow uploading if used in "My Account"
            if (isUsedInMyAccount) {
              // Trigger picking and uploading a new cover image
              BlocProvider.of<SocialCubit>(context).pickAndUploadCoverImage();
              // Close the popover/menu after uploading
              Navigator.pop(context);
            }
          },
          child: Container(
            height: 50,
            color:
                const Color(0xff8862D9), // Background color for upload option
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon for upload action
                CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  radius: 15,
                  child: const Icon(Icons.file_upload_sharp),
                ),
                const SizedBox(
                  width: 5,
                ),
                // Label for upload action
                Text(
                  'Upload photo',
                  style: FontsStyle.font18Popin(),
                )
              ],
            ),
          ),
        ),
        // =========================
        // See Cover Photo option
        // =========================
        GestureDetector(
          onTap: () {
            // TODO: Implement functionality to view the cover photo
            // This is currently a placeholder for the "See cover photo" action
          },
          child: Container(
            height: 50,
            color: const Color(
                0xffA879E2), // Background color for see photo option
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon for viewing photo action
                CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  radius: 15,
                  child: const Icon(
                    Icons.photo_outlined,
                    size: 22.5,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                // Label for see cover photo action
                Text(
                  'See cover photo',
                  style: FontsStyle.font18Popin(),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
