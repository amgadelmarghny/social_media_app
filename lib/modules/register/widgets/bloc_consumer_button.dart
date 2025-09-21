import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_register_impl.dart';
import 'package:social_media_app/shared/bloc/register_cubit/register_cubit.dart';
import 'package:social_media_app/shared/components/custom_button.dart';
import 'package:social_media_app/shared/components/show_toast.dart';

class BlocConsumerButton extends StatelessWidget {
  const BlocConsumerButton({
    super.key,
    required this.emailController,
    required this.firstNameController,
    required this.lastNameController,
    required this.dateAndMonthController,
    required this.yearController,
    required this.userNameController,
  });

  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController dateAndMonthController;
  final TextEditingController yearController;
  final TextEditingController userNameController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        RegisterCubit registerCubit = BlocProvider.of<RegisterCubit>(context);
        return CustomButton(
          text: 'Sign up',
          onTap: () {
            if (registerCubit.formKey.currentState!.validate()) {
              if (registerCubit.gender != null) {
                UserRegisterImpl userRegisterImpl = UserRegisterImpl(
                  email: emailController.text,
                  password: emailController.text,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  dateAndMonth: dateAndMonthController.text,
                  year: yearController.text,
                  gender: registerCubit.gender!,
                  userName: userNameController.text,
                );
                registerCubit.userRegister(userRegisterImpl);
              } else {
                customSnakbar(context, msg: 'Please select your gender');
              }
            } else {
              registerCubit.noticeTextFormFieldValidation();
            }
          },
          isLoading: state is RegisterLoadingState,
        );
      },
    );
  }
}
