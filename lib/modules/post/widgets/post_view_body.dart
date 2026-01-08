import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/modules/feeds/widgets/hashtag.dart';
import 'package:social_media_app/modules/feeds/widgets/interactive_row.dart';
import 'package:social_media_app/modules/feeds/widgets/profile_post_row.dart';
import 'package:social_media_app/modules/post/widgets/display_post_image.dart';
import 'package:social_media_app/shared/bloc/comments_cubit/comments_cubit.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/comment_item.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/components/add_comment_button.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PostViewBody extends StatefulWidget {
  const PostViewBody({
    super.key,
    required this.postModel,
    required this.postId,
  });

  // final PostView widget;
  final PostModel postModel;
  final String postId;

  @override
  State<PostViewBody> createState() => _PostViewBodyState();
}

class _PostViewBodyState extends State<PostViewBody> {
  /// Whether the current user has liked this post.
  bool isLike = false;

  /// The currently authenticated Firebase user.
  final currentUser = FirebaseAuth.instance.currentUser!;

  /// The collection of likes for this post.
  QuerySnapshot<Map<String, dynamic>>? likesCollection;
  List<QueryDocumentSnapshot>? commentsDocs;
  late CommentsCubit commentsCubit;

  @override
  void initState() {
    commentsCubit = context.read<CommentsCubit>();
    // Fetch the initial like state for this post.
    fetchLikes();
    super.initState();
  }

  /// Toggles the like state for this post and updates Firestore.
  void toggleLike() async {
    isLike = !isLike;

    // Update the like in Firestore and refresh the likes collection.
    likesCollection = await BlocProvider.of<SocialCubit>(context)
        .toggleLike(postId: widget.postId, isLike: isLike);

    // Don't call getPosts() here as it's expensive and not needed
    // The BlocListener in PostItem will handle the state update
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with CustomScrollView
        Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                80, // Add space for the fixed button
          ),
          child: CustomScrollView(
            slivers: [
              // Display the user's profile photo, name, and post time.
              SliverToBoxAdapter(
                child: ProfilePostRow(
                  image: widget.postModel.profilePhoto,
                  userName: widget.postModel.userName,
                  timePosted: DateFormat.yMMMd()
                      .add_jm()
                      .format(widget.postModel.dateTime),
                  userUid: widget.postModel.creatorUid,
                  postId: widget.postId,
                ),
              ),
              // If the post has text content, display it.
              if (widget.postModel.content != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      widget.postModel.content!,
                      style: FontsStyle.font15Popin(),
                    ),
                  ),
                ),
              // Display hashtags (currently hardcoded as #Profile).
              // TODO: Add hashtags when it be available
              // const SliverToBoxAdapter(
              //   child: Wrap(
              //     children: [
              //       Hashtag(
              //         title: '#Profile',
              //       ),
              //     ],
              //   ),
              // ),
              // If the post has an image, display it with a border and rounded corners.
              if (widget.postModel.postImage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: DisplayPostImage(
                        postImage: widget.postModel.postImage!),
                  ),
                ),
              // Display the interactive row (likes, comments, etc.).
              SliverToBoxAdapter(
                child: InteractiveRow(
                  numOfLikes: likesCollection?.docs.length ?? 0,
                  showCommentSheet: false,
                  isLike: isLike,
                  onLikeButtonTap: toggleLike,
                  postId: widget.postId,
                  commentsNum: widget.postModel.commentsNum,
                  creatorUid: widget.postModel.userName,
                ),
              ),
              BlocBuilder<CommentsCubit, CommentsState>(
                builder: (context, state) {
                  return SliverToBoxAdapter(
                    child: Skeletonizer(
                      enabled: commentsCubit.commentsModelList.isEmpty,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: commentsCubit.commentsModelList.length,
                        itemBuilder: (context, index) => CommentItem(
                            commentModel:
                                commentsCubit.commentsModelList[index]),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Fixed SendCommentButton at the bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.only(
              right: 15,
              left: 15,
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: AddCommentButton(
              postId: widget.postId,
              commentsNum: widget.postModel.commentsNum,
              creatorUid: widget.postModel.creatorUid,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> fetchLikes() async {
    likesCollection = await FirebaseFirestore.instance
        .collection(kPostsCollection)
        .doc(widget.postId)
        .collection(kLikesCollection)
        .get();

    final likeDocs = likesCollection!.docs;
    setState(() {
      isLike = likeDocs.any((doc) {
        return doc.id == currentUser.uid;
      });
    });
  }
}
