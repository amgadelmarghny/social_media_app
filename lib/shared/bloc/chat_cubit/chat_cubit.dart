import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/models/chat_item_model.dart';
import 'package:social_media_app/models/message_model.dart';
import 'package:social_media_app/shared/components/constants.dart';
import 'package:social_media_app/shared/network/local/cache_helper.dart';

part 'chat_state.dart';

/// Cubit class to manage chat-related state and logic
class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  /// List to store messages for the current chat
  List<MessageModel> messageList = [];

  /// Subscription to Firestore messages stream
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  /// Override close to cancel the Firestore subscription when cubit is disposed
  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }

  /// List to store chat items (chat previews)
  List<ChatItemModel> chatItemsList = [];

  /// Fetches the list of chat previews for the current user
  Future<void> getChats() async {
    emit(GetChatsLoadingState());
    try {
      // Get the chat collection for the current user, ordered by creation date
      final messageCollection = await FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(CacheHelper.getData(key: kUidToken))
          .collection(kChatCollection)
          .orderBy(kCreatedAt, descending: true)
          .get();

      chatItemsList.clear();

      // Iterate through each chat document and add to the chatItemsList
      for (var chatItem in messageCollection.docs) {
        ChatItemModel chatItemModel = ChatItemModel(
          uid: chatItem.id,
          message: chatItem.data()['message'],
          dateTime: (chatItem.data()[kCreatedAt] as Timestamp).toDate(),
        );
        chatItemsList.add(chatItemModel);
      }
      emit(GetChatsSuccessState());
    } on Exception catch (e) {
      emit(GetChatsFailureState(errMessage: e.toString()));
    }
  }

  /// Sends a message to Firestore for the given [messageModel]
  Future<void> sendMessages(final MessageModel messageModel) async {
    emit(SendMessageLoading());
    try {
      // Only send if the message is not empty
      if (messageModel.message.isNotEmpty) {
        // Reference to the messages collection for the friend
        final userDoc = FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(CacheHelper.getData(key: kUidToken))
            .collection(kChatCollection)
            .doc(messageModel.friendUid);

        // Add the message to the collection
        userDoc.collection(kMessageCollection).add({
          'message': messageModel.message,
          'friendUid': messageModel.friendUid,
          kCreatedAt: messageModel.dateTime,
        });

        // Update the chat preview with the latest message and timestamp
        await userDoc.set(messageModel.toJson());
      }
      emit(SendMessageSuccess());
    } on Exception catch (e) {
      emit(SendMessageFailure(errMessage: e.toString()));
    }
  }

  /// Listens to messages in real-time for a specific friend [friendUid]
  void getMessages({required String friendUid}) {
    emit(GetMessagesLoading());
    try {
      // Cancel existing subscription to avoid memory leaks
      _messagesSubscription?.cancel();

      // Reference to the messages collection for the friend
      final messageCollection = FirebaseFirestore.instance
          .collection(kUsersCollection)
          .doc(CacheHelper.getData(key: kUidToken))
          .collection(kChatCollection)
          .doc(friendUid)
          .collection(kMessageCollection);

      messageList.clear();

      // Listen to real-time updates from Firestore, ordered by creation date
      _messagesSubscription = messageCollection
          .orderBy(kCreatedAt, descending: true)
          .snapshots()
          .listen((event) {
        messageList.clear();
        // Add each message to the messageList
        for (var doc in event.docs) {
          messageList.add(MessageModel.fromJson(doc.data()));
        }
        emit(GetMessagesSuccess());
      });
    } on Exception catch (e) {
      emit(GetMessagesFailure(errMessage: e.toString()));
    }
  }

  // Future<void> pushMessageNotificationToTheFriend({
  //   required String token,
  //   required String title,
  //   required String content,
  // }) async {
  //   try {
  //     await DioHelper.post(token: token, title: title, bodyContent: content);
  //     emit(PushMessageNotificationToTheFriendSuccess());
  //   } on Exception catch (e) {
  //     emit(PushMessageNotificationToTheFriendFailure(
  //         errMessage: 'Error sending push notification: ${e.toString()}'));
  //   }
  // }
}
