import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/modules/post/post_view.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/custom_read_more_text.dart';
import 'package:social_media_app/shared/components/image_viewer_screen.dart';
import 'package:social_media_app/shared/components/post_item_image.dart';
import '../../modules/feeds/widgets/interactive_row.dart';
import '../../modules/feeds/widgets/profile_post_row.dart';
import 'constants.dart';

class PostItem extends StatefulWidget {
  const PostItem({
    super.key,
    required this.postModel,
    required this.postId,
  });
  final PostModel postModel;
  final String postId;
  // final UserModel userModel;

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool isLike = false;
  final currentUser = FirebaseAuth.instance.currentUser!;
  QuerySnapshot<Map<String, dynamic>>? likesCollection;

  @override
  void initState() {
    fetchLikes();
    super.initState();
  }

  Future<void> fetchLikes() async {
    likesCollection = await FirebaseFirestore.instance
        .collection(kPostsCollection)
        .doc(widget.postId)
        .collection(kLikesCollection)
        .get();
    final likesDocs = likesCollection!.docs;
    if (mounted) {
      setState(() {
        isLike = likesDocs.any((doc) => doc.id == currentUser.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void toggleLike() async {
      setState(() {
        isLike = !isLike;
      });
      // get likesCollection to access docs length for number of likes
      likesCollection = await BlocProvider.of<SocialCubit>(context)
          .toggleLike(postId: widget.postId, isLike: isLike);
    }

    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            // Navigate to PostView and refresh likes and comments when returning
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostView(
                  postModel: widget.postModel,
                  postId: widget.postId,
                ),
              ),
            );
            // Refresh likes and comments when returning from PostView
            fetchLikes();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff6D4ACD).withValues(alpha: 0.40),
              borderRadius: const BorderRadius.all(Radius.circular(25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfilePostRow(
                  image: widget.postModel.profilePhoto,
                  userName: widget.postModel.userName,
                  timePosted: DateFormat.yMMMd()
                      .add_jm()
                      .format(widget.postModel.dateTime),
                  userUid: widget.postModel.creatorUid,
                  postId: widget.postId,
                ),
                if (widget.postModel.content != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: CustomReadMoreText(text: widget.postModel.content!),
                  ),
                // hashtags
                // TODO: Add hashtags when it be available
                // const Wrap(
                //   children: [
                //     Hashtag(
                //       title: '#Profile',
                //     ),
                //   ],
                // ),
                if (widget.postModel.postImage != null)
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageViewerScreen(
                                imageUrl: widget.postModel.postImage!),
                          ),
                        );
                      },
                      child: PostItemImage(
                          postImage: widget.postModel.postImage!)),
                InteractiveRow(
                  numOfLikes: likesCollection?.docs.length ?? 0,
                  isLike: isLike,
                  onLikeButtonTap: toggleLike,
                  postId: widget.postId,
                  creatorUid: widget.postModel.creatorUid,
                  commentsNum: widget.postModel.commentsNum,
                  authorName: widget.postModel.userName,
                  postText: widget.postModel.content,
                  postImage: widget.postModel.postImage,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
