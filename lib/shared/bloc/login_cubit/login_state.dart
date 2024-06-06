part of 'login_cubit.dart';

sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginloadingSatate extends LoginState {}

final class LoginSuccessSatate extends LoginState {
  final String uid;

  LoginSuccessSatate({required this.uid});
}

final class LoginFailureSatate extends LoginState {
  final String errMessage;

  LoginFailureSatate({required this.errMessage});
}
