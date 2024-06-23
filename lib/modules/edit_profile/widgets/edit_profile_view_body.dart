import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class EditProfileViewBody extends StatelessWidget {
  const EditProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    UserModel userModel = BlocProvider.of<SocialCubit>(context).userModel!;
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              child: Column(
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
                          style: TextStyle(
                              fontSize: 20, color: Colors.blue.shade800),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(userModel.photo),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 0.9,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cover photo',
                        style: FontsStyle.font25Bold,
                      ),
                      TextButton(
                        onPressed: () {
                          BlocProvider.of<SocialCubit>(context)
                              .pickAndUploadCoverImage();
                        },
                        child: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Image.network(
                      height: height * 0.3,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      userModel.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 0.9,
                    color: Colors.white70,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profile',
                        style: FontsStyle.font25Bold,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Name'),
                          trailing: const Icon(IconBroken.Arrow___Right_2),
                          onTap: () {},
                        ),
                        ListTile(
                          title: const Text('Birthday'),
                          trailing: const Icon(IconBroken.Arrow___Right_2),
                          onTap: () {},
                        ),
                        ListTile(
                          title: const Text('Bio'),
                          trailing: const Icon(IconBroken.Arrow___Right_2),
                          onTap: () {},
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
