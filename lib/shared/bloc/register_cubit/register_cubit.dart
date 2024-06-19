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
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  GlobalKey<FormState> formKey = GlobalKey();
  void noticeTextFormFieldValidation() {
    autoValidateMode = AutovalidateMode.always;
    emit(TextFieldValidationState());
  }

  TextEditingController yearController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController dateAndMonthController = TextEditingController();

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
      await saveUserData(
        firstName: firstName,
        lastName: lastName,
        dateAndMonth: dateAndMonth,
        year: year,
        email: email,
        gender: gender,
        uid: userCredential.user!.uid,
      );
    } on Exception catch (error) {
      emit(RegisterFailureState(errMessage: error.toString()));
    }
  }

  Future<void> saveUserData({
    required String firstName,
    required String lastName,
    required String dateAndMonth,
    required String year,
    required String email,
    required String gender,
    required String uid,
  }) async {
    emit(SaveUserInfoLoadingState());
    UserModel userModel = UserModel(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      dateAndMonth: dateAndMonth,
      year: year,
      gender: gender,
      photo:
          'https://img.freepik.com/free-vector/blue-circle-with-white-user_78370-4707.jpg?t=st=1718443395~exp=1718446995~hmac=0e6003476b13a111d940370d474ab77d892f114041691e56209fdeb2024a310d&w=740',
    );
    try {
      await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .set(userModel.tojson());
      emit(SaveUserInfoSuccessState(uid: uid));
    } catch (err) {
      emit(SaveUserInfoFailureState(errMessage: err.toString()));
    }
  }
}
