import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/register_cubit/register_cubit.dart';
import 'package:social_media_app/shared/components/gender_icon.dart';

class GenderIconList extends StatefulWidget {
  const GenderIconList({
    super.key,
  });

  @override
  State<GenderIconList> createState() => _GenderIconListState();
}

class _GenderIconListState extends State<GenderIconList> {
  int? isSelected;
  @override
  Widget build(BuildContext context) {
    const List<String> genderTypeList = [
      'Male',
      'Female',
      'Other',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: genderTypeList
          .map((e) => GestureDetector(
                onTap: () {
                  isSelected = genderTypeList.indexOf(e);
                  setState(() {});
                  if (isSelected == genderTypeList.indexOf(e)) {
                    BlocProvider.of<RegisterCubit>(context).gender = e;
                  }
                },
                child: GenderIcon(
                  genderType: e,
                  isActive:
                      isSelected == genderTypeList.indexOf(e) ? true : false,
                ),
              ))
          .toList(),
    );
  }
}
