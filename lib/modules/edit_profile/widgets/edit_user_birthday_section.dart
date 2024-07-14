import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';

class EditUserBirthdaySection extends StatelessWidget {
  const EditUserBirthdaySection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Birthday'),
      trailing: const Icon(IconBroken.Arrow___Down_2),
      onTap: () {},
    );
  }
}