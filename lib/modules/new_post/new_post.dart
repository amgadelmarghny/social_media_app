import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import '../../shared/style/fonts/font_style.dart';
import '../feeds/widgets/profile_post_row.dart';

class CreatePostSheet extends StatelessWidget {
  const CreatePostSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController postContentController = TextEditingController();
    return Container(
      decoration: themeColor(),
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Scaffold(
          appBar: AppBar(
            actions: [
              MaterialButton(
                color: Colors.grey.shade400,
                onPressed: () {},
                child: Text(
                  'Post',
                  style:
                      FontsStyle.font18PopinBold().copyWith(color: Colors.grey),
                ),
              ),
              const SizedBox(
                width: 20,
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ProfilePostRow(
                  isAddPost: true,
                  image:
                      BlocProvider.of<SocialCubit>(context).userModel!.photo!,
                  userName:
                      '${BlocProvider.of<SocialCubit>(context).userModel!.firstName} ${BlocProvider.of<SocialCubit>(context).userModel!.lastName}',
                ),
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: TextField(
                    controller: postContentController,
                    maxLines: null, // Allows the TextField to expand vertically
                    expands:
                        true, // Allows the TextField to expand to fill available space
                    style: FontsStyle.font18Popin(),
                    decoration: InputDecoration(
                        hintText: 'What is on your mind?',
                        hintStyle: FontsStyle.font18Popin(),
                        border: InputBorder.none),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: SizedBox(
                          height: 50,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.insert_photo,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Add photo',
                                  style: FontsStyle.font18Popin(
                                      color: Colors.blue),
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
                              style: FontsStyle.font18Popin(
                                  color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
