import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/chat/widgets/chat_view_body.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

import 'package:social_media_app/shared/services/notification_service.dart';
import '../user/user_view.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});
  static const routeName = "./chat_view";

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late UserModel userModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userModel = ModalRoute.settingsOf(context)!.arguments as UserModel;
    // Set the opened chat ID to prevent notifications for this user
    NotificationService.openedChatId = userModel.uid;
  }

  @override
  void dispose() {
    // Clear the opened chat ID when leaving the screen
    NotificationService.openedChatId = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: defaultColor,
            systemStatusBarContrastEnforced: true,
          ),
          backgroundColor: defaultColor,
          toolbarHeight: 80,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0XFFB1ACC7),
            ),
          ),
          title: InkWell(
            onTap: () => Navigator.pushNamed(context, UserView.routName,
                arguments: userModel),
            child: Row(
              children: [
                ProfilePictureWithStory(
                  size: 60,
                  image: userModel.photo,
                  isWithoutStory: true,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text("${userModel.firstName} ${userModel.lastName}"),
              ],
            ),
          ),
        ),
        body: ChatViewBody(
          friendUid: userModel.uid,
          friendToken: userModel.fcmToken,
        ),
      ),
    );
  }
}
