import 'package:flutter/material.dart';
import 'package:social_media_app/shared/style/theme/constant.dart';
// Call this in the select year button.

Future<String?> pickYear({required BuildContext context}) async {
  String? selectedYear;
  await showDialog(
    context: context,
    builder: (context) {
      final Size size = MediaQuery.of(context).size;
      int currentYear = DateTime.now().year;
      int minimumeYear = currentYear - 13;
     return AlertDialog(
        backgroundColor: defaultColorButton,

        title: const Text(
          'Select a Year',
          style: TextStyle(color: Colors.white),
        ),
        // Changing default contentPadding to make the content looks better

        contentPadding: const EdgeInsets.all(10),
        content: SizedBox(
          // Giving some size to the dialog so the gridview know its bounds

          height: size.height / 3,
          width: size.width,
          //  Creating a grid view with 3 elements per line.
          child: GridView.count(
            crossAxisCount: 3,
            children: [
              // Generating a list of 123 years starting from 2022
              // Change it depending on your needs.
              ...List.generate(
                123,
                (index) => InkWell(
                  onTap: () {
                    // The action you want to happen when you select the year below,
                    selectedYear = (minimumeYear - index).toString();
                    // Quitting the dialog through navigator.
                    Navigator.pop(context);
                  },
                  // This part is up to you, it's only ui elements
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chip(
                      label: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(5),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            // Showing the year text, it starts from 2022 and ends in 1900 (you can modify this as you like)
                            (minimumeYear - index).toString(),
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  return selectedYear;
}
