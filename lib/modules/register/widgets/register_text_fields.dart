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
    FocusNode lastNameFocus = FocusNode();
    FocusNode userNameFocus = FocusNode();
    FocusNode emailFocus = FocusNode();
    FocusNode passwordFocus = FocusNode();
    FocusNode birthOfDateFocus = FocusNode();

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
                    onFieldSubmitted: (unnamed) =>
                        FocusScope.of(context).requestFocus(lastNameFocus),
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 6,
                  child: CustomTextField(
                    hintText: 'Last Name',
                    focusNode: lastNameFocus,
                    onFieldSubmitted: (unnamed) =>
                        FocusScope.of(context).requestFocus(emailFocus),
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
              hintText: 'Email',
              focusNode: emailFocus,
              onFieldSubmitted: (unnamed) =>
                  FocusScope.of(context).requestFocus(userNameFocus),
              textInputType: TextInputType.emailAddress,
              controller: registerCubit.emailController,
            ),
            const SizedBox(
              height: 15,
            ),
            UserNameTextField(
              focusNode: userNameFocus,
              onFieldSubmitted: (unnamed) =>
                  FocusScope.of(context).requestFocus(passwordFocus),
            ),

            const SizedBox(
              height: 15,
            ),
            // Password field with visibility toggle.
            CustomTextField(
              hintText: 'Password',
              focusNode: passwordFocus,
              onFieldSubmitted: (unnamed) =>
                  FocusScope.of(context).requestFocus(birthOfDateFocus),
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
              style: FontsStyle.font18PopinWithShadowOption(),
            ),
            const SizedBox(
              height: 15,
            ),
            // Row for date/month and year fields.
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: CustomTextField(
                    hintText: 'Date/month',
                    focusNode: birthOfDateFocus,
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
              style: FontsStyle.font18PopinWithShadowOption(),
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
