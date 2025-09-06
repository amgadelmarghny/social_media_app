import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_broken/icon_broken.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import '../../../shared/components/expanded_list_animation_widget.dart';
import '../../../shared/components/text_form_field.dart';

class EditUserBirthdaySection extends StatefulWidget {
  const EditUserBirthdaySection({
    super.key,
  });

  @override
  State<EditUserBirthdaySection> createState() =>
      _EditUserBirthdaySectionState();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller:
                    BlocProvider.of<SocialCubit>(context).birthdayController,
                outLineBorderColor: Colors.grey,
                contentVerticalPadding: 10,
                textInputType: TextInputType.datetime,
                hintText: 'DD/MM/YYYY',
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.parse('1930-01-01'),
                    lastDate: DateTime.now(),
                  ).then(
                    (value) {
                      if (value != null && context.mounted) {
                      
                        BlocProvider.of<SocialCubit>(context)
                            .birthdayController
                            .text = DateFormat.yMMMd().format(value);
                        BlocProvider.of<SocialCubit>(context)
                                .updatedDayAndMonth =
                            DateFormat.MMMMd().format(value);
                        BlocProvider.of<SocialCubit>(context)
                            .updatedYear =
                            DateFormat.y().format(value);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
