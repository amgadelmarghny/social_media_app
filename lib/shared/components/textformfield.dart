import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
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
  });

  final TextEditingController? controller;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final TextInputType? textInputType;
  final bool obscureText;
  final String? hintText;
  final void Function(String)? onChange;
  final Function()? suffixOnPressed;
  final String? labelText;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        maxLines: 1,
        keyboardType: textInputType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 12, color: Colors.white),
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
              const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: suffixOnPressed,
                  icon: Icon(
                    suffixIcon,
                  ),
                )
              : null,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                )
              : null,
          hintText: hintText,
          hintStyle: FontsStyle.font20Popin(),
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
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
