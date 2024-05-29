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
        style: FontsStyle.font18Popin(),
        validator: (data) {
          if (data?.isEmpty ?? true) {
            return 'FIELD IS EMPTY';
          }
          return null;
        },
        controller: controller,
        onChanged: onChange,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                )
              : null,
          hintText: hintText,
          hintStyle: FontsStyle.font18Popin(),
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
      borderSide: const BorderSide(
        width: 2.2,
        color: Colors.white,
      ),
    );
  }
}
