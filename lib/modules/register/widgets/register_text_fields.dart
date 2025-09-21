import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/modules/register/widgets/user_name_text_field.dart';
import 'package:social_media_app/shared/bloc/register_cubit/register_cubit.dart';
import 'package:social_media_app/shared/components/gender_icon_list.dart';
import 'package:social_media_app/shared/components/text_form_field.dart';
import 'package:social_media_app/shared/components/year_picker.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';

/// Widget that displays all the text fields required for user registration.
class RegisterTextFields extends StatelessWidget {
  const RegisterTextFields({super.key});

  @override
  Widget build(BuildContext context) {
    // Using BlocBuilder to rebuild the widget when RegisterState changes.
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        // Access the RegisterCubit instance.
        RegisterCubit registerCubit = BlocProvider.of<RegisterCubit>(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for First Name and Last Name fields.
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: CustomTextField(
                    hintText: 'First Name',
                    controller: registerCubit.firstNameController,
                    textInputType: TextInputType.name,
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 6,
                  child: CustomTextField(
                    hintText: 'Last Name',
                    textInputType: TextInputType.name,
                    controller: registerCubit.lastNameController,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            // Email or phone number field.
            CustomTextField(
              hintText: 'Email/phone number',
              textInputType: TextInputType.emailAddress,
              controller: registerCubit.emailController,
            ),
            const SizedBox(
              height: 15,
            ),
            const UserNameTextField(),
            const SizedBox(
              height: 15,
            ),
            // Password field with visibility toggle.
            CustomTextField(
              hintText: 'Password',
              textInputType: TextInputType.visiblePassword,
              obscureText: registerCubit.isObscure,
              controller: registerCubit.passwordController,
              suffixIcon: IconButton(
                onPressed: () {
                  // Toggle password visibility.
                  registerCubit.changeTextFieldObscure();
                },
                icon: Icon(
                  registerCubit.eyeIcon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            // Label for birth date section.
            Text(
              'Birth of date',
              style: FontsStyle.font18Popin(),
            ),
            SizedBox(
              height: 15,
            ),
            // Row for date/month and year fields.
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: CustomTextField(
                    hintText: 'Date/month',
                    textInputType: TextInputType.datetime,
                    controller: registerCubit.dateAndMonthController,
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    hintText: 'Year',
                    controller: registerCubit.yearController,
                    textInputType: TextInputType.datetime,
                    onTap: () async {
                      // Show year picker dialog when tapped.
                      String? selectedYear = await pickYear(context: context);
                      if (selectedYear != null) {
                        // Set the selected year in the controller.
                        registerCubit.yearController.text = selectedYear;
                      }
                    },
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Down arrow icon for year picker.
                        SvgPicture.asset(
                          'lib/assets/images/arrow_bottom.svg',
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            // Label for gender selection.
            Text(
              'Gender',
              style: FontsStyle.font18Popin(),
            ),
            const SizedBox(
              height: 15,
            ),
            // Gender icon selection widget.
            const GenderIconList(),
          ],
        );
      },
    );
  }
}
