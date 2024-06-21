import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class ProfileImageMenuItem extends StatelessWidget {
  const ProfileImageMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: (){
            BlocProvider.of<SocialCubit>(context).pickAndUploadProfileImage();
            Navigator.pop(context);
          },
          child: Container(
            height: 50,
            color: const Color(0xff8862D9),
            child: Center(
              child: Text(
                'Change picture',
                style: FontsStyle.font18Popin(),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: (){},
          child: Container(
            height: 50,
            color: const Color(0xffA879E2),
            child: Center(
              child: Text(
                'View picture',
                style: FontsStyle.font18Popin(),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: (){},
          child: Container(
            height: 50,
            color: const Color(0xffD197ED),
            child: Center(
              child: Text(
                'View story',
                style: FontsStyle.font18Popin(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
