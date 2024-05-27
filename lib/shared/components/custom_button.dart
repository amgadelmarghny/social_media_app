import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
  });
  final void Function()? onTap;
  final String text;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: ShapeDecoration(
          shadows: const [
            BoxShadow(
              blurRadius: 5,
              offset: Offset(0, 5),
              color: Colors.black38,
            )
          ],
          color: const Color(0xFF635A8F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: FontsStyle.font22Blod,
          ),
        ),
      ),
    );
  }
}
