import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/update_user_impl_model.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/show_toast.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import 'widgets/edit_profile_view_body.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});
  static const routeViewName = 'EditProfileView';
  @override
  Widget build(BuildContext context) {
    SocialCubit socialCubit = BlocProvider.of<SocialCubit>(context);
    return Container(
      decoration: themeColor(),
      child: BlocConsumer<SocialCubit, SocialState>(
        listener: (BuildContext context, SocialState state) {
          if (state is GetMyDataSuccessState) {
            showToast(
              msg: 'Update Successfully',
              toastState: ToastState.success,
            );
          }
          if (state is UpdateUserInfoFailureState) {
            showToast(
              msg: state.errMessage,
              toastState: ToastState.worrning,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    if (socialCubit.firstNameController.text.isNotEmpty ||
                        socialCubit.lastNameController.text.isNotEmpty ||
                        socialCubit.bioController.text.isNotEmpty ||
                        socialCubit.updatedYear != null ||
                        socialCubit.updatedDayAndMonth != null) {
                      UpdateUserImplModel updateUserImplModel =
                          UpdateUserImplModel(
                        firstName:
                            socialCubit.firstNameController.text.isNotEmpty
                                ? socialCubit.firstNameController.text
                                : null,
                        lastName: socialCubit.lastNameController.text.isNotEmpty
                            ? socialCubit.lastNameController.text
                            : null,
                        bio: socialCubit.bioController.text.isNotEmpty
                            ? socialCubit.bioController.text
                            : null,
                        year: socialCubit.updatedYear,
                        dateAndMonth: socialCubit.updatedDayAndMonth,
                      );
                      await socialCubit.updateUserInfo(
                          updateUserImplModel: updateUserImplModel);
                    }
                  },
                  icon: state is UpdateUserInfoLoadingState
                      ? const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.check,
                        ),
                ),
              ],
            ),
            body: const EditProfileViewBody(),
          );
        },
      ),
    );
  }
}
