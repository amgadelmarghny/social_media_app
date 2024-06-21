import 'package:flutter/material.dart';
import '../../../shared/components/custom_button.dart';

class FollowAndMessageButtons extends StatelessWidget {
  const FollowAndMessageButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            height: 50,
            text: 'Follow',
            onTap: () {},
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: CustomButton(
            text: 'Message',
            height: 50,
            buttonColor: Colors.white,
            textColor: const Color(0xFF635A8F),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
