part of 'chat_cubit.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class SendMessageLoading extends ChatState {}

final class SendMessageSuccess extends ChatState {}

final class SendMessageFailure extends ChatState {
  final String errMessage;

  const SendMessageFailure({required this.errMessage});
}

final class GetMessagesLoading extends ChatState {}

final class GetMessagesSuccess extends ChatState {}

final class GetMessagesFailure extends ChatState {
  final String errMessage;

  const GetMessagesFailure({required this.errMessage});
}

final class GetChatsSuccessState extends ChatState {}

final class GetChatsLoadingState extends ChatState {}

final class GetChatsFailureState extends ChatState {
  final String errMessage;

  const GetChatsFailureState({required this.errMessage});
}
