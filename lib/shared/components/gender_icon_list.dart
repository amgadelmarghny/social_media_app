import 'package:flutter/material.dart';
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
    const List<String> genderTypeList = ['Male', 'Female', 'Athor'];
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: genderTypeList.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            isSelected = index;
            setState(() {});
          },
          child: GenderIcon(
            genderType: genderTypeList[index],
            isActive: isSelected == index ? true : false,
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(
          width: 35,
        ),
      ),
    );
  }
}
