import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/models/user_register_impl.dart';
import 'package:social_media_app/shared/components/constants.dart';

part 'register_state.dart';

/// RegisterCubit manages user registration logic, including form state,
/// Firebase Auth operations, Firestore integration, and notification token handling.
class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  // Determines if the password field should be hidden (obscure text).
  bool isObscure = true;
  // Current icon for password visibility toggle button.
  IconData eyeIcon = Icons.visibility_off_outlined;

  /// Toggle password field visibility and update the eye icon accordingly.
  void changeTextFieldObscure() {
    isObscure = !isObscure;
    eyeIcon =
        isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(TextFieldObscureState());
  }

  // Keeps track of auto-validation mode for the registration form fields.
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  // The global key for the registration form widget.
  GlobalKey<FormState> formKey = GlobalKey();

  /// Switch the registration form to auto-validation mode to show errors on all fields.
  void noticeTextFormFieldValidation() {
    autoValidateMode = AutovalidateMode.always;
    emit(TextFieldValidationState());
  }

  // Text controllers for all registration form input fields.
  TextEditingController yearController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dateAndMonthController = TextEditingController();

  // Stores the result of the Firebase authentication process for later use.
  late UserCredential userCredential;
  // Holds the user's selected gender during registration.
  String? gender;

  /// Handles user registration:
  /// - Registers the user with Firebase Auth.
  /// - Gets an FCM token for notifications.
  /// - Creates a UserModel and saves it to Firestore.
  /// - Refreshes the FCM token after registration.
  ///
  /// Emits:
  ///   - RegisterLoadingState when starting
  ///   - RegisterFailureState if something goes wrong (commented out for now)
  Future<void> userRegister(UserRegisterImpl userRegisterImpl) async {
    emit(RegisterLoadingState());

    // To debug incorrect password length, print the actual string and its code units
    String rawPassword = userRegisterImpl.password;
    String trimmedPassword = rawPassword.trim();

      try {
        // Register the user with Firebase Auth using supplied email/password.
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: userRegisterImpl.email.trim(),
          password: trimmedPassword,
        );

        // Request a Firebase Cloud Messaging token for notifications.
        String? token = await FirebaseMessaging.instance.getToken();

        // Assemble the user data into a UserModel, ensuring token is always a string.
        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          firstName: userRegisterImpl.firstName,
          lastName: userRegisterImpl.lastName,
          email: userRegisterImpl.email.trim(),
          dateAndMonth: userRegisterImpl.dateAndMonth,
          year: userRegisterImpl.year,
          gender: userRegisterImpl.gender,
          userName: userRegisterImpl.userName,
          fcmToken: token ?? '', // If token is null, store empty string.
        );

        // Persist the user information in Firestore.
        await saveUserData(
          userModel: userModel,
        );

        // Refresh FCM token in Firestore after successful registration.
        await updateFCMToken(userCredential.user!.uid);
      } on FirebaseAuthException catch (e) {
        // Handle Firebase Auth specific errors
        String errorMessage;
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'كلمة المرور ضعيفة جداً';
            break;
          case 'email-already-in-use':
            errorMessage = 'هذا البريد الإلكتروني مستخدم بالفعل';
            break;
          case 'invalid-email':
            errorMessage = 'البريد الإلكتروني غير صحيح';
            break;
          case 'operation-not-allowed':
            errorMessage = 'عملية التسجيل غير مسموحة';
            break;
          case 'network-request-failed':
            errorMessage = 'خطأ في الاتصال بالإنترنت';
            break;
          default:
            errorMessage = 'حدث خطأ غير متوقع: ${e.message}';
        }
        emit(RegisterFailureState(errMessage: errorMessage));
        log('Registration error: ${e.code} - ${e.message}');
      } catch (error) {
        emit(RegisterFailureState(errMessage: 'حدث خطأ غير متوقع: $error'));
        log('Registration error: $error');
      }

  }

  /// Checks if a username is already used in Firestore.
  ///
  /// Performs a query for `username` (normalized to lowercase),
  /// and returns true if available (not taken), false otherwise.
  ///
  /// Returns:
  ///   - [true] if the username is not taken.
  ///   - [false] if the username exists in the collection.
  Future<bool> checkUsernameAvailable(String username) async {
    // Query the 'users' Firestore collection for any user with a matching (lowercase) username.
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .get();

    // Username is available if no documents match.
    return querySnapshot.docs.isEmpty;
  }

  /// Saves [userModel] to Firestore under the users collection.
  ///
  /// Emits state changes:
  ///   - SaveUserInfoLoadingState while saving.
  ///   - SaveUserInfoSuccessState on success (with uid).
  ///   - SaveUserInfoFailureState on error (with error message).
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

  /// Updates the user's FCM token in Firestore after registration.
  ///
  /// Attempts to fetch and update the FCM token immediately;
  /// if unavailable, retries after a 3-second delay.
  ///
  /// Any errors will trigger a toast notification for debugging/user feedback.
  Future<void> updateFCMToken(String uid) async {
    try {
      // Wait briefly to ensure Firebase Messaging is initialized.
      await Future.delayed(const Duration(seconds: 1));

      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        // First attempt to update the user's FCM token in Firestore.
        await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(uid)
            .update({'fcmToken': token});
      } else {
        // Token is null, wait and try again after 3 seconds.
        await Future.delayed(const Duration(seconds: 3));
        token = await FirebaseMessaging.instance.getToken();

        if (token != null) {
          // Successfully acquired a token on the second attempt, update in Firestore.
          await FirebaseFirestore.instance
              .collection(kUsersCollection)
              .doc(uid)
              .update({'fcmToken': token});
        }
      }
    } catch (error) {
      // Show error toast if updating the FCM token fails.
      emit(SaveUserInfoFailureState(
          errMessage: 'Error updating FCM token after registration: $error'));
    }
  }
}
