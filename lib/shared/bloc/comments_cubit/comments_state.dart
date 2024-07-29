part of 'comments_cubit.dart';

sealed class CommentsState {}

final class CommentsInitial extends CommentsState {}

// pick image
final class PickImageLoadingState extends CommentsState {}

final class PickImageSuccessState extends CommentsState {}

final class PickImageFailureState extends CommentsState {
  final String errMessage;

  PickImageFailureState({required this.errMessage});
}

// add comment
final class AddCommentLoading extends CommentsState {}

final class AddCommentSuccess extends CommentsState {}

final class AddCommentFailure extends CommentsState {
  final String error;

  AddCommentFailure({required this.error});
}

// upload Comment image
final class UploadCommentImageLoadingState extends CommentsState {}

final class UploadCommentImageFailureState extends CommentsState {
  final String errMessage;

  UploadCommentImageFailureState({required this.errMessage});
}

// remove pic
final class RemoveCommentPicture extends CommentsState {}

// get comments
final class GetCommentsLoading extends CommentsState {}

final class GetCommentsSuccess extends CommentsState {}

final class GetCommentsFailure extends CommentsState {
  final String error;

  GetCommentsFailure({required this.error});
}
