part of 'social_cubit.dart';

sealed class SocialState {}

final class SocialInitial extends SocialState {}

final class BottomNavBarState extends SocialState {}

///////////////! get user data /////////////////
final class GetUserDataLoadingState extends SocialState {}

final class GetUserDataSuccessState extends SocialState {}

final class GetUserDataFailureState extends SocialState {
  final String errMessage;

  GetUserDataFailureState({required this.errMessage});
}

// pick image
final class PickeImageLoadingState extends SocialState {}

final class PickeImageSuccessState extends SocialState {}

final class PickeImageFailureState extends SocialState {
  final String errMessage;

  PickeImageFailureState({required this.errMessage});
}

// upload profile image
final class UploadProfileImageLoadingState extends SocialState {}

final class UploadProfileImageSuccessState extends SocialState {}

final class UploadProfileImageFailureState extends SocialState {
  final String errMessage;

  UploadProfileImageFailureState({required this.errMessage});
}

// upload cover image
final class UploadCoverImageLoadingState extends SocialState {}

final class UploadCoverImageSuccessState extends SocialState {}

final class UploadCoverImageFailureState extends SocialState {
  final String errMessage;

  UploadCoverImageFailureState({required this.errMessage});
}

// upload post image
final class UploadPostImageLoadingState extends SocialState {}

final class UploadPostImageSuccessState extends SocialState {}

final class UploadPostImageFailureState extends SocialState {
  final String errMessage;

  UploadPostImageFailureState({required this.errMessage});
}

///////////////////! update user info /////////////////
final class UpdateUserInfoLoadingState extends SocialState {}

final class UpdateUserInfoFailureState extends SocialState {
  final String errMessage;

  UpdateUserInfoFailureState({required this.errMessage});
}
