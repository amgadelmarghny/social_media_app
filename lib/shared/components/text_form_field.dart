import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.onChange,
    this.obscureText = false,
    this.hintText,
    this.textInputType,
    this.suffixIcon,
    this.suffixOnPressed,
    this.prefixIcon,
    this.labelText,
    this.controller,
    this.onTap,
    this.outLineBorderColor = Colors.white,
    this.contentVerticalPadding = 16,
    this.errorText,
  });

  final TextEditingController? controller;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final TextInputType? textInputType;
  final bool obscureText;
  final String? hintText;
  final void Function(String)? onChange;
  final void Function()? suffixOnPressed;
  final String? labelText;
  final void Function()? onTap;
  final Color outLineBorderColor;
  final double contentVerticalPadding;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        onTap: onTap,
        maxLines: 1,
        keyboardType: textInputType,
        obscureText: obscureText,
        style: FontsStyle.font18PopinWithShadowOption().copyWith(
          color:
              outLineBorderColor != Colors.white ? Colors.black : Colors.white,
        ),
        validator: (data) {
          if (data?.isEmpty ?? true) {
            return 'FIELD IS EMPTY';
          }
          return null;
        },
        controller: controller,
        onChanged: onChange,
        decoration: InputDecoration(
          
          errorText: errorText,
          contentPadding: EdgeInsets.symmetric(
              horizontal: 20, vertical: contentVerticalPadding),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                )
              : null,
          hintText: hintText,
          hintStyle: FontsStyle.font18PopinWithShadowOption().copyWith(
            color: outLineBorderColor,
          ),
          labelText: labelText,
          labelStyle: const TextStyle(
            fontSize: 16,
          ),
          enabledBorder: outlineBorder(context),
          focusedBorder: outlineBorder(context),
          border: outlineBorder(context),
        ),
      ),
    );
  }

  OutlineInputBorder outlineBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(
        width: 2.2,
        color: outLineBorderColor,
      ),
    );
  }
}
