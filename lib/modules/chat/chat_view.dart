import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/chat/widgets/chat_view_body.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});
  static const routeName = "./chat_view";

  @override
  Widget build(BuildContext context) {
    UserModel userModel =
        ModalRoute.settingsOf(context)!.arguments as UserModel;
    return BlocProvider(
      create: (context) => ChatCubit(),
      child: Container(
        decoration: themeColor(),
        child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
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
            title: Row(
              children: [
                ProfilePictureWithStory(
                  size: 60,
                  image: userModel.photo,
                  isWithoutStory: true,
                ),
                SizedBox(
                  width: 10,
                ),
                Text("${userModel.firstName} ${userModel.lastName}"),
              ],
            ),
          ),
          body: ChatViewBody(
            friendUid: userModel.uid,
          ),
        ),
      ),
    );
  }
}
