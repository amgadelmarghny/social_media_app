part of 'register_cubit.dart';

sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class TextFieldObscureState extends RegisterState {}

final class TextFieldValidationState extends RegisterState {}

final class RegisterLoadingState extends RegisterState {}

final class RegisterFailureState extends RegisterState {
  final String errMessage;

  RegisterFailureState({required this.errMessage});
}

final class SaveUserInfoLoadingState extends RegisterState {}

final class SaveUserInfoSuccessState extends RegisterState {
  final String uid;

  SaveUserInfoSuccessState({required this.uid});
}

final class SaveUserInfoFailureState extends RegisterState {
  final String errMessage;

  SaveUserInfoFailureState({required this.errMessage});
}

