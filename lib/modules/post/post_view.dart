import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/post_model.dart';
import 'package:social_media_app/modules/post/widgets/post_view_body.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import '../../models/user_model.dart';
import '../../shared/bloc/comments_cubit/comments_cubit.dart';

/// A view that displays a single post, including user info, content, image, hashtags, and interactive actions.
class PostView extends StatelessWidget {
  const PostView({
    super.key,
    required this.postModel,
    required this.postId,
    required this.userModel,
  });

  /// The post data to display.
  final PostModel postModel;

  /// The Firestore document ID for the post.
  final String postId;

  /// The user who created the post.
  final UserModel userModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommentsCubit(),
      child: Container(
        decoration: themeColor(), // Set the background theme color.
        child: Scaffold(
          appBar: AppBar(),
          body: PostViewBody(
            postModel: postModel,
            postId: postId,
            userModel: userModel,
          ),
        ),
      ),
    );
  }
}
