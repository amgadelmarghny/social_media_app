import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/new_post/widgets/new_post_bottom_action_buttons.dart';
import '../../../shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/style/fonts/font_style.dart';
import '../../feeds/widgets/profile_post_row.dart';

/// The main body widget for creating a new post.
/// Displays user info, a text field for post content, an optional image preview,
/// and buttons to add a photo or tags.
class CreatePostSheetBody extends StatelessWidget {
  const CreatePostSheetBody({
    super.key,
    required this.postContentController,
  });

  /// Controller for the post content text field.
  final TextEditingController postContentController;

  @override
  Widget build(BuildContext context) {
    // Get the SocialCubit instance from the context.
    SocialCubit socialCubit = context.read<SocialCubit>();

    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
      child: BlocBuilder<SocialCubit, SocialState>(
        builder: (BuildContext context, SocialState state) {
          return SingleChildScrollView(
            child: SizedBox(
              // Set the height to fit the available space minus some offset.
              height: MediaQuery.sizeOf(context).height - 105,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Display the user's profile photo and name at the top.
                  ProfilePostRow(
                    image: socialCubit.userModel!.photo,
                    userName:
                        '${socialCubit.userModel!.firstName} ${socialCubit.userModel!.lastName}',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // The main text field for entering post content.
                  Flexible(
                    child: TextField(
                      controller: postContentController,
                      maxLines:
                          null, // Allows the TextField to expand vertically
                      expands: true, // Expands to fill available space
                      style: FontsStyle.font18Popin(),
                      decoration: InputDecoration(
                        hintText: 'What is on your mind?',
                        hintStyle: FontsStyle.font18Popin(),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  // If an image is picked, show a preview with a remove button.
                  if (socialCubit.postImagePicked != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        // Display the picked image.
                        Image.file(
                          socialCubit.postImagePicked!,
                        ),
                        // Button to remove the picked image.
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: CircleAvatar(
                            backgroundColor: Colors.redAccent.shade100,
                            child: IconButton(
                              onPressed: () => socialCubit.removePickedFile(),
                              icon: Icon(
                                Icons.close,
                                color: Colors.red[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Row of action buttons: Add photo and Add tags.
                  const NewPostBottomActionButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
