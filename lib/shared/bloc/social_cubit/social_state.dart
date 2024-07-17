part of 'social_cubit.dart';

sealed class SocialState {}

final class SocialInitial extends SocialState {}

final class BottomNavBarState extends SocialState {}

final class GetUserDataLoadingState extends SocialState {}

final class GetUserDataSuccessState extends SocialState {}

final class GetUserDataFailureState extends SocialState {
  final String errMessage;

  GetUserDataFailureState({required this.errMessage});
}

final class ProfileImagePickedLoadingState extends SocialState {}

final class ProfileImagePickedSuccessState extends SocialState {}

final class ProfileImagePickedFailureState extends SocialState {
  final String errMessage;

  ProfileImagePickedFailureState({required this.errMessage});
}

final class UploadProfileImageLoadingState extends SocialState {}

final class UploadProfileImageSuccessState extends SocialState {}

final class UploadProfileImageFailureState extends SocialState {
  final String errMessage;

  UploadProfileImageFailureState({required this.errMessage});
}

final class CoverImagePickedLoadingState extends SocialState {}

final class CoverImagePickedSuccessState extends SocialState {}

final class CoverImagePickedFailureState extends SocialState {
  final String errMessage;

  CoverImagePickedFailureState({required this.errMessage});
}

final class UploadCoverImageLoadingState extends SocialState {}

final class UploadCoverImageSuccessState extends SocialState {}

final class UploadCoverImageFailureState extends SocialState {
  final String errMessage;

  UploadCoverImageFailureState({required this.errMessage});
}

final class UpdateUserInfoLoadingState extends SocialState {}

final class UpdateUserInfoFailureState extends SocialState {
  final String errMessage;

  UpdateUserInfoFailureState({required this.errMessage});
}
