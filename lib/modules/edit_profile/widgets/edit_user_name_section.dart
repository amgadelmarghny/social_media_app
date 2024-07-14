import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';
import '../../../shared/components/expanded_list_animation_widget.dart';
import '../../../shared/components/text_form_field.dart';

class EditUserNameSection extends StatefulWidget {
  const EditUserNameSection({
    super.key,
  });

  @override
  State<EditUserNameSection> createState() => _EditUserNameSectionState();
}

class _EditUserNameSectionState extends State<EditUserNameSection> {
  bool isStretchedDropDown = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Name'),
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
                  textInputType: TextInputType.name,
                  hintText: 'First name',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  outLineBorderColor: Colors.grey,
                  contentVerticalPadding: 10,
                  textInputType: TextInputType.name,
                  hintText: 'Last name',
                ),
              ],
            )),
      ],
    );
  }
}
