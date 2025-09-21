import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/models/user_register_impl.dart';
import 'package:social_media_app/shared/components/constants.dart';

part 'register_state.dart';

/// Cubit responsible for handling user registration logic and state.
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  // Controls whether the password field is obscured (hidden) or visible.
  bool isObscure = true;
  // Icon to display for the password visibility toggle.
  IconData eyeIcon = Icons.visibility_off_outlined;

  /// Toggles the password field's visibility and updates the icon.
  void changeTextFieldObscure() {
    isObscure = !isObscure;
    eyeIcon =
        isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(TextFieldObscureState());
  }

  // Controls the validation mode for the registration form.
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  // Key to uniquely identify the registration form.
  GlobalKey<FormState> formKey = GlobalKey();

  /// Enables auto-validation for the registration form fields.
  void noticeTextFormFieldValidation() {
    autoValidateMode = AutovalidateMode.always;
    emit(TextFieldValidationState());
  }

  // Controllers for the registration form fields.
  TextEditingController yearController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dateAndMonthController = TextEditingController();

  // Stores the result of the Firebase authentication process.
  late UserCredential userCredential;
  // Stores the selected gender value.
  String? gender;

  /// Registers a new user using Firebase Authentication and saves user data to Firestore.
  ///
  /// Emits [RegisterLoadingState] while processing, [RegisterFailureState] on error.
  Future<void> userRegister(UserRegisterImpl userRegisterImpl) async {
    emit(RegisterLoadingState());
    try {
      // Create user with email and password using Firebase Auth.
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userRegisterImpl.email,
        password: userRegisterImpl.password,
      );

      // Create a user model with the provided registration data.
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        firstName: userRegisterImpl.firstName,
        lastName: userRegisterImpl.lastName,
        email: userRegisterImpl.email,
        dateAndMonth: userRegisterImpl.dateAndMonth,
        year: userRegisterImpl.year,
        gender: userRegisterImpl.gender,
        userName: userRegisterImpl.userName,
      );

      // Save the user data to Firestore.
      await saveUserData(
        userModel: userModel,
      );
    } on Exception catch (error) {
      // Emit failure state if registration fails.
      emit(RegisterFailureState(errMessage: error.toString()));
    }
  }

  /// Checks if a username is available in the Firestore 'users' collection.
  ///
  /// Converts the provided [username] to lowercase and queries the 'users' collection
  /// for any document where the 'username' field matches. If no documents are found,
  /// the username is available and the function returns true. Otherwise, returns false.
  ///
  /// Returns:
  ///   - [true] if the username is available (not taken).
  ///   - [false] if the username is already in use.
  Future<bool> checkUsernameAvailable(String username) async {
    // Query the 'users' collection for documents with a matching username (case-insensitive).
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .get();

    // If the query returns no documents, the username is available.
    // (If empty, then available)
    return querySnapshot.docs.isEmpty;
  }

  /// Saves the user data to Firestore under the users collection.
  ///
  /// Emits [SaveUserInfoLoadingState] while saving, [SaveUserInfoSuccessState] on success,
  /// or [SaveUserInfoFailureState] on error.
  Future<void> saveUserData({required UserModel userModel}) async {
    emit(SaveUserInfoLoadingState());
    try {
      await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(userModel.uid)
          .set(userModel.toMap());
      emit(SaveUserInfoSuccessState(uid: userModel.uid));
    } catch (err) {
      emit(SaveUserInfoFailureState(errMessage: err.toString()));
    }
  }
}
