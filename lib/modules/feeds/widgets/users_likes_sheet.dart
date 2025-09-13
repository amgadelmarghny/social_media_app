import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/feeds/widgets/user_like_items_list_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class UsersLikesSheet extends StatelessWidget {
  const UsersLikesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      padding: const EdgeInsets.only(top: 40),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocListener<SocialCubit, SocialState>(
          listener: (BuildContext context, SocialState state) {
            if (state is GetPostLikesFailureState) {
              showToast(msg: state.errMessage, toastState: ToastState.error);
            }
          },
          child: const UserLikeItemsListView(),
        ),
      ),
    );
  }
}
