import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/new_post/new_post.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/bottom_bar_cilper.dart';

/// Custom bottom navigation bar widget with a floating action button for creating posts.
/// Uses a custom clipper for a unique shape and integrates with SocialCubit for navigation state.
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // BlocBuilder listens to SocialCubit state changes to update the navigation bar.
    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        return SizedBox(
          width: screenWidth, // Ensure full width
          child: Stack(
            clipBehavior: Clip.none, // Allows the FAB to overflow the stack.
            children: [
              // The custom-shaped bottom navigation bar using a ClipPath and BottomBarClipper.
              ClipPath(
                clipper: BottomBarClipper(context, height: 73),
                child: Container(
                  width: screenWidth, // Ensure full width
                  height: 80,
                  padding: const EdgeInsets.all(1.5),
                  color: const Color(0xffBA85E8), // Outer border color.
                  child: ClipPath(
                    clipper: BottomBarClipper(context, height: 73),
                    child: BottomNavigationBar(
                      // The current selected index from the SocialCubit.
                      currentIndex: BlocProvider.of<SocialCubit>(context)
                          .currentBottomNavBarIndex,
                      // When a navigation item is tapped, update the index in the cubit.
                      onTap: (value) {
                        BlocProvider.of<SocialCubit>(context)
                            .changeBottomNavBar(value);
                      },
                      iconSize: 28,
                      // The navigation items provided by the SocialCubit.
                      items: BlocProvider.of<SocialCubit>(context)
                          .bottomNavigationBarItem,
                    ),
                  ),
                ),
              ),
              // The floating action button, positioned to overlap the navigation bar.
              Positioned(
                top: -17.5, // Raise the FAB above the bar.
                left: 0,
                right: 0,
                // Center the FAB horizontally using Align widget.
                child: Align(
                  alignment: Alignment.center,
                  child: FloatingActionButton(
                    // When pressed, show the CreatePostSheet in a modal bottom sheet.
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return const FractionallySizedBox(
                            heightFactor:
                                1.0, // This makes the bottom sheet take the full height
                            child: CreatePostSheet(),
                          );
                        },
                      );
                    },
                    child: const Icon(
                      Icons.add,
                      color: Color(0xffD2C0DD), // Icon color.
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
