import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  // text field obscure
  bool isObscure = true;
  IconData eyeIcon = Icons.visibility_off_outlined;

  void changeTextFieldObscure() {
    isObscure = !isObscure;
    eyeIcon =
        isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(TextFieldObscureState());
  }

  // text field validation
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  GlobalKey<FormState> formKey = GlobalKey();
  void noticeTextFormFieldValidation() {
    autovalidateMode = AutovalidateMode.always;
    emit(TextFieldValidationState());
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void loginUser({required String email, required String password}) async {
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      emit(LoginSuccessState(uid: userCredential.user!.uid));
    } on FirebaseAuthException catch (e) {
      // Catching FirebaseAuthException specifically for more detailed error handling
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        emit(LoginFailureState(errMessage: 'Invalid email or password.'));
      } else if (e.code == 'invalid-credential') {
        emit(LoginFailureState(
            errMessage: 'Credentials are malformed or expired.'));
      } else {
        emit(LoginFailureState(
            errMessage: 'An unknown error occurred: ${e.message}'));
      }
      log('Login error: ${e.message}');
    } catch (error) {
      emit(LoginFailureState(errMessage: error.toString()));
      log(error.toString());
    }
  }
}
