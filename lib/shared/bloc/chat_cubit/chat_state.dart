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

final class PushMessageNotificationToTheFriendSuccess extends ChatState {}

final class PushMessageNotificationToTheFriendFailure extends ChatState {
  final String errMessage;

  const PushMessageNotificationToTheFriendFailure({required this.errMessage});
}

final class GetMessagesLoading extends ChatState {}

final class GetMessagesSuccess extends ChatState {
  final List<MessageModel> messages; // القائمة هنا

  const GetMessagesSuccess({required this.messages});

  @override
  List<Object> get props => [messages];
}

final class GetMessagesFailure extends ChatState {
  final String errMessage;

  const GetMessagesFailure({required this.errMessage});
}

final class RecordingNowState extends ChatState {}

final class RecordingStoped extends ChatState {}

final class UploadRecordLoading extends ChatState {}

final class UploadRecordFailure extends ChatState {
  final String errMessage;

  const UploadRecordFailure({required this.errMessage});
  @override
  List<Object> get props => [errMessage];
}

final class RecordAndUploadAVoiceSuccessState extends ChatState {}

final class RecordAndUploadAVoiceFailureState extends ChatState {
  final String errMessage;

  const RecordAndUploadAVoiceFailureState({required this.errMessage});
  @override
  List<Object> get props => [errMessage];
}

final class GetChatsSuccessState extends ChatState {}

final class GetChatsLoadingState extends ChatState {}

final class GetChatsFailureState extends ChatState {
  final String errMessage;

  const GetChatsFailureState({required this.errMessage});
}
