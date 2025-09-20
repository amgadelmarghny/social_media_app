import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/feeds/widgets/user_suggestion_item.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';

class UserLikeItemsListView extends StatelessWidget {
  const UserLikeItemsListView({super.key, required this.userModelList});
  final List<UserModel> userModelList;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Skeletonizer(
            enabled: userModelList.isEmpty,
            child: ListView.separated(
              itemCount: userModelList.length,
              itemBuilder: (context, index) {
                BlocProvider.of<UserCubit>(context).checkFollowStatus(
                    BlocProvider.of<SocialCubit>(context).userModel!.uid,
                    userModelList[index].uid);
                return UserSuggestionItem(
                  userModel: userModelList[index],
                );
              },
              separatorBuilder: (context, index) => SizedBox(
                height: 10,
              ),
            ),
          ),
        );
      },
    );
  }
}
