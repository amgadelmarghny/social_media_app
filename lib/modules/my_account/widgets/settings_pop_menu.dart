import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_media_app/modules/my_account/widgets/delete_account_dialog_widget.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class SettingPopMenuItems extends StatelessWidget {
  const SettingPopMenuItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            BlocProvider.of<SocialCubit>(context).logOut();
            Navigator.pop(context);
          },
          child: Container(
            height: 50,
            color: const Color(0xff8862D9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  radius: 15,
                  child: const HugeIcon(
                    icon: HugeIcons.strokeRoundedLogout02,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  'Logout',
                  style: FontsStyle.font18PopinWithShadowOption(),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (context) => DeleteAccountDialogWidget(),
            );
          if (context.mounted) Navigator.pop(context);
          },
          child: Container(
            height: 50,
            color: const Color(0xffA879E2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    radius: 15,
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedUserAccount,
                      size: 22.5,
                    )),
                const SizedBox(
                  width: 5,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'DELETE YOUR ACCOUNT',
                    style: FontsStyle.font18PopinWithShadowOption(),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
