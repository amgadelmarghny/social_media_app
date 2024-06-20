import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:social_media_app/modules/users/widgets/custom_cover_and_image_profile.dart';
import '../../shared/style/theme/constant.dart';

class UsersBody extends StatelessWidget {
  const UsersBody({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        const CustomCoverAndImageProfile(
          profileImage:
              'https://img.freepik.com/free-psd/travel-tourism-facebook-cover-template_106176-2350.jpg?t=st=1718837003~exp=1718840603~hmac=ee693122a4a6abe55342026a5443a20b35e53b8ec5c6c4a8cddcb53e87314dba&w=1380',
          profileCover:
              'https://avatars.githubusercontent.com/u/126693786?s=400&u=b1aebebdd8c0990c5bdb1c6b62cca90aebf2e247&v=4',
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Amgad Marghny',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: defaultColor,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                IconBroken.Edit_Square,
                size: 32,
                color: defaultColor,
              ),
              color: defaultColor,
            )
          ],
        ),
      ],
    );
  }
}
