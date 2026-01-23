import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';

/// A widget that displays two action buttons for adding a photo and tags to a post.
/// The buttons are styled with a purple color and a popin font.
class NewPostBottomActionButtons extends StatelessWidget {
  const NewPostBottomActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain the SocialCubit instance from the context.
    SocialCubit socialCubit = context.read<SocialCubit>();

    return Row(
      children: [
        // Expanded widget for the "Add photo" button.
        Expanded(
          child: InkWell(
            // When tapped, open the image picker and assign the picked image to the cubit.
            onTap: () async {
              // Pick an image and assign it to the cubit.
              socialCubit.postImagePicked = await socialCubit.pickImage();
            },
            child: SizedBox(
              height: 50,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon for the photo button.
                    const Icon(
                      Icons.insert_photo_outlined,
                      color: defaultColorButton,
                      size: 30,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    // Text label for the photo button.
                    Text(
                      'Add photo',
                      style: FontsStyle.font18PopinWithShadowOption(
                          color: defaultColorButton),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        // Expanded widget for the "#tags" button.
        // TODO: Add Tages
        // Expanded(
        //   child: InkWell(
        //     // Currently, tapping this button does nothing.
        //     onTap: () {},
        //     child: SizedBox(
        //       height: 50,
        //       child: Center(
        //         child: Text(
        //           '#tags',
        //           style: FontsStyle.font18PopinWithShadowOption(
        //               color: defaultColorButton),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
