import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/components/constants.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  // Controls if the password field is obscured
  bool isObscure = true;
  IconData eyeIcon = Icons.visibility_off_outlined;

  /// Toggle the visibility of the password text field
  void changeTextFieldObscure() {
    isObscure = !isObscure;
    eyeIcon =
        isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(TextFieldObscureState());
  }

  // Validation related fields
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  GlobalKey<FormState> formKey = GlobalKey();

  /// Enable text field autovalidate mode and emit a validation state
  void noticeTextFormFieldValidation() {
    autovalidateMode = AutovalidateMode.always;
    emit(TextFieldValidationState());
  }

  // Controllers for login fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// Validate login input data, emit failure state with message if not valid
  bool validateLoginData(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      emit(LoginFailureState(errMessage: 'يرجى ملء جميع الحقول'));
      return false;
    }

    if (!email.contains('@')) {
      emit(LoginFailureState(errMessage: 'البريد الإلكتروني غير صحيح'));
      return false;
    }

    if (password.length < 6) {
      emit(LoginFailureState(
          errMessage: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'));
      return false;
    }

    return true;
  }

  /// Attempt user login using the provided email and password
  Future<void> loginUser(
      {required String email, required String password}) async {
    // Validate before attempting login
    if (!validateLoginData(email, password)) {
      return;
    }

    emit(LoginLoadingState()); // Emit loading state

    try {
      // Clean up input data
      String cleanEmail = email.trim().toLowerCase();
      String cleanPassword = password.trim();

      // Sign out if a user is already signed in
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

      // Attempt Firebase sign-in
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      // Update the FCM token in Firestore after successful login
      await updateFCMToken(userCredential.user!.uid);

      // Emit success state with UID
      emit(LoginSuccessState(uid: userCredential.user!.uid));
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors and display appropriate messages
      String errorMessage;

      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled by the administrator';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'invalid-credential':
          // This error is common even with apparently valid data
          errorMessage = 'Invalid login credentials. Please make sure:\n'
              '• The email is typed correctly\n'
              '• The password is correct\n';
          break;
        case 'too-many-requests':
          errorMessage =
              'Too many attempts, please wait a moment and try again';
          break;
        case 'network-request-failed':
          errorMessage = 'Network connection error';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Email/password login is not enabled in Firebase Console';
          break;
        case 'user-token-expired':
          errorMessage = 'User session expired, please log in again';
          break;
        case 'invalid-user-token':
          errorMessage = 'Invalid user token';
          break;
        default:
          errorMessage = 'An unexpected error occurred: ${e.message}';
      }
      emit(LoginFailureState(errMessage: errorMessage));
    } catch (error) {
      emit(LoginFailureState(
          errMessage: 'An unexpected error occurred: $error'));
    }
  }

  /// Update FCM token for the user document in Firestore with retry mechanism
  Future<void> updateFCMToken(String uid) async {
    try {
      // Wait briefly to ensure Firebase Messaging is initialized
      await Future.delayed(const Duration(seconds: 1));

      String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        // First attempt to update the user's FCM token in Firestore
        await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(uid)
            .update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp()
        });
      } else {
        // Token is null, wait and try again after 3 seconds
        await Future.delayed(const Duration(seconds: 3));
        token = await FirebaseMessaging.instance.getToken();

        if (token != null) {
          // Successfully acquired a token on the second attempt, update in Firestore
          await FirebaseFirestore.instance
              .collection(kUsersCollection)
              .doc(uid)
              .update({
            'fcmToken': token,
            'tokenUpdatedAt': FieldValue.serverTimestamp()
          });
        }
      }
    } catch (error) {
      // Log error but don't emit failure state to avoid disrupting login flow
      debugPrint('Error updating FCM token after login: $error');
    }
  }

  /// Send password reset email using Firebase Auth
  Future<void> sendPasswordResetEmail(String email) async {
    emit(SendPasswordResetEmailLoading());
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      emit(SendPasswordResetEmailSuccess(
          message: 'Password reset link has been sent successfully.'));
    } on FirebaseAuthException catch (e) {
      emit(SendPasswordResetEmailFailure(errMessage: e.toString()));
    } catch (error) {
      emit(SendPasswordResetEmailFailure(errMessage: error.toString()));
    }
  }
}
