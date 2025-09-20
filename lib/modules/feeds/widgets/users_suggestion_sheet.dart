import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/modules/feeds/widgets/user_suggestion_items_list_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/bloc/user_cubit/user_cubit.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';

class UsersSuggestionsSheet extends StatelessWidget {
  const UsersSuggestionsSheet({super.key, required this.userModelList});
  final List<UserModel> userModelList;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(),
      child: Container(
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
            child: UserLikeItemsListView(
              userModelList: userModelList,
            ),
          ),
        ),
      ),
    );
  }
}
