import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import '../../models/user_model.dart';
import '../../shared/bloc/comments_cubit/comments_cubit.dart';
import '../../shared/bloc/social_cubit/social_cubit.dart';
import '../../shared/components/constants.dart';
import '../../shared/style/fonts/font_style.dart';
import '../feeds/widgets/hashtag.dart';
import '../feeds/widgets/interactive_row.dart';
import '../feeds/widgets/profile_post_row.dart';

class PostView extends StatefulWidget {
  const PostView({
    super.key,
    required this.postModel,
    required this.postId,
    required this.userModel,
  });
  final PostModel postModel;
  final String postId;
  final UserModel userModel;

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
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
      BlocProvider.of<SocialCubit>(context).getLikes(widget.postId);
    }

    return Container(
      decoration: themeColor(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.postModel.userName),
        ),
        body: Padding(
          padding:  EdgeInsets.only(left: 20,right: 20,bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  child: Text(
                    widget.postModel.content!,
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
      ),
    );
  }
}
