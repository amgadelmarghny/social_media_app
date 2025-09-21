import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:social_media_app/modules/chat/widgets/chat_item.dart';
import 'package:social_media_app/shared/bloc/chat_cubit/chat_cubit.dart';

class ChatsBody extends StatefulWidget {
  const ChatsBody({super.key});

  @override
  State<ChatsBody> createState() => _ChatsBodyState();
}

class _ChatsBodyState extends State<ChatsBody> {
  // Controller for handling scroll events in the chat body.
  final ScrollController _scrollController = ScrollController();
  late ChatCubit chatCubit;
  // Padding at the bottom of the chat body, adjusted based on scroll.
  double _bodiesBottomPadding = 36;

  @override
  void initState() {
    super.initState();
    chatCubit = BlocProvider.of<ChatCubit>(context);
    getChats();
    // Add a listener to the scroll controller to detect when the user
    // has scrolled to the edge (top or bottom) of the scroll view.
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (!isTop) {
          // Reached the bottom of the scroll view.
          // Increase the bottom padding to make space for the bottom nav bar.
          setState(() {
            _bodiesBottomPadding = 82;
          });
        }
      }
    });
  }

  Future<void> getChats() async => await chatCubit.getChats();

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
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (BlocProvider.of<ChatCubit>(context).chatItemsList.isEmpty) {
              return Center(
                child: Image.asset(
                  'lib/assets/images/empty_box.png',
                  height: 200,
                ),
              );
            }
            return ListView.separated(
              controller: _scrollController,
              itemCount:
                  BlocProvider.of<ChatCubit>(context).chatItemsList.length,
              itemBuilder: (context, index) => Skeletonizer(
                enabled: state is GetChatsLoadingState,
                child: ChatItem(
                  chatItemModel:
                      BlocProvider.of<ChatCubit>(context).chatItemsList[index],
                ),
              ),
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
