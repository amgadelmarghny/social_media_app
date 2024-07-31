import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/shared/bloc/comments_cubit/comments_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../../modules/feeds/widgets/hashtag.dart';
import '../../modules/feeds/widgets/interactive_row.dart';
import '../../modules/feeds/widgets/profile_post_row.dart';
import 'constants.dart';

class PostItem extends StatefulWidget {
  const PostItem({
    super.key,
    required this.postModel,
    required this.postId,
    required this.userModel,
  });
  final PostModel postModel;
  final String postId;
  final UserModel userModel;

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
    setState(() {
      isLike = likesDocs.any((doc) => doc.id == currentUser.uid);
    });
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

    return BlocProvider(
      create: (context) => CommentsCubit()..getComments(postId: widget.postId),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xff6D4ACD).withOpacity(0.40),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfilePostRow(
              image: widget.postModel.profilePhoto,
              userName: widget.postModel.userName,
              timePosted:
                  DateFormat.yMMMd().add_jm().format(widget.postModel.dateTime),
            ),
            if (widget.postModel.content != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ReadMoreText(
                  widget.postModel.content!,
                  trimMode: TrimMode.Line,
                  trimLines: 4,
                  colorClickableText: Colors.pink,
                  trimCollapsedText: 'more',
                  trimExpandedText: ' less',
                  style: FontsStyle.font15Popin(),
                  lessStyle: FontsStyle.font15Popin(
                    color: Colors.white60,
                  ),
                  moreStyle: FontsStyle.font15Popin(
                    color: Colors.white60,
                  ),
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
            if (widget.postModel.postImage != null)
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
                      imageUrl: widget.postModel.postImage!,
                      placeholder: (context, url) => const Center(
                          child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      )),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.error_outline,
                          size: 30,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            BlocBuilder<CommentsCubit, CommentsState>(
              builder: (BuildContext context, state) {
                return InteractiveRow(
                  numOfLikes: likesCollection?.docs.length ?? 0,
                  isLike: isLike,
                  onLikeButtonTap: toggleLike,
                  postId: widget.postId,
                  userModel: widget.userModel,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
