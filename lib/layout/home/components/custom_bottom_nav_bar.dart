import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:social_media_app/shared/components/bottom_bar_cilper.dart';

class CustomBottomNavBat extends StatelessWidget {
  const CustomBottomNavBat({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: BottomBarClipper(context, hight: 73),
          // Apply clipper to Container
          child: Container(
            height: 80,
            padding: const EdgeInsets.all(1.5),
            color: const Color(0xffBA85E8),
            child: ClipPath(
              clipper: BottomBarClipper(context, hight: 73),
              child: BottomNavigationBar(
                iconSize: 28,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(IconBroken.Home), label: ''),
                  BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(IconBroken.Chat),
                      ),
                      label: ''),
                  BottomNavigationBarItem(icon: SizedBox(), label: ''),
                  BottomNavigationBarItem(
                      icon: Icon(IconBroken.Profile), label: ''),
                  BottomNavigationBarItem(
                      icon: Icon(IconBroken.Notification), label: ''),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -17.5,
          left: (MediaQuery.sizeOf(context).width - 25) / 2 - 17.5,
          child: FloatingActionButton(
            onPressed: () {},
            child: const Icon(
              Icons.add,
              size: 35,
              color: Color(0xffD2C0DD),
            ),
          ),
        )
      ],
    );
  }
}
