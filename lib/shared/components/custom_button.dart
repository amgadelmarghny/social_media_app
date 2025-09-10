import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import '../style/theme/constant.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.buttonColor = const Color(0xFF635A8F),
    this.textColor = Colors.white,
    this.height = 55, this.width, this.fontSize = 22
  });
  final void Function()? onTap;
  final String text;
  final bool isLoading;
  final Color buttonColor;
  final Color textColor;
  final double height;
  final double? width, fontSize;
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          shadows: const [
            BoxShadow(
              blurRadius: 5,
              offset: Offset(0, 5),
              color: Colors.black38,
            )
          ],
          color: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(
                  color: defaultColor,
                )
              : Text(
                  text,
                  style: FontsStyle.font22Bold(color: textColor ,fontSize:fontSize! ),
                ),
        ),
      ),
    );
  }
}
