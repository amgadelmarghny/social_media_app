import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';

class EditUseBioSection extends StatelessWidget {
  const EditUseBioSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Bio'),
      trailing: const Icon(IconBroken.Arrow___Down_2),
      onTap: () {},
    );
  }
}
