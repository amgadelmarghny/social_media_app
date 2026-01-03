import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class NotificationsBody extends StatefulWidget {
  const NotificationsBody({super.key});

  @override
  State<NotificationsBody> createState() => _NotificationsBodyState();
}

class _NotificationsBodyState extends State<NotificationsBody> {
  // Controller for handling scroll events in the notifications body.
  final ScrollController _scrollController = ScrollController();

  // Padding at the bottom of the notifications body, adjusted based on scroll.
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
        child: Center(
          child: Text(
            'This feature will be available soon',
            style: FontsStyle.font22Bold(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
