import 'package:cached_network_image/cached_network_image.dart';
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
            Container(
              width: 160,
              height: 160,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child:
                  BlocProvider.of<SocialCubit>(context).userModel!.photo == null
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.shade600,
                          size: 120,
                        )
                      : CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: BlocProvider.of<SocialCubit>(context)
                              .userModel!
                              .photo!,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 30,
                              color: Colors.red,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ],
    );
  }
}
