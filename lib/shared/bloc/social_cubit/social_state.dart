part of 'social_cubit.dart';

sealed class SocialState {}

final class SocialInitial extends SocialState {}

final class BottomNavBarState extends SocialState {}

////////////////! get user data /////////////////
final class GetMyDataLoadingState extends SocialState {}

final class GetMyDataSuccessState extends SocialState {}

final class GetMyDataFailureState extends SocialState {
  final String errMessage;

  GetMyDataFailureState({required this.errMessage});
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

final class RemovePostFailureState extends SocialState {
  final String errMessage;

  RemovePostFailureState({required this.errMessage});
}

// //////////////////! like post ///////////////
final class ToggleLikeLoadingState extends SocialState {}

final class ToggleLikeSuccessState extends SocialState {}

final class LikePostFailureState extends SocialState {
  final String errMessage;

  LikePostFailureState({required this.errMessage});
}

////////////////! get feed posts /////////////////
final class GetFeedsPostsLoadingState extends SocialState {}

final class GetFeedsPostsSuccessState extends SocialState {}

final class GetFeedsPostsFailureState extends SocialState {
  final String errMessage;

  GetFeedsPostsFailureState({required this.errMessage});
}

final class GetMyPostsLoading extends SocialState {}

final class GetMyPostsSuccess extends SocialState {}

final class GetMyPostsFailure extends SocialState {
  final String errMessage;

  GetMyPostsFailure({required this.errMessage});
}

final class GetPostLikesSuccessState extends SocialState {}

final class GetPostLikesFailureState extends SocialState {
  final String errMessage;

  GetPostLikesFailureState({required this.errMessage});
}

//////////////////! get users who did likes in post //////////
final class GetUsersLikesPostLoadingState extends SocialState {}

final class GetUsersLikesPostSuccessState extends SocialState {}

final class GetUsersLikesPostFailureState extends SocialState {
  final String errMessage;

  GetUsersLikesPostFailureState({required this.errMessage});
}

////////////////////! update user info /////////////////
final class UpdateUserInfoLoadingState extends SocialState {}

final class UpdateUserInfoFailureState extends SocialState {
  final String errMessage;

  UpdateUserInfoFailureState({required this.errMessage});
}

class GetFollowersSuccessState extends SocialState {
  GetFollowersSuccessState();
}

class GetFollowingSuccessState extends SocialState {
  GetFollowingSuccessState();
}
