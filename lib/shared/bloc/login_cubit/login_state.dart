part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginloadingSatate extends LoginState {}

final class TextFieldObscureState extends LoginState {}

final class TextFieldValidationState extends LoginState {}

final class LoginSuccessState extends LoginState {
  final String uid;

  LoginSuccessState({required this.uid});
}

final class LoginFailureState extends LoginState {
  final String errMessage;

  LoginFailureState({required this.errMessage});
}
