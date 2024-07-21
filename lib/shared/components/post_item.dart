import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../modules/feeds/widgets/hashtag.dart';
import '../../modules/feeds/widgets/interactive_row.dart';
import '../../modules/feeds/widgets/profile_post_row.dart';

class PostItem extends StatelessWidget {
  const PostItem({
    super.key,
    required this.postModel,
  });
  final PostModel postModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff6D4ACD).withOpacity(0.40),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfilePostRow(
            image: postModel.profilePhoto,
            userName: postModel.userName,
            timePosted: DateFormat.yMMMd().add_jm().format(postModel.dateTime),
          ),
          if (postModel.content != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                postModel.content!,
                style: FontsStyle.font15Popin(),
              ),
            ),
          // hashtags
          const Wrap(
            children: [
              Hashtag(
                title: '#Profile',
              ),
            ],
          ),
          if (postModel.postImage != null)
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
                  child: CachedNetworkImage(
                    fit: BoxFit.fitHeight,
                    width: double.infinity,
                    imageUrl: postModel.postImage!,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // const SizedBox(
          //   height: 5,
          // ),
          const InteractiveRow(
            numOfLikes: '0',
            numOfComments: '0',
          ),
        ],
      ),
    );
  }
}
