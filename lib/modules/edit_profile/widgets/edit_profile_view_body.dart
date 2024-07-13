import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:social_media_app/modules/edit_profile/widgets/edit_cover_photo_section.dart';
import 'package:social_media_app/modules/edit_profile/widgets/edit_profile_picture_section.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class EditProfileViewBody extends StatelessWidget {
  const EditProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 const ProfilePictureSection(),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 0.9,
                  ),
                 const CoverPhotoSection(),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 0.9,
                    color: Colors.white70,
                  ),
                  const Text(
                    'Profile',
                    style: FontsStyle.font25Bold,
                  ),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Name'),
                          trailing: const Icon(IconBroken.Arrow___Down_2),
                          onTap: () {},
                        ),
                        ListTile(
                          title: const Text('Birthday'),
                          trailing: const Icon(IconBroken.Arrow___Down_2),
                          onTap: () {},
                        ),
                        ListTile(
                          title: const Text('Bio'),
                          trailing: const Icon(IconBroken.Arrow___Down_2),
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
