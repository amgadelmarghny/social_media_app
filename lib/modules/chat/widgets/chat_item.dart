import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/models/chat_item_model.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/chat/chat_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/message_date_lable.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

// This widget represents an item in the chat list, displaying user info and last message.
class ChatItem extends StatefulWidget {
  const ChatItem({super.key, required this.chatItemModel});
  final ChatItemModel chatItemModel;

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  // Stores the user model associated with this chat item.
  UserModel? userModel;
  // Used for accessing social-related features (e.g., fetching user data).
  late SocialCubit socialCubit;

  @override
  void initState() {
    // Get the current instance of the SocialCubit.
    socialCubit = context.read<SocialCubit>();
    // Fetch the chat user's information when this widget is initialized.
    getChatUserModel();
    super.initState();
  }

  // Fetches the user data associated with the chat item's user UID.
  Future<void> getChatUserModel() async {
    userModel =
        await socialCubit.getUserData(userUid: widget.chatItemModel.uid);
    if (mounted) {
      setState(() {}); // Update the widget when user data is received.
    }
  }

  @override
  void didUpdateWidget(covariant ChatItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the UID has changed (due to list reordering and widget reuse),
    // refresh the user data.
    if (oldWidget.chatItemModel.uid != widget.chatItemModel.uid) {
      userModel = null;
      getChatUserModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      // Show skeleton loading while the user model has not been fetched.
      enabled: userModel?.firstName.isEmpty ?? true,
      child: InkWell(
          onTap: () => Navigator.pushNamed(
                context,
                ChatView.routeName, // Navigate to the chat view on tap.
                arguments: userModel,
              ),
          child: Row(
            children: [
              ProfilePictureWithStory(
                size: 70,
                image: userModel?.photo,
                isWithoutStory: true, // Always show as without story here.
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display user's full name.
                    Text(
                      "${userModel?.firstName} ${userModel?.lastName}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: FontsStyle.font20Poppins
                          .copyWith(color: Colors.white),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        // Show voice message indicator if there's a voice record.
                        if (widget.chatItemModel.voiceRecord != null) ...[
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedMic01,
                            color: Color(0XFFC4C2CB),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            'Voice message',
                            maxLines: 1,
                            style: FontsStyle.font18PopinWithShadowOption(
                                color: const Color(0XFFC4C2CB)),
                          ),
                          const Spacer(),
                        ],
                        // Show image indicator if there are images sent.
                        if (widget.chatItemModel.images != null)
                          if (widget.chatItemModel.images!.length > 1) ...[
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedAlbum02,
                              color: Color(0XFFC4C2CB),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: Text(
                                widget.chatItemModel.textMessage == null
                                    ? 'Photos'
                                    : widget.chatItemModel.textMessage!,
                                maxLines: 1,
                                style: FontsStyle.font18PopinWithShadowOption(
                                    color: const Color(0XFFC4C2CB)),
                              ),
                            ),
                          ] else ...[
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedImage02,
                              color: Color(0XFFC4C2CB),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: Text(
                                widget.chatItemModel.textMessage == null
                                    ? 'Photo'
                                    : widget.chatItemModel.textMessage!,
                                maxLines: 1,
                                style: FontsStyle.font18PopinWithShadowOption(
                                    color: const Color(0XFFC4C2CB)),
                              ),
                            ),
                          ],
                        // Show text message preview if present.
                        if (widget.chatItemModel.textMessage != null &&
                            widget.chatItemModel.images == null)
                          Expanded(
                            child: Text(
                              widget.chatItemModel.textMessage!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: FontsStyle.font18PopinWithShadowOption(
                                  color: Colors.white60),
                            ),
                          ),
                        // Display the label for date/time of the last message.
                        Text(
                          getMessageDateLabel(widget.chatItemModel.dateTime),
                          style: FontsStyle.font18PopinWithShadowOption(
                              color: Colors.white60),
                        ),
                        if (!widget.chatItemModel.isRead)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
