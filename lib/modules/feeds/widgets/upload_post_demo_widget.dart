import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/feeds/widgets/profile_post_row.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import '../../../shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/components/error_widget.dart';
import '../../../shared/style/fonts/font_style.dart';
import 'hashtag.dart';

class UploadPostDemo extends StatelessWidget {
  const UploadPostDemo({super.key});

  @override
  Widget build(BuildContext context) {
    SocialCubit socialCubit = BlocProvider.of<SocialCubit>(context);
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.only(
                  top: 10,
                  bottom: socialCubit.postImagePicked != null ? 10 : 20,
                  right: 10,
                  left: 10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Opacity(
                opacity: 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProfilePostRow(
                      image: socialCubit.userModel!.photo,
                      userName:
                          '${socialCubit.userModel!.firstName} ${socialCubit.userModel!.lastName}',
                    ),

                    if (state is CreatePostLoadingState)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: LinearProgressIndicator(
                          color: defaultTextColor,
                          borderRadius: BorderRadius.all(Radius.circular(200)),
                          backgroundColor: Color(0xffA878E2),
                        ),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (socialCubit.postContentController.text.isNotEmpty)
                      Text(
                        socialCubit.postContentController.text,
                        style: FontsStyle.font15Popin(),
                      ),

                    // hashtags
                    const Wrap(
                      children: [
                        Hashtag(
                          title: '#Profile',
                        ),
                      ],
                    ),
                    if (socialCubit.postImagePicked != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Container(
                          padding: const EdgeInsets.all(1.3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Container(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Image(
                              fit: BoxFit.fitWidth,
                              image: FileImage(socialCubit.postImagePicked!),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (state is UploadPostImageFailureState ||
                state is CreatePostFailureState)
              const FloatingErrorWidget()
          ],
        );
      },
    );
  }
}
