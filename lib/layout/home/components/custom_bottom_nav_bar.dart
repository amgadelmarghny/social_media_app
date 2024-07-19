import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/new_post/new_post.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/bottom_bar_cilper.dart';

class CustomBottomNavBat extends StatelessWidget {
  const CustomBottomNavBat({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialCubit, SocialState>(builder: (context, state) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: BottomBarClipper(context, height: 73),
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(1.5),
              color: const Color(0xffBA85E8),
              child: ClipPath(
                clipper: BottomBarClipper(context, height: 73),
                child: BottomNavigationBar(
                  currentIndex: BlocProvider.of<SocialCubit>(context)
                      .currentBottomNavBarIndex,
                  onTap: (value) {
                    BlocProvider.of<SocialCubit>(context)
                        .changeBottomNavBar(value);
                  },
                  iconSize: 28,
                  items: BlocProvider.of<SocialCubit>(context)
                      .bottomNavigationBarItem,
                ),
              ),
            ),
          ),
          Positioned(
            top: -17.5,
            left: (MediaQuery.sizeOf(context).width - 25) / 2 - 17.5,
            child: FloatingActionButton(
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
                color: Color(0xffD2C0DD),
              ),
            ),
          )
        ],
      );
    });
  }
}
