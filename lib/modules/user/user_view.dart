import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/user/widgets/user_view_body.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class UserView extends StatelessWidget {
  const UserView({super.key});
  static const routName = "./User_View";
  @override
  Widget build(BuildContext context) {
    UserModel userModel =
        ModalRoute.settingsOf(context)!.arguments as UserModel;
    return BlocProvider(
      create: (context) => UserCubit()..getUserPosts(userModel.uid)
        ..checkFollowStatus(
            context.read<SocialCubit>().userModel!.uid, userModel.uid)
        ..getFollowers(userModel.uid)
        ..getFollowing(userModel.uid),
      child: Container(
        decoration: themeColor(),
        child: Scaffold(
          body: UserViewBody(userModel: userModel),
        ),
      ),
    );
  }
}
