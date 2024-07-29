import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import '../../../shared/components/comment_item.dart';

class CommentsSheet extends StatelessWidget {
  const CommentsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: themeColor(),
      padding: const EdgeInsets.only(top: 40),
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) => const CommentItem(),
                  itemCount: 20,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
