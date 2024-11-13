import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class GenderIcon extends StatelessWidget {
  const GenderIcon({
    super.key,
    required this.genderType,
    required this.isActive,
  });
  final String genderType;
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: height,
      width: width,
      duration: const Duration(milliseconds: 300),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: isActive ? const Color(0xff8B64DA) : Colors.white,
            width: 2.4,
          ),
        ),
      ),
      child: Center(
        child: Text(
          genderType,
          style: FontsStyle.font18Popin(),
        ),
      ),
    );
  }
}
