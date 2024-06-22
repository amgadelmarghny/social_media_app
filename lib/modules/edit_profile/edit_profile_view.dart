import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import 'widgets/edit_profile_view_body.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});
  static const routeViewName = 'EditProfileView';
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body:const EditProfileViewBody(),
      ),
    );
  }
}
