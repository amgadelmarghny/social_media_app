import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  // text field obscure
  bool isObscure = true;
  IconData eyeIcon = Icons.visibility_off_outlined;

  void changeTextFieldObscure() {
    isObscure = !isObscure;
    eyeIcon =
        isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(TextFieldObscureState());
  }

  //
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  GlobalKey<FormState> formKey = GlobalKey();
  void noticeTextFormFieldValidation() {
    autovalidateMode = AutovalidateMode.always;
    emit(TextFieldValidationState());
  }

  late UserCredential userCredential;

  void userRegister({required String email, required String password}) async {
    emit(RegisterLoadingState());
    print('loading');
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      emit(RegisterLoadingState());
      print('Success');
    } on Exception catch (error) {
      print(error.toString());
      emit(RegisterFailureState(errMessage: error.toString()));
      print('Failure : ${error.toString()}');
    }
  }
}
