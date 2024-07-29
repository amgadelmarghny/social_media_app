import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
import 'package:social_media_app/shared/style/theme/theme.dart';
import '../../../shared/components/comment_item.dart';
import '../../../shared/style/fonts/font_style.dart';

class CommentsSheet extends StatelessWidget {
  const CommentsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController commentController = TextEditingController();
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
              ),
              TextField(
                style: FontsStyle.font18Popin(isShadow: true),
                controller: commentController,
                decoration: InputDecoration(
                  hintStyle: FontsStyle.font18Popin(isShadow: true),
                  suffixIconColor: defaultColor,
                  suffixIcon: IconButton(
                    onPressed: () {
                      commentController.clear();
                    },
                    icon: const Icon(Icons.send_outlined),
                  ),
                  hintText: 'Write comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
