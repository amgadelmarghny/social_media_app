import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/chat/chat_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/profile_picture_with_story.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({super.key, required this.dateTime});
  final String dateTime;

  @override
  Widget build(BuildContext context) {
    UserModel? userModel = BlocProvider.of<SocialCubit>(context).userModel;

    return InkWell(
        onTap: () => Navigator.pushNamed(
              context,
              ChatView.routeName,
              arguments: userModel,
            ),
        child: Row(
          children: [
            ProfilePictureWithStory(
              size: 70,
              image: userModel!.photo,
              isWithoutStory: true,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${userModel.firstName} ${userModel.lastName}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style:
                        FontsStyle.font20Poppins.copyWith(color: Colors.white),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${userModel.firstName} ${userModel.lastName}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: FontsStyle.font18Popin(color: Colors.white60),
                        ),
                      ),
                      Text(
                        dateTime,
                        style: FontsStyle.font18Popin(color: Colors.white60),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ));
  }
}
