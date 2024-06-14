import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media_app/shared/bloc/register_cubit/register_cubit.dart';
import 'package:social_media_app/shared/components/gender_icon_list.dart';
import 'package:social_media_app/shared/components/text_form_field.dart';
import 'package:social_media_app/shared/components/year_picker.dart';
import 'package:social_media_app/shared/style/fonts/font_style.dart';
import 'bloc_consumer_button.dart';

class RegisterFieldsAndButton extends StatelessWidget {
  const RegisterFieldsAndButton({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        RegisterCubit registerCubit = BlocProvider.of<RegisterCubit>(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(
              height: height * 0.02,
            ),
            CustomTextField(
              hintText: 'Email/phone number',
              textInputType: TextInputType.emailAddress,
              controller: registerCubit.emailController,
            ),
            SizedBox(
              height: height * 0.02,
            ),
            CustomTextField(
              hintText: 'Password',
              textInputType: TextInputType.visiblePassword,
              obscureText: registerCubit.isObscure,
              controller: registerCubit.passwordController,
              suffixIcon: IconButton(
                onPressed: () {
                  registerCubit.changeTextFieldObscure();
                },
                icon: Icon(
                  registerCubit.eyeIcon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: height * 0.015,
            ),
            Text(
              'Birth of date',
              style: FontsStyle.font18Popin(),
            ),
            SizedBox(
              height: height * 0.015,
            ),
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
                      String? selectedYear = await pickYear(context: context);
                      if (selectedYear != null) {
                        registerCubit.yearController.text = selectedYear;
                      }
                    },
                    suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                      SvgPicture.asset(
                        'lib/assets/images/arrow_bottom.svg',
                        height: 20,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height * 0.015,
            ),
            Text(
              'Gender',
              style: FontsStyle.font18Popin(),
            ),
            SizedBox(
              height: height * 0.015,
            ),
            const GenderIconList(),
            SizedBox(
              height: height * 0.15,
            ),
            BlocConsumerButton(
              emailController: registerCubit.emailController,
              firstNameController: registerCubit.firstNameController,
              lastNameController: registerCubit.lastNameController,
              dateAndMonthController: registerCubit.dateAndMonthController,
              yearController: registerCubit.yearController,
            ),
          ],
        );
      },
    );
  }
}
