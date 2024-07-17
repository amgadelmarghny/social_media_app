import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/user_model.dart';
import 'package:social_media_app/models/user_register_impl.dart';
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
  void userRegister(UserRegisterImpl userRegisterImpl) async {
    emit(RegisterLoadingState());
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: userRegisterImpl.email,
          password: userRegisterImpl.password);
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        firstName: userRegisterImpl.firstName,
        lastName: userRegisterImpl.lastName,
        email: userRegisterImpl.email,
        dateAndMonth: userRegisterImpl.dateAndMonth,
        year: userRegisterImpl.year,
        gender: userRegisterImpl.gender,
      );
      await saveUserData(
        userModel: userModel,
      );
    } on Exception catch (error) {
      emit(RegisterFailureState(errMessage: error.toString()));
    }
  }

  Future<void> saveUserData({required UserModel userModel}) async {
    emit(SaveUserInfoLoadingState());
    try {
      await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(userModel.uid)
          .set(userModel.toMap());
      emit(SaveUserInfoSuccessState(uid: userModel.uid));
    } catch (err) {
      emit(SaveUserInfoFailureState(errMessage: err.toString()));
    }
  }
}
