part of 'user_cubit.dart';

/// Base class for all user-related states.
abstract class UserState {}

/// Initial state when the user cubit is first created.
class UserInitial extends UserState {}

final class GetUserPostsLoading extends UserState {}

final class GetUserPostsSuccess extends UserState {}

final class GetUserPostsFailure extends UserState {
  final String errMessage;

  GetUserPostsFailure({required this.errMessage});
}

/// State when a user-related operation is loading.
class GetUserFollowingLoadingState extends UserState {}

/// State indicating that fetching following users was successful.
class GetUserFollowingSuccessState extends UserState {}

/// State when an error occurs in a user-related operation.
class GetUserFollowingErrorState extends UserState {
  /// Error message describing what went wrong.
  final String errMessage;

  /// Constructor for [GetUserFollowingErrorState].
  GetUserFollowingErrorState(this.errMessage);
}

/// State indicating that the follow status has changed.
/// [isFollowing] is true if the user is now following, false otherwise.
class FollowStatusChanged extends UserState {
  final bool isFollowing;

  /// Constructor for [FollowStatusChanged].
  FollowStatusChanged(this.isFollowing);
}

class GetUserFollowersLoadingState extends UserState {}

/// State indicating that fetching followers was successful.
 class GetUserFollowersSuccessState extends UserState {}

class GetUserFollowersFailureState extends UserState {
  final String errMessage;

  GetUserFollowersFailureState({required this.errMessage});
}
