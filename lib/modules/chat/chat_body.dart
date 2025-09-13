import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:social_media_app/modules/chat/widgets/chat_item.dart';

class ChatBody extends StatefulWidget {
  const ChatBody({super.key});

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  // Controller for handling scroll events in the chat body.
  final ScrollController _scrollController = ScrollController();

  // Padding at the bottom of the chat body, adjusted based on scroll.
  double _bodiesBottomPadding = 36;

  @override
  void initState() {
    super.initState();
    // Add a listener to the scroll controller to detect when the user
    // has scrolled to the edge (top or bottom) of the scroll view.
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          // Reached the bottom of the scroll view.
          debugPrint(
              "^^^^^^^ Reached the end of the SingleChildScrollView ^^^");
          // Increase the bottom padding to make space for the bottom nav bar.
          setState(() {
            _bodiesBottomPadding = 82;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      // Listen for scroll updates to adjust bottom padding
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          // If the user scrolls up (forward), reset the bottom padding.
          if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            setState(() {
              _bodiesBottomPadding = 36;
            });
          }
        }
        return true;
      },
      child: Padding(
        padding: EdgeInsets.only(
            top: 10, left: 20, right: 20, bottom: _bodiesBottomPadding),
        child: ListView.separated(
          controller: _scrollController,
          itemCount: 20,
          itemBuilder: (context, index) => const ChatItem(),
          separatorBuilder: (context, index) => const SizedBox(
            height: 5,
          ),
        ),
      ),
    );
  }
}
