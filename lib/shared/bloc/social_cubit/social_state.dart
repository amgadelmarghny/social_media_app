part of 'social_cubit.dart';

sealed class SocialState {}

final class SocialInitial extends SocialState {}

final class BottomNavBarState extends SocialState {}

////////////////! get user data /////////////////
final class GetUserDataLoadingState extends SocialState {}

final class GetUserDataSuccessState extends SocialState {}

final class GetUserDataFailureState extends SocialState {
  final String errMessage;

  GetUserDataFailureState({required this.errMessage});
}

// pick image
final class PickImageLoadingState extends SocialState {}

final class PickImageSuccessState extends SocialState {}

final class PickImageFailureState extends SocialState {
  final String errMessage;

  PickImageFailureState({required this.errMessage});
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
final class UploadPostImageSuccessState extends SocialState {}

final class UploadPostImageFailureState extends SocialState {
  final String errMessage;

  UploadPostImageFailureState({required this.errMessage});
}

// create post
final class CreatePostLoadingState extends SocialState {}

final class CreatePostSuccessState extends SocialState {}

final class CreatePostFailureState extends SocialState {
  final String errMessage;

  CreatePostFailureState({required this.errMessage});
}

//remove image
final class RemovePickedFile extends SocialState {}

// cancel upload post
final class RemovePostState extends SocialState {}

// //////////////////! like post ///////////////
final class ToggleLikeSuccessState extends SocialState {}

final class LikePostFailureState extends SocialState {
  final String errMessage;

  LikePostFailureState({required this.errMessage});
}

////////////////! get posts /////////////////
final class GetPostsLoadingState extends SocialState {}

final class GetPostsSuccessState extends SocialState {}

final class GetPostsFailureState extends SocialState {
  final String errMessage;

  GetPostsFailureState({required this.errMessage});
}

////////////////////! update user info /////////////////
final class UpdateUserInfoLoadingState extends SocialState {}

final class UpdateUserInfoFailureState extends SocialState {
  final String errMessage;

  UpdateUserInfoFailureState({required this.errMessage});
}
