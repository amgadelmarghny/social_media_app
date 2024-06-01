import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class GenderIcon extends StatelessWidget {
  const GenderIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 60,
      width: 100,
      duration: const Duration(milliseconds: 300),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(
            color: Color(0xff8B64DA),
            width: 2.4,
          ),
        ),
      ),
      child: Center(
        child: Text(
          'Male',
          style: FontsStyle.font18Popin(),
        ),
      ),
    );
  }
}
