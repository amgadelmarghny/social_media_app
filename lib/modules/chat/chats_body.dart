import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/modules/chat/widgets/chat_item.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';

/// Main chats body widget for viewing the list of chat previews.
/// Stateful to manage dynamic padding and listen to scroll events.
class ChatsBody extends StatefulWidget {
  const ChatsBody({super.key});

  @override
  State<ChatsBody> createState() => _ChatsBodyState();
}

class _ChatsBodyState extends State<ChatsBody> {
  // Scroll controller to listen for edge scrolling,
  // used to adjust the body padding at the bottom
  final ScrollController _scrollController = ScrollController();

  // Dynamic bottom padding, updated when scrolling to bottom or up
  double _bodiesBottomPadding = 36;

  @override
  void initState() {
    super.initState();
    // Attach a listener to detect if the user scrolls to an edge (top or bottom)
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          // If we are at the bottom (not top), increase the bottom padding
          // to create space (e.g., for nav bar or FAB)
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
      // Listen for user scroll updates to reset bottom padding as the user scrolls up
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          // When the user scrolls up, i.e., reveals more earlier items,
          // restore the bottom padding to the default
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
        // Apply dynamic padding to create smooth UX when navigating list edge
        padding: EdgeInsets.only(
            top: 10, left: 20, right: 20, bottom: _bodiesBottomPadding),
        child: BlocBuilder<ChatCubit, ChatState>(
          // Only rebuild the list for chat-related loading/success/failure
          buildWhen: (previous, current) =>
              current is GetChatsSuccessState ||
              current is GetChatsLoadingState ||
              current is GetChatsFailureState,
          builder: (context, state) {
            // If chat item list is empty, show a placeholder image
            if (BlocProvider.of<ChatCubit>(context).chatItemsList.isEmpty) {
              return const Center(
                child: Image(
                  image: AssetImage('lib/assets/images/empty_box.png'),
                  height: 200,
                ),
              );
            }
            // Otherwise, display the list of chat previews,
            // optionally skeletonized if still loading (shimmer effect)
            return ListView.separated(
              controller: _scrollController,
              itemCount:
                  BlocProvider.of<ChatCubit>(context).chatItemsList.length,
              // Each row is wrapped in two Skeletonizer widgets to emulate loading states
              itemBuilder: (context, index) => Skeletonizer(
                enabled: state is GetChatsLoadingState,
                child: Skeletonizer(
                  enabled: state is GetChatsLoadingState,
                  child: ChatItem(
                    chatItemModel: BlocProvider.of<ChatCubit>(context)
                        .chatItemsList[index],
                  ),
                ),
              ),
              // Add a gap between chat preview items
              separatorBuilder: (context, index) => const SizedBox(
                height: 5,
              ),
            );
          },
        ),
      ),
    );
  }
}
