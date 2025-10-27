part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoadingState extends LoginState {}

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

final class SendPasswordResetEmailLoading extends LoginState {}

final class SendPasswordResetEmailSuccess extends LoginState {
  final String message;

  SendPasswordResetEmailSuccess({required this.message});
}

final class SendPasswordResetEmailFailure extends LoginState {
  final String errMessage;

  SendPasswordResetEmailFailure({required this.errMessage});
}
