import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/style/fonts/font_style.dart';

class ProfilePictureSection extends StatelessWidget {
  const ProfilePictureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Profile Picture',
              style: FontsStyle.font25Bold,
            ),
            TextButton(
              onPressed: () {
                BlocProvider.of<SocialCubit>(context)
                    .pickAndUploadProfileImage();
              },
              child: Text(
                'Edit',
                style: TextStyle(fontSize: 20, color: Colors.blue.shade800),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(
                BlocProvider.of<SocialCubit>(context).userModel!.photo,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
