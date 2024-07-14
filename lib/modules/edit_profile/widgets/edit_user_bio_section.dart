import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';
import '../../../shared/components/expanded_list_animation_widget.dart';
import '../../../shared/components/text_form_field.dart';

class EditUseBioSection extends StatefulWidget {
  const EditUseBioSection({
    super.key,
  });

  @override
  State<EditUseBioSection> createState() => _EditUseBioSectionState();
}

class _EditUseBioSectionState extends State<EditUseBioSection> {
  bool isStretchedDropDown = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Bio'),
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
                textInputType: TextInputType.text,
                hintText: 'Write your bio',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
