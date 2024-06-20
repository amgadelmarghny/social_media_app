import 'package:flutter/material.dart';
import '../../../shared/style/fonts/font_style.dart';

class CustomNumberWithTitleColumn extends StatelessWidget {
  const CustomNumberWithTitleColumn({
    super.key,
    required this.number,
    required this.title,
    this.onTap,
  });
  final String number;
  final String title;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: FontsStyle.font35Bold,
          ),
          Text(
            title,
            style: FontsStyle.font20Poppins,
          )
        ],
      ),
    );
  }
}
