import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/onBoarding/user_model.dart';
import 'package:social_media_app/shared/components/constants.dart';

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

  // text field validation
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  GlobalKey<FormState> formKey = GlobalKey();
  void noticeTextFormFieldValidation() {
    autovalidateMode = AutovalidateMode.always;
    emit(TextFieldValidationState());
  }

  late UserCredential userCredential;
  String? gender;
  void userRegister({
    required String firstName,
    required String lastName,
    required String dateAndMonth,
    required String year,
    required String email,
    required String gender,
    required String password,
  }) async {
    emit(RegisterLoadingState());
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          dateAndMonth: dateAndMonth,
          year: year,
          gender: gender);
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(userCredential.user!.uid)
          .set(userModel.tojson());
      emit(RegisterLoadingState());
    } on Exception catch (error) {
      emit(RegisterFailureState(errMessage: error.toString()));
    }
  }
}
