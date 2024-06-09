import 'package:flutter/material.dart';

import '../../../shared/components/story_item.dart';

class StoryListView extends StatelessWidget {
  const StoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 111,
      child: ListView.separated(
        itemBuilder: (context, index) => const StoryItem(
          image:
              'https://avatars.githubusercontent.com/u/126693786?s=400&u=b1aebebdd8c0990c5bdb1c6b62cca90aebf2e247&v=4',
          firstName: 'Amgad',
        ),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(
            width: 15,
          );
        },
        itemCount: 11,
      ),
    );
  }
}
