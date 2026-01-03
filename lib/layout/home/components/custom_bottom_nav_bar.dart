import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/new_post/new_post.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/bottom_bar_cilper.dart';
import 'package:social_media_app/shared/components/bottom_bar_shadow_painter.dart';

/// Custom bottom navigation bar with a floating action button for adding new posts.
/// Uses BlocBuilder to reactively update UI based on SocialCubit state.
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the width of the device's screen for responsive sizing.
    final width = MediaQuery.sizeOf(context).width;

    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        // Retrieve the SocialCubit instance from the context.
        var cubit = context.read<SocialCubit>();

        return Container(
          width: width,
          height: 100,
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Main navigation bar positioned above the bottom edge with side paddings.
              Positioned(
                bottom: 3, // 3 pixels above the screen's bottom edge.
                left: 15, // Padding from the left.
                right: 15, // Padding from the right.
                child: CustomPaint(
                  // The size is reduced by 30 pixels to account for left/right paddings.
                  size: Size(width - 30, 70),
                  painter:
                      BottomBarShadowPainter(), // Custom shadow painter for the bar.
                  child: ClipPath(
                    clipper:
                        BottomBarClipper(), // Custom clipper for the desired bar shape.
                    child: Container(
                      height: 70,
                      color: const Color(0xffF5F5F5), // Bar background color.
                      child: BottomNavigationBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: const Color(0xff6A5C93),
                        unselectedItemColor: Colors.grey,
                        currentIndex: cubit.currentBottomNavBarIndex,
                        onTap: cubit.changeBottomNavBar,
                        items: cubit.bottomNavigationBarItem,
                      ),
                    ),
                  ),
                ),
              ),

              // Floating action button for creating a new post, positioned over the bar.
              Positioned(
                bottom: 38, // Raised above the bar to visually float over it.
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        // Shadow for the FAB to give a floating effect.
                        BoxShadow(
                          color: const Color(0xff6A5C93).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      elevation: 0,
                      backgroundColor: const Color(0xff6A5C93),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          enableDrag: false, // Prevents dragging down to close
                          backgroundColor: Colors.transparent,
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 1,
                            maxChildSize: 1,
                            minChildSize: 1,
                            expand: true,
                            builder: (context, scrollController) =>
                                const CreatePostSheet(),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.add,
                        color: Color(0xffD2C0DD),
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
