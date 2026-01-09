import 'package:flutter/material.dart';
import 'package:social_media_app/modules/edit_profile/widgets/edit_cover_photo_section.dart';
import 'package:social_media_app/modules/edit_profile/widgets/edit_profile_picture_section.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'edit_user_bio_section.dart';
import 'edit_user_birthday_section.dart';
import 'edit_user_name_section.dart';

class EditProfileViewBody extends StatefulWidget {
  const EditProfileViewBody({super.key});

  @override
  State<EditProfileViewBody> createState() => _EditProfileViewBodyState();
}

class _EditProfileViewBodyState extends State<EditProfileViewBody> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
      child: SingleChildScrollView(
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
            Text(
              'Profile',
              style: FontsStyle.font25Bold,
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, right: 10, left: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff6D4ACD).withValues(alpha: 0.40),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              child: const Column(
                children: [
                  EditUserNameSection(),
                  EditUserBirthdaySection(),
                  EditUseBioSection(),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.paddingOf(context).bottom,
            ),
          ],
        ),
      ),
    );
  }
}
