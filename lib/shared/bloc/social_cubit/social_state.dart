part of 'social_cubit.dart';

sealed class SocialState {}

final class SocialInitial extends SocialState {}

final class SocialLoadingState extends SocialState {}

final class SocialSuccessState extends SocialState {}

final class BottomNavBarState extends SocialState {}

final class SocialFailureState extends SocialState {
  final String errMessage;

  SocialFailureState({required this.errMessage});
}
