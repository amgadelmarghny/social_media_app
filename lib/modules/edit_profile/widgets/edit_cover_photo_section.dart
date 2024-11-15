import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/style/fonts/font_style.dart';

class CoverPhotoSection extends StatelessWidget {
  const CoverPhotoSection({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cover photo',
              style: FontsStyle.font25Bold,
            ),
            TextButton(
              onPressed: () {
                BlocProvider.of<SocialCubit>(context).pickAndUploadCoverImage();
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
          child: BlocProvider.of<SocialCubit>(context).userModel!.cover != null
              ? CachedNetworkImage(
                  height: height * 0.3,
                  fit: BoxFit.cover,
                  imageUrl:
                      BlocProvider.of<SocialCubit>(context).userModel!.cover!,
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
                )
              : SizedBox(
                  height: height * 0.3,
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
