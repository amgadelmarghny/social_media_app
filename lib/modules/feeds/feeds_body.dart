import 'package:flutter/material.dart';
import 'package:social_media_app/modules/feeds/widgets/post_item.dart';
import 'package:social_media_app/modules/feeds/widgets/story_list_view.dart';

class FeedsBody extends StatelessWidget {
  const FeedsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 20,left: 20,right: 20,),
        child: Column(
          children: [
            SearchBar(
              hintText: 'Explore',
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const StoryListView(),
            const SizedBox(
              height: 20,
            ),
            // post
            const PostItem()
          ],
        ),
      ),
    );
  }
}
