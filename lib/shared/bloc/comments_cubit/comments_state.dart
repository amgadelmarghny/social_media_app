part of 'comments_cubit.dart';

sealed class CommentsState {}

final class CommentsInitial extends CommentsState {}

// add comment
final class AddCommentLoading extends CommentsState {}

final class AddCommentSuccess extends CommentsState {}

final class AddCommentFailure extends CommentsState {
  final String error;

  AddCommentFailure({required this.error});
}

// get comments
final class GetCommentsLoading extends CommentsState {}

final class GetCommentsSuccess extends CommentsState {}

final class GetCommentsFailure extends CommentsState {
  final String error;

  GetCommentsFailure({required this.error});
}