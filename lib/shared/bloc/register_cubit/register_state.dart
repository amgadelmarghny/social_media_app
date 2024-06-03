part of 'register_cubit.dart';

sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class TextFieldObscureState extends RegisterState {}

final class TextFieldValidationState extends RegisterState {}

final class RegisterLoadingState extends RegisterState {}

final class RegisterSuccessState extends RegisterState {}

final class RegisterFailureState extends RegisterState {
  final String errMessage;

  RegisterFailureState({required this.errMessage});
}
