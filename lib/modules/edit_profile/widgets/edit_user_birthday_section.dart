import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';

import '../../../shared/components/expanded_list_animation_widget.dart';
import '../../../shared/components/text_form_field.dart';

class EditUserBirthdaySection extends StatefulWidget {
  const EditUserBirthdaySection({
    super.key,
  });

  @override
  State<EditUserBirthdaySection> createState() => _EditUserBirthdaySectionState();
}

class _EditUserBirthdaySectionState extends State<EditUserBirthdaySection> {
  bool isStretchedDropDown = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('BirthDay'),
          trailing: isStretchedDropDown
              ? const Icon(IconBroken.Arrow___Up_2)
              : const Icon(IconBroken.Arrow___Down_2),
          onTap: () {
            setState(() {
              isStretchedDropDown = !isStretchedDropDown;
            });
          },
        ),
        ExpandedSection(
          expand: isStretchedDropDown,
          height: 100,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                outLineBorderColor: Colors.grey,
                contentVerticalPadding: 10,
                textInputType: TextInputType.datetime,
                hintText: 'DD/MM/YYYY',
              ),
            ],
          ),
        ),
      ],
    );
  }
}