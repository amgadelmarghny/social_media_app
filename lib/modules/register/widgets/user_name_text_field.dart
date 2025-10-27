import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/bloc/register_cubit/register_cubit.dart';
import 'package:social_media_app/shared/components/text_form_field.dart';

/// A custom text field widget for entering a username during registration.
/// It checks username availability as the user types and shows a loading indicator.
class UserNameTextField extends StatefulWidget {
  const UserNameTextField({super.key});

  @override
  State<UserNameTextField> createState() => _UserNameTextFieldState();
}

class _UserNameTextFieldState extends State<UserNameTextField> {
  late RegisterCubit
      registerCubit; // Reference to the RegisterCubit for state management
  String? errorText; // Holds error message if username is taken
  bool isChecking =
      false; // Indicates if username availability is being checked
  @override
  void initState() {
    super.initState();
    // Get the RegisterCubit instance from the context
    registerCubit = context.read<RegisterCubit>();

    // Add a listener to the username controller to check username availability on every change
    registerCubit.userNameController.addListener(() {
      final value = registerCubit.userNameController.text;
      _checkUsername(value);
    });
  }

  /// Checks if the entered username is available.
  /// Shows a loading indicator while checking and updates errorText accordingly.
  void _checkUsername(String value) async {
    if (value.isEmpty) {
      // If the field is empty, clear any error message
      if (mounted) setState(() => errorText = null);
      return;
    }

    // Set loading state to true
    if (mounted) setState(() => isChecking = true);

    // Check username availability asynchronously
    final available = await registerCubit.checkUsernameAvailable(value);

    // Update UI based on availability result
    if (mounted) {
      setState(() {
        isChecking = false;
        errorText = available ? null : "Username already taken!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: 'username',
      // Optionally, you could pass errorText to CustomTextField if it supports it
      controller: registerCubit.userNameController,
      errorText: errorText,
      // Show a loading spinner as a suffix icon while checking username
      suffixIcon: isChecking
          ? const SizedBox(
              width: 10,
              height: 10,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
