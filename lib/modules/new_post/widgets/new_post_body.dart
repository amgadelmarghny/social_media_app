import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import '../../../shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/style/fonts/font_style.dart';
import '../../feeds/widgets/profile_post_row.dart';

class CreatePostSheetBody extends StatelessWidget {
  const CreatePostSheetBody({
    super.key,
    required this.postContentController,
  });
  final TextEditingController postContentController;

  @override
  Widget build(BuildContext context) {
    SocialCubit socialCubit = BlocProvider.of<SocialCubit>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
      child: BlocBuilder<SocialCubit, SocialState>(
        builder: (BuildContext context, SocialState state) {
          return SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height - 105,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ProfilePostRow(
                    image: socialCubit.userModel!.photo!,
                    userName:
                        '${socialCubit.userModel!.firstName} ${socialCubit.userModel!.lastName}',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Flexible(
                    child: TextField(
                      controller: postContentController,
                      maxLines:
                          null, // Allows the TextField to expand vertically
                      expands:
                          true, // Allows the TextField to expand to fill available space
                      style: FontsStyle.font18Popin(),
                      decoration: InputDecoration(
                        hintText: 'What is on your mind?',
                        hintStyle: FontsStyle.font18Popin(),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (socialCubit.postImagePicked != null)
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(
                          socialCubit.postImagePicked!,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: CircleAvatar(
                            backgroundColor: Colors.redAccent.shade100,
                            child: IconButton(
                              onPressed: () {
                                socialCubit.removePickedFile();
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.red[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            socialCubit.postImagePicked =
                                await socialCubit.pickImage();
                          },
                          child: SizedBox(
                            height: 50,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.insert_photo_outlined,
                                    color: defaultColorButton,
                                    size: 30,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Add photo',
                                    style: FontsStyle.font18Popin(
                                        color: defaultColorButton),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                '#tags',
                                style:
                                    FontsStyle.font18Popin(color: defaultColorButton),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
