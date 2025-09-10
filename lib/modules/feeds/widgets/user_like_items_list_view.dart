import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/modules/feeds/widgets/user_like_item.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';

class UserLikeItemsListView extends StatelessWidget {
  const UserLikeItemsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        List userModels = context.read<SocialCubit>().userModelList;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Skeletonizer(
            enabled: userModels.isEmpty,
            child: ListView.separated(
              itemCount: userModels.length,
              itemBuilder: (context, index) => UserLikeItem(
                userModel: userModels[index],
              ),
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