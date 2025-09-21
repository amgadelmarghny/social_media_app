import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:popover/popover.dart';
import 'package:social_media_app/modules/login/login_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/components/profile_picture_with_story.dart';
import 'cover_image_menu_items.dart';
import 'profile_image_menu_items.dart';

/// A custom widget that displays a user's profile cover image and profile picture
/// in a stacked layout. The cover image takes up the top portion of the container,
/// while the profile picture is positioned at the bottom center, overlapping the cover.
///
/// This widget supports interactive functionality where users can tap on either
/// the cover image or profile picture to show context menus for editing options.
class CustomCoverAndImageProfile extends StatelessWidget {
  /// Creates a [CustomCoverAndImageProfile] widget.
  ///
  /// [profileImage] is the URL of the user's profile picture.
  /// [profileCover] is the URL of the user's cover image.
  /// [isUsedInMyAccount] determines if the widget is used in the user's own account.
  const CustomCoverAndImageProfile({
    super.key,
    required this.profileImage,
    required this.profileCover,
    this.isUsedInMyAccount = false,
  });

  /// The URL of the user's profile picture image.
  final String? profileImage;

  /// The URL of the user's cover image.
  final String? profileCover;

  /// Determines if this widget is being used in the user's own account view
  /// vs. viewing another user's profile. Affects the menu options shown.
  final bool isUsedInMyAccount;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing.
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    return Stack(
      // Allow widgets to extend beyond the stack boundaries.
      clipBehavior: Clip.none,
      children: [
        // Cover image container with bottom padding for the profile picture overlap.
        Padding(
          // Add bottom padding to account for the overlapping profile picture.
          padding: const EdgeInsets.only(bottom: 50),
          child: Container(
            decoration: BoxDecoration(
              // Show grey background if no cover image is provided.
              color: profileCover != null ? null : Colors.grey,
              // Add shadow for visual depth.
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: 0.5), // Use withOpacity for clarity.
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            // Cover image takes up 30% of screen height.
            height: height * 0.3,
            width: double.infinity,
            child: GestureDetector(
              // Handle tap on cover image to show edit menu.
              onTap: () {
                // Show a popover menu for editing the cover image.
                showPopover(
                  backgroundColor: const Color(0xff8862D9),
                  height: 100,
                  width: 250,
                  context: context,
                  bodyBuilder: (context) => CoverImageMenuItem(
                    isUsedInMyAccount: isUsedInMyAccount,
                  ),
                );
              },
              child: profileCover != null
                  // Display cover image with loading and error states.
                  ? CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: double.infinity,
                      imageUrl: profileCover!,
                      // Show loading indicator while image loads.
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      // Show error icon if image fails to load.
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.error_outline,
                          size: 30,
                          color: Colors.red,
                        ),
                      ),
                    )
                  // Show camera icon as placeholder when no cover image.
                  : const Icon(
                      Icons.camera_alt,
                      size: 80,
                    ),
            ),
          ),
        ),
        // Profile picture positioned at bottom center, overlapping the cover.
        Positioned(
          // Position the profile picture so it overlaps the bottom
          // of the cover image by 50 pixels.
          top: height * 0.3 - 50,
          // Center horizontally by offsetting by half the image width.
          right: width / 2 - 50,
          child: GestureDetector(
            // Handle tap on profile picture to show edit menu.
            onTap: () {
              // Show a popover menu for editing the profile picture.
              showPopover(
                backgroundColor: const Color(0xff8862D9),
                height: 150,
                width: 250,
                context: context,
                bodyBuilder: (context) => ProfileImageMenuItem(
                  isUsedInMyAccount: isUsedInMyAccount,
                ),
              );
            },
            child: ProfilePictureWithStory(
              size: 100,
              image: profileImage,
            ),
          ),
        ),
        if (isUsedInMyAccount)
          Positioned(
            left: 10,
            bottom: 0,
            child: BlocConsumer<SocialCubit, SocialState>(
              listener: (context, state) {
                if (state is LogOutSuccessState) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginView.routeViewName, (route) => false);
                }
              },
              builder: (context, state) {
                return AbsorbPointer(
                  absorbing: state is LogOutLoadingState,
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<SocialCubit>().logOut();
                    },
                    child: const Icon(
                      HugeIcons.strokeRoundedLogout02,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
