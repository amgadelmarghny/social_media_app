import 'package:flutter/material.dart';
import 'package:social_media_app/modules/feeds/widgets/story_list_view.dart';

class FeedsBody extends StatelessWidget {
  const FeedsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
             StoryListView()
            ],
          ),
        ),
      ),
    );
  }
}
